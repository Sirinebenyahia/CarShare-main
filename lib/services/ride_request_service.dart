import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_request.dart' as model;

class RideRequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _requests = FirebaseFirestore.instance.collection('ride_requests');

  Map<String, dynamic> _timeToJson(model.TimeOfDay t) => {'hour': t.hour, 'minute': t.minute};
  model.TimeOfDay _timeFromJson(Map<String, dynamic> j) => model.TimeOfDay(hour: j['hour'], minute: j['minute']);

  Map<String, dynamic> requestToJson(model.RideRequest r) {
    return {
      'id': r.id,
      'passengerId': r.passengerId,
      'passengerName': r.passengerName,
      'passengerAvatar': r.passengerAvatar,
      'passengerRating': r.passengerRating,
      'origin': r.origin,
      'destination': r.destination,
      'departureDate': r.departureDate.toIso8601String(),
      'departureTime': _timeToJson(r.departureTime),
      'seatsNeeded': r.seatsNeeded,
      'maxPrice': r.maxPrice,
      'notes': r.notes,
      'status': r.status.toString().split('.').last,
      'createdAt': r.createdAt.toIso8601String(),
    };
  }

  model.RideRequest requestFromJson(Map<String, dynamic> j) {
    return model.RideRequest(
      id: j['id'],
      passengerId: j['passengerId'],
      passengerName: j['passengerName'],
      passengerAvatar: j['passengerAvatar'] ?? '',
      passengerRating: (j['passengerRating'] as num?)?.toDouble() ?? 0.0,
      origin: j['origin'],
      destination: j['destination'],
      departureDate: DateTime.parse(j['departureDate']),
      departureTime: _timeFromJson(Map<String, dynamic>.from(j['departureTime'])),
      seatsNeeded: j['seatsNeeded'],
      maxPrice: (j['maxPrice'] as num).toDouble(),
      notes: j['notes'],
      status: model.RideRequestStatus.values.firstWhere(
        (e) => e.toString() == 'RideRequestStatus.${j['status']}',
        orElse: () => model.RideRequestStatus.active,
      ),
      createdAt: DateTime.parse(j['createdAt']),
      proposals: const [], // proposals = sous-collection
    );
  }

  Stream<List<model.RideRequest>> streamAllRequests() {
    return _requests.snapshots().map((snap) {
      return snap.docs.map((d) => requestFromJson(d.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<model.RideRequest>> streamMyRequests(String passengerId) {
    return _requests
        .where('passengerId', isEqualTo: passengerId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => requestFromJson(d.data() as Map<String, dynamic>)).toList());
  }

  // ============================
  // STREAM WITH PROPOSALS (pour les passagers)
  // ============================
  Stream<List<model.RideRequest>> streamMyRequestsWithProposals(String passengerId) {
    return _requests
        .where('passengerId', isEqualTo: passengerId)
        .snapshots()
        .asyncMap((snap) async {
      final requests = <model.RideRequest>[];
      
      for (final doc in snap.docs) {
        final request = requestFromJson(doc.data() as Map<String, dynamic>);
        
        // Charger les propositions depuis la sous-collection
        final proposalsSnap = await proposalsRef(doc.id).get();
        final proposals = proposalsSnap.docs
            .map((d) => proposalFromJson(d.data() as Map<String, dynamic>))
            .toList();
        
        // Créer une nouvelle request avec les propositions
        final requestWithProposals = request.copyWith(proposals: proposals);
        requests.add(requestWithProposals);
      }
      
      return requests;
    });
  }

  Future<String> createRequest(model.RideRequest req) async {
    final doc = _requests.doc();
    final data = requestToJson(req.copyWith(id: doc.id));
    await doc.set(data);
    return doc.id;
  }

  // Proposals subcollection: ride_requests/{id}/proposals/{proposalId}
  CollectionReference<Map<String, dynamic>> proposalsRef(String requestId) {
    return _requests.doc(requestId).collection('proposals');
  }

  Map<String, dynamic> proposalToJson(model.RideProposal p) {
    return {
      'id': p.id,
      'requestId': p.requestId,
      'driverId': p.driverId,
      'driverName': p.driverName,
      'driverAvatar': p.driverAvatar,
      'driverRating': p.driverRating,
      'rideId': p.rideId,
      'vehicleName': p.vehicleName,
      'proposedPrice': p.proposedPrice,
      'message': p.message,
      'status': p.status.toString().split('.').last,
      'createdAt': p.createdAt.toIso8601String(),
    };
  }

  model.RideProposal proposalFromJson(Map<String, dynamic> j) {
    return model.RideProposal(
      id: j['id'],
      requestId: j['requestId'],
      driverId: j['driverId'],
      driverName: j['driverName'],
      driverAvatar: j['driverAvatar'] ?? '',
      driverRating: (j['driverRating'] as num?)?.toDouble() ?? 0.0,
      rideId: j['rideId'],
      vehicleName: j['vehicleName'],
      proposedPrice: (j['proposedPrice'] as num).toDouble(),
      message: j['message'],
      status: model.ProposalStatus.values.firstWhere(
        (e) => e.toString() == 'ProposalStatus.${j['status']}',
        orElse: () => model.ProposalStatus.pending,
      ),
      createdAt: DateTime.parse(j['createdAt']),
    );
  }

  Stream<List<model.RideProposal>> streamProposals(String requestId) {
    return proposalsRef(requestId).snapshots().map((snap) {
      return snap.docs.map((d) => proposalFromJson(d.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<String> addProposal(String requestId, model.RideProposal proposal) async {
    final doc = proposalsRef(requestId).doc();
    final now = DateTime.now();

    final p = proposal.copyWith(id: doc.id, createdAt: now);
    await doc.set(proposalToJson(p));
    return doc.id;
  }

  Future<void> updateProposalStatus({
    required String requestId,
    required String proposalId,
    required String status,
  }) async {
    await proposalsRef(requestId).doc(proposalId).update({'status': status});
  }

  // ============================
  // STREAM ALL PROPOSALS FOR DRIVER (SIMPLIFIÉ)
  // ============================
  Stream<List<model.RideProposal>> streamMyProposals(String driverId) {
    return _requests.snapshots().map((snap) {
      final allProposals = <model.RideProposal>[];
      
      for (final requestDoc in snap.docs) {
        final requestData = requestDoc.data() as Map<String, dynamic>;
        final proposalsData = requestData['proposals'] as List<dynamic>? ?? [];
        
        for (final proposalData in proposalsData) {
          if (proposalData['driverId'] == driverId) {
            final proposal = proposalFromJson(proposalData as Map<String, dynamic>);
            allProposals.add(proposal);
          }
        }
      }
      
      return allProposals;
    });
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _requests.doc(requestId).update({'status': status});
  }
}

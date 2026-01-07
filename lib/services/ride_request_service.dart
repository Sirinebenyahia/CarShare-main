import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ride_request.dart';

class RideRequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _requests = FirebaseFirestore.instance.collection('ride_requests');

  Map<String, dynamic> _timeToJson(TimeOfDay t) => {'hour': t.hour, 'minute': t.minute};
  TimeOfDay _timeFromJson(Map<String, dynamic> j) => TimeOfDay(hour: j['hour'], minute: j['minute']);

  Map<String, dynamic> requestToJson(RideRequest r) {
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

  RideRequest requestFromJson(Map<String, dynamic> j) {
    return RideRequest(
      id: j['id'] as String? ?? '',
      passengerId: j['passengerId'] as String? ?? '',
      passengerName: j['passengerName'] as String? ?? '',
      passengerAvatar: j['passengerAvatar'] as String? ?? '',
      passengerRating: (j['passengerRating'] as num?)?.toDouble() ?? 0.0,
      origin: j['origin'] as String? ?? '',
      destination: j['destination'] as String? ?? '',
      departureDate: j['departureDate'] != null 
          ? DateTime.parse(j['departureDate'] as String)
          : DateTime.now(),
      departureTime: j['departureTime'] != null
          ? _timeFromJson(j['departureTime'] as Map<String, dynamic>)
          : const TimeOfDay(hour: 8, minute: 0),
      seatsNeeded: (j['seatsNeeded'] as int?) ?? 1,
      maxPrice: (j['maxPrice'] as num?)?.toDouble() ?? 20.0,
      notes: j['notes'] as String?,
      status: RideRequestStatus.values.firstWhere(
        (e) => e.toString() == 'RideRequestStatus.${j['status']}',
        orElse: () => RideRequestStatus.active,
      ),
      createdAt: j['createdAt'] != null
          ? DateTime.parse(j['createdAt'] as String)
          : DateTime.now(),
      proposals: const [], // proposals = sous-collection
    );
  }

  Stream<List<RideRequest>> streamAllRequests() {
    return _requests.snapshots().map((snap) {
      return snap.docs.map((d) => requestFromJson(d.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<RideRequest>> streamMyRequests(String passengerId) {
    return _requests
        .where('passengerId', isEqualTo: passengerId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => requestFromJson(d.data() as Map<String, dynamic>)).toList());
  }

  // ============================
  // STREAM WITH PROPOSALS (pour les passagers)
  // ============================
  Stream<List<RideRequest>> streamMyRequestsWithProposals(String passengerId) {
    return _requests
        .where('passengerId', isEqualTo: passengerId)
        .snapshots()
        .asyncMap((snap) async {
      final requests = <RideRequest>[];
      
      for (final doc in snap.docs) {
        final request = requestFromJson(doc.data() as Map<String, dynamic>);
        
        // Charger les propositions depuis la sous-collection
        final proposalsSnap = await _requests.doc(doc.id).collection('proposals').get();
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

  Future<String> createRequest(RideRequest req) async {
    final doc = _requests.doc();
    final data = requestToJson(req.copyWith(id: doc.id));
    await doc.set(data);
    return doc.id;
  }

  // Proposals subcollection: ride_requests/{id}/proposals/{proposalId}
  CollectionReference<Map<String, dynamic>> proposalsRef(String requestId) {
    return _requests.doc(requestId).collection('proposals');
  }

  Map<String, dynamic> proposalToJson(RideProposal p) {
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

  RideProposal proposalFromJson(Map<String, dynamic> j) {
    return RideProposal(
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
      status: ProposalStatus.values.firstWhere(
        (e) => e.toString() == 'ProposalStatus.${j['status']}',
        orElse: () => ProposalStatus.pending,
      ),
      createdAt: DateTime.parse(j['createdAt']),
    );
  }

  Stream<List<RideProposal>> streamProposals(String requestId) {
    return proposalsRef(requestId).snapshots().map((snap) {
      return snap.docs.map((d) => proposalFromJson(d.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<String> addProposal(String requestId, RideProposal proposal) async {
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
  Stream<List<RideProposal>> streamMyProposals(String driverId) {
    return _requests.snapshots().map((snap) {
      final allProposals = <RideProposal>[];
      
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

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_request.dart';

class RideRequestProvider with ChangeNotifier {
  List<RideRequest> _allRequests = [];
  List<RideRequest> _myRequests = [];
  List<RideRequest> _myProposals = [];
  bool _isLoading = false;
  String? _error;

  List<RideRequest> get allRequests => _allRequests;
  List<RideRequest> get myRequests => _myRequests;
  List<RideRequest> get myProposals => _myProposals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RideRequest _reqFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = Map<String, dynamic>.from(d.data());
    data['id'] ??= d.id;
    return RideRequest.fromJson(data);
  }

  // Fetch all ride requests (for drivers to see all requests from passengers)
  Future<void> fetchAllRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('ride_requests')
          .where('status', isEqualTo: RideRequestStatus.active.toString().split('.').last)
          .orderBy('createdAt', descending: false)
          .get();

      _allRequests = snap.docs.map(_reqFromDoc).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch my ride requests (for passengers to see their own requests)
  Future<void> fetchMyRequests(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('ride_requests')
          .where('passengerId', isEqualTo: userId)
          .orderBy('createdAt', descending: false)
          .get();

      _myRequests = snap.docs.map(_reqFromDoc).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch requests where I made proposals (for drivers)
  Future<void> fetchMyProposals(String driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch requests where this driver made proposals
      final snap = await _firestore
          .collection('ride_requests')
          .where('proposals', arrayContains: driverId)
          .orderBy('createdAt', descending: false)
          .get();

      _myProposals = snap.docs.map(_reqFromDoc).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new ride request (passenger)
  Future<void> createRequest(RideRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ref = _firestore.collection('ride_requests').doc();
      final data = request.toJson();
      data['id'] = ref.id;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await ref.set(data);

      final created = request.copyWith(id: ref.id);
      _allRequests.insert(0, created);
      _myRequests.insert(0, created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Cancel a ride request (passenger)
  Future<void> cancelRequest(String requestId) async {
    try {
      await _firestore.collection('ride_requests').doc(requestId).set(
            {
              'status': RideRequestStatus.cancelled.toString().split('.').last,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

      final index = _allRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        _allRequests[index] = _allRequests[index].copyWith(
          status: RideRequestStatus.cancelled,
        );
      }

      final myRequestIndex = _myRequests.indexWhere((req) => req.id == requestId);
      if (myRequestIndex != -1) {
        _myRequests[myRequestIndex] = _myRequests[myRequestIndex].copyWith(
          status: RideRequestStatus.cancelled,
        );
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Submit a proposal (driver)
  Future<void> submitProposal(String requestId, RideProposal proposal) async {
    try {
      await _firestore.collection('ride_requests').doc(requestId).set(
            {
              'proposals': FieldValue.arrayUnion([
                proposal.toJson(),
              ]),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

      // Update local state
      final index = _allRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        final updatedProposals = List<RideProposal>.from(_allRequests[index].proposals);
        updatedProposals.add(proposal);

        _allRequests[index] = _allRequests[index].copyWith(
          proposals: updatedProposals,
        );

        // Also update in myRequests if it's there
        final myRequestIndex = _myRequests.indexWhere((req) => req.id == requestId);
        if (myRequestIndex != -1) {
          _myRequests[myRequestIndex] = _allRequests[index];
        }

        // Add to myProposals if not already there
        if (!_myProposals.any((req) => req.id == requestId)) {
          _myProposals.insert(0, _allRequests[index]);
        }
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Accept a proposal (passenger)
  Future<void> acceptProposal(String requestId, String proposalId) async {
    try {
      final requestIndex = _allRequests.indexWhere((req) => req.id == requestId);
      if (requestIndex == -1) return;

      final request = _allRequests[requestIndex];
      final updatedProposals = request.proposals.map((proposal) {
        if (proposal.id == proposalId) {
          return proposal.copyWith(status: ProposalStatus.accepted);
        } else {
          return proposal.copyWith(status: ProposalStatus.rejected);
        }
      }).toList();

      await _firestore.collection('ride_requests').doc(requestId).set(
            {
              'proposals': updatedProposals.map((p) => p.toJson()).toList(),
              'status': RideRequestStatus.matched.toString().split('.').last,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

      _allRequests[requestIndex] = request.copyWith(
        proposals: updatedProposals,
        status: RideRequestStatus.matched,
      );

      // Update myRequests if applicable
      final myRequestIndex = _myRequests.indexWhere((req) => req.id == requestId);
      if (myRequestIndex != -1) {
        _myRequests[myRequestIndex] = _allRequests[requestIndex];
      }

      // Update myProposals if applicable
      final myProposalIndex = _myProposals.indexWhere((req) => req.id == requestId);
      if (myProposalIndex != -1) {
        _myProposals[myProposalIndex] = _allRequests[requestIndex];
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Get requests by status
  List<RideRequest> getRequestsByStatus(RideRequestStatus status) {
    return _allRequests.where((req) => req.status == status).toList();
  }

  // Get my requests by status
  List<RideRequest> getMyRequestsByStatus(RideRequestStatus status) {
    return _myRequests.where((req) => req.status == status).toList();
  }

  // Get active requests for drivers (exclude cancelled and expired)
  List<RideRequest> getActiveRequestsForDrivers() {
    return _allRequests.where((req) => req.status == RideRequestStatus.active).toList();
  }

  // Get number of active requests
  int get activeRequestsCount {
    return _allRequests.where((req) => req.status == RideRequestStatus.active).length;
  }

  // Get number of my active requests
  int get myActiveRequestsCount {
    return _myRequests.where((req) => req.status == RideRequestStatus.active).length;
  }

  // Get number of proposals I made
  int getMyProposalsCount(String driverId) {
    int count = 0;
    for (var request in _allRequests) {
      count += request.proposals.where((p) => p.driverId == driverId).length;
    }
    return count;
  }

  // Get my proposals with status
  List<RideProposal> getMyProposalsList(String driverId) {
    List<RideProposal> proposals = [];
    for (var request in _allRequests) {
      proposals.addAll(request.proposals.where((p) => p.driverId == driverId));
    }
    return proposals;
  }

  // Search requests by route
  List<RideRequest> searchRequests(String origin, String destination) {
    return _allRequests.where((req) {
      return req.origin.toLowerCase().contains(origin.toLowerCase()) &&
          req.destination.toLowerCase().contains(destination.toLowerCase()) &&
          req.status == RideRequestStatus.active;
    }).toList();
  }
}
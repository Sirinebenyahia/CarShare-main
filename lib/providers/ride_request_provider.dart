import 'package:flutter/foundation.dart';
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

  RideRequestProvider() {
    // Initialize with mock data
    _initializeMockData();
  }

  void _initializeMockData() {
    _allRequests = [
      RideRequest(
        id: 'req_1',
        passengerId: 'user_passenger_1',
        passengerName: 'Ahmed Ben Ali',
        passengerAvatar: '',
        passengerRating: 4.7,
        origin: 'Tunis',
        destination: 'Sousse',
        departureDate: DateTime.now().add(const Duration(days: 2)),
        departureTime: TimeOfDay(hour: 8, minute: 30),
        seatsNeeded: 2,
        maxPrice: 25.0,
        notes: 'Préférence pour trajet direct',
        status: RideRequestStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        proposals: [],
      ),
      RideRequest(
        id: 'req_2',
        passengerId: 'user_passenger_2',
        passengerName: 'Fatma Mansour',
        passengerAvatar: '',
        passengerRating: 4.9,
        origin: 'Sfax',
        destination: 'Tunis',
        departureDate: DateTime.now().add(const Duration(days: 1)),
        departureTime: TimeOfDay(hour: 14, minute: 0),
        seatsNeeded: 1,
        maxPrice: 30.0,
        notes: 'Flexible sur l\'heure de départ',
        status: RideRequestStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        proposals: [],
      ),
      RideRequest(
        id: 'req_3',
        passengerId: 'user_passenger_3',
        passengerName: 'Mohamed Trabelsi',
        passengerAvatar: '',
        passengerRating: 4.5,
        origin: 'Bizerte',
        destination: 'Tunis',
        departureDate: DateTime.now().add(const Duration(days: 3)),
        departureTime: TimeOfDay(hour: 7, minute: 0),
        seatsNeeded: 3,
        maxPrice: 20.0,
        status: RideRequestStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        proposals: [],
      ),
    ];
  }

  // Fetch all ride requests (for drivers to see all requests from passengers)
  Future<void> fetchAllRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // All requests are already available in _allRequests
      // Filter only active requests for drivers to see
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Filter requests created by this user
      _myRequests = _allRequests.where((req) => req.passengerId == userId).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Filter requests where this driver made proposals
      _myProposals = _allRequests.where((req) {
        return req.proposals.any((proposal) => proposal.driverId == driverId);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new ride request (passenger)
  Future<void> createRequest(RideRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Add to all requests (visible to all drivers)
      _allRequests.insert(0, request);
      
      // Add to my requests (visible to this passenger)
      _myRequests.insert(0, request);

      _isLoading = false;
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
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update status instead of removing
      final requestIndex = _allRequests.indexWhere((req) => req.id == requestId);
      if (requestIndex != -1) {
        _allRequests[requestIndex] = _allRequests[requestIndex].copyWith(
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
      notifyListeners();
      rethrow;
    }
  }

  // Submit a proposal (driver)
  Future<void> submitProposal(String requestId, RideProposal proposal) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Find the request and add the proposal
      final requestIndex = _allRequests.indexWhere((req) => req.id == requestId);
      if (requestIndex != -1) {
        final updatedProposals = List<RideProposal>.from(_allRequests[requestIndex].proposals);
        updatedProposals.add(proposal);
        
        _allRequests[requestIndex] = _allRequests[requestIndex].copyWith(
          proposals: updatedProposals,
        );

        // Also update in myRequests if it's there
        final myRequestIndex = _myRequests.indexWhere((req) => req.id == requestId);
        if (myRequestIndex != -1) {
          _myRequests[myRequestIndex] = _allRequests[requestIndex];
        }

        // Add to myProposals
        if (!_myProposals.any((req) => req.id == requestId)) {
          _myProposals.insert(0, _allRequests[requestIndex]);
        }

        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Accept a proposal (passenger)
  Future<void> acceptProposal(String requestId, String proposalId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final requestIndex = _allRequests.indexWhere((req) => req.id == requestId);
      if (requestIndex != -1) {
        final request = _allRequests[requestIndex];
        final updatedProposals = request.proposals.map((proposal) {
          if (proposal.id == proposalId) {
            return proposal.copyWith(status: ProposalStatus.accepted);
          } else {
            return proposal.copyWith(status: ProposalStatus.rejected);
          }
        }).toList();

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
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
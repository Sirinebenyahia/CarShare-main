import 'package:flutter/foundation.dart';
import '../models/ride_request.dart';
import '../services/ride_request_service.dart';

class RideRequestProvider extends ChangeNotifier {
  final RideRequestService _service = RideRequestService();
  
  List<RideRequest> _allRequests = [];
  List<RideRequest> _myRequests = [];
  List<RideProposal> _myProposals = [];
  
  bool _isLoading = false;
  
  // ============================
  // GETTERS
  // ============================
  List<RideRequest> get allRequests => _allRequests;
  List<RideRequest> get myRequests => _myRequests;
  List<RideProposal> get myProposals => _myProposals;
  bool get isLoading => _isLoading;

  // ============================
  // STREAM ALL REQUESTS (driver)
  // ============================
  void listenToAllRequests() {
    _service.streamAllRequests().listen((requests) {
      _allRequests = requests;
      notifyListeners();
    });
  }

  // ============================
  // STREAM MY REQUESTS (passenger)
  // ============================
  void listenToMyRequests(String passengerId) {
    _service.streamMyRequests(passengerId).listen((requests) {
      _myRequests = requests;
      notifyListeners();
    });
  }

  // ============================
  // STREAM MY REQUESTS WITH PROPOSALS (passager avec propositions)
  // ============================
  void listenToMyRequestsWithProposals(String passengerId) {
    _service.streamMyRequestsWithProposals(passengerId).listen((requests) {
      _myRequests = requests;
      notifyListeners();
    });
  }

  // ============================
  // LEGACY METHODS (pour compatibilité)
  // ============================
  Future<void> fetchAllRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      listenToAllRequests();
      await Future.delayed(const Duration(milliseconds: 500)); // petit délai pour le stream
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyRequests(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      listenToMyRequestsWithProposals(userId); // Utiliser le stream avec propositions
      await Future.delayed(const Duration(milliseconds: 500)); // petit délai pour le stream
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // CREATE REQUEST
  // ============================
  Future<void> createRequest(RideRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createRequest(request);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // SUBMIT PROPOSAL
  // ============================
  Future<void> submitProposal(String requestId, RideProposal proposal) async {
    await _service.addProposal(requestId, proposal);
  }

  // ============================
  // ACCEPT PROPOSAL
  // ============================
  Future<void> acceptProposal(String requestId, String proposalId) async {
    try {
      // 1. Mettre à jour le statut de la proposition
      await _service.updateProposalStatus(
        requestId: requestId,
        proposalId: proposalId,
        status: 'accepted',
      );
      
      // 2. Mettre à jour le statut de la demande
      await _service.updateRequestStatus(requestId, 'matched');
      
      // 3. Notifier les listeners pour rafraîchir l'interface
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ============================
  // CANCEL REQUEST
  // ============================
  Future<void> cancelRequest(String requestId) async {
    try {
      // Mettre à jour le statut de la demande
      await _service.updateRequestStatus(requestId, 'cancelled');
      
      // Notifier les listeners pour rafraîchir l'interface
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ============================
  // STREAM MY PROPOSALS (DRIVER) - SIMPLIFIÉ
  // ============================
  void listenToMyProposals(String driverId) {
    _service.streamMyProposals(driverId).listen((proposals) {
      _myProposals = proposals;
      notifyListeners();
    });
  }

  // ============================
  // GET MY PROPOSALS
  // ============================
  // Déjà déclaré ci-dessus

  // ============================
  // GET MY REQUESTS BY STATUS
  // ============================
  List<RideRequest> getMyRequestsByStatus(RideRequestStatus status) {
    return _myRequests.where((req) => req.status == status).toList();
  }

  // ============================
  // ADD PROPOSAL (alias pour compatibilité)
  // ============================
  Future<void> addProposal(String requestId, RideProposal proposal) async {
    await _service.addProposal(requestId, proposal);
  }
}

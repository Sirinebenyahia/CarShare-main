import 'package:flutter/material.dart';
import '../models/group.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _allGroups = [];
  List<Group> _myGroups = [];
  bool _isLoading = false;

  List<Group> get allGroups => _allGroups;
  List<Group> get myGroups => _myGroups;
  bool get isLoading => _isLoading;

  GroupProvider() {
    _initializeMockGroups();
  }

  void _initializeMockGroups() {
    _allGroups = [
      Group(
        id: '1',
        name: 'Covoiturage Tunis-Sfax',
        description: 'Groupe pour les trajets réguliers entre Tunis et Sfax',
        creatorId: '1',
        type: GroupType.public_group,
        memberIds: ['1', '2', '3', '4'],
        memberCount: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Group(
        id: '2',
        name: 'Université de Sousse',
        description: 'Groupe pour les étudiants de l\'université de Sousse',
        creatorId: '2',
        type: GroupType.public_group,
        memberIds: ['2', '5', '6', '7', '8'],
        memberCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];

    _myGroups = [_allGroups[0]];
  }

  Future<void> fetchAllGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // _allGroups déjà initialisé
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyGroups(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _myGroups = _allGroups.where((group) => group.memberIds.contains(userId)).toList();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required String creatorId,
    required GroupType type,
    String? imageUrl,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final newGroup = Group(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        imageUrl: imageUrl,
        creatorId: creatorId,
        type: type,
        memberIds: [creatorId],
        memberCount: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _allGroups.add(newGroup);
      _myGroups.add(newGroup);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> joinGroup(String groupId, String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _allGroups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        final group = _allGroups[index];
        if (!group.memberIds.contains(userId)) {
          // Update group
          _myGroups.add(group);
        }
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _myGroups.removeWhere((g) => g.id == groupId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Group? getGroupById(String groupId) {
    try {
      return _allGroups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }
}

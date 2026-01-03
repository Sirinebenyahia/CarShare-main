import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _allGroups = [];
  List<Group> _myGroups = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Group> get allGroups => _allGroups;
  List<Group> get myGroups => _myGroups;
  bool get isLoading => _isLoading;

  Group _groupFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = Map<String, dynamic>.from(d.data());
    data['id'] ??= d.id;
    return Group.fromJson(data);
  }

  Future<void> fetchAllGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('groups')
          .orderBy('createdAt', descending: false)
          .get();

      _allGroups = snap.docs.map(_groupFromDoc).toList();
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
      final snap = await _firestore
          .collection('groups')
          .where('memberIds', arrayContains: userId)
          .orderBy('createdAt', descending: false)
          .get();

      _myGroups = snap.docs.map(_groupFromDoc).toList();
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
      final ref = _firestore.collection('groups').doc();
      final data = {
        'id': ref.id,
        'name': name,
        'description': description,
        'creatorId': creatorId,
        'type': type.toString().split('.').last,
        'imageUrl': imageUrl,
        'memberIds': [creatorId],
        'memberCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await ref.set(data);

      final newGroup = Group(
        id: ref.id,
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
      await _firestore.collection('groups').doc(groupId).set(
            {
              'memberIds': FieldValue.arrayUnion([userId]),
              'memberCount': FieldValue.increment(1),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

      final index = _allGroups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        final group = _allGroups[index];
        if (!group.memberIds.contains(userId)) {
          final updated = group.copyWith(
            memberIds: [...group.memberIds, userId],
            memberCount: group.memberCount + 1,
            updatedAt: DateTime.now(),
          );
          _allGroups[index] = updated;
          _myGroups.add(updated);
        }
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).set(
            {
              'memberIds': FieldValue.arrayRemove([userId]),
              'memberCount': FieldValue.increment(-1),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 0.0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Transaction _txFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = Map<String, dynamic>.from(d.data());
    data['id'] ??= d.id;
    return Transaction.fromJson(data);
  }

  Future<void> fetchBalance(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (doc.exists) {
        _balance = (doc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('wallets')
          .doc(userId)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .get();

      _transactions = snap.docs.map(_txFromDoc).toList();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rechargeWallet(double amount) async {
    try {
      final auth = _firestore.collection('users').doc('dummy').snapshots().first;
      final userId = 'dummy'; // TODO: get real userId via AuthProvider

      final walletRef = _firestore.collection('wallets').doc(userId);
      await walletRef.set(
        {
          'balance': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final txRef = walletRef.collection('transactions').doc();
      final tx = Transaction(
        id: txRef.id,
        userId: userId,
        type: TransactionType.recharge,
        amount: amount,
        description: 'Recharge du portefeuille',
        createdAt: DateTime.now(),
      );

      await txRef.set({
        'id': tx.id,
        'userId': tx.userId,
        'type': tx.type.toString().split('.').last,
        'amount': tx.amount,
        'description': tx.description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _balance += amount;
      _transactions.insert(0, tx);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> makePayment({
    required double amount,
    required String description,
    String? relatedId,
  }) async {
    if (_balance < amount) {
      throw Exception('Solde insuffisant');
    }

    try {
      final userId = 'dummy'; // TODO: get real userId via AuthProvider
      final walletRef = _firestore.collection('wallets').doc(userId);

      await walletRef.set(
        {
          'balance': FieldValue.increment(-amount),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final txRef = walletRef.collection('transactions').doc();
      final tx = Transaction(
        id: txRef.id,
        userId: userId,
        type: TransactionType.payment,
        amount: -amount,
        description: description,
        relatedId: relatedId,
        createdAt: DateTime.now(),
      );

      await txRef.set({
        'id': tx.id,
        'userId': tx.userId,
        'type': tx.type.toString().split('.').last,
        'amount': tx.amount,
        'description': tx.description,
        'relatedId': tx.relatedId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _balance -= amount;
      _transactions.insert(0, tx);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addEarnings({
    required double amount,
    required String description,
    String? relatedId,
  }) async {
    try {
      final userId = 'dummy'; // TODO: get real userId via AuthProvider
      final walletRef = _firestore.collection('wallets').doc(userId);

      await walletRef.set(
        {
          'balance': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final txRef = walletRef.collection('transactions').doc();
      final tx = Transaction(
        id: txRef.id,
        userId: userId,
        type: TransactionType.earning,
        amount: amount,
        description: description,
        relatedId: relatedId,
        createdAt: DateTime.now(),
      );

      await txRef.set({
        'id': tx.id,
        'userId': tx.userId,
        'type': tx.type.toString().split('.').last,
        'amount': tx.amount,
        'description': tx.description,
        'relatedId': tx.relatedId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _balance += amount;
      _transactions.insert(0, tx);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refund({
    required double amount,
    required String description,
    String? relatedId,
  }) async {
    try {
      final userId = 'dummy'; // TODO: get real userId via AuthProvider
      final walletRef = _firestore.collection('wallets').doc(userId);

      await walletRef.set(
        {
          'balance': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final txRef = walletRef.collection('transactions').doc();
      final tx = Transaction(
        id: txRef.id,
        userId: userId,
        type: TransactionType.refund,
        amount: amount,
        description: description,
        relatedId: relatedId,
        createdAt: DateTime.now(),
      );

      await txRef.set({
        'id': tx.id,
        'userId': tx.userId,
        'type': tx.type.toString().split('.').last,
        'amount': tx.amount,
        'description': tx.description,
        'relatedId': tx.relatedId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _balance += amount;
      _transactions.insert(0, tx);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}

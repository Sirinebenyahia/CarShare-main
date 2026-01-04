import 'package:flutter/material.dart';
import '../models/transaction.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 150.0; // Mock balance
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  WalletProvider() {
    _initializeMockTransactions();
  }

  void _initializeMockTransactions() {
    _transactions = [
      Transaction(
        id: '1',
        userId: '1',
        type: TransactionType.recharge,
        amount: 100.0,
        description: 'Recharge du portefeuille',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: '2',
        userId: '1',
        type: TransactionType.payment,
        amount: -25.0,
        description: 'Paiement trajet Tunis - Sfax',
        relatedId: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: '3',
        userId: '1',
        type: TransactionType.earning,
        amount: 75.0,
        description: 'Gains trajet Sousse - Tunis',
        relatedId: '2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<void> fetchBalance(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // _balance déjà initialisé
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
      await Future.delayed(const Duration(seconds: 1));
      // _transactions déjà initialisé
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rechargeWallet(double amount) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      _balance += amount;

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1',
        type: TransactionType.recharge,
        amount: amount,
        description: 'Recharge du portefeuille',
        createdAt: DateTime.now(),
      );

      _transactions.insert(0, transaction);
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
      await Future.delayed(const Duration(seconds: 1));

      _balance -= amount;

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1',
        type: TransactionType.payment,
        amount: -amount,
        description: description,
        relatedId: relatedId,
        createdAt: DateTime.now(),
      );

      _transactions.insert(0, transaction);
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
      await Future.delayed(const Duration(seconds: 1));

      _balance += amount;

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1',
        type: TransactionType.earning,
        amount: amount,
        description: description,
        relatedId: relatedId,
        createdAt: DateTime.now(),
      );

      _transactions.insert(0, transaction);
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
      await Future.delayed(const Duration(seconds: 1));

      _balance += amount;

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1',
        type: TransactionType.refund,
        amount: amount,
        description: description,
        relatedId: relatedId,
        createdAt: DateTime.now(),
      );

      _transactions.insert(0, transaction);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<WalletProvider>().fetchBalance(userId);
      await context.read<WalletProvider>().fetchTransactions(userId);
    }
  }

  void _showRechargeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const RechargeModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon portefeuille'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<WalletProvider>(
          builder: (context, walletProvider, _) {
            if (walletProvider.isLoading && walletProvider.transactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Balance Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Solde disponible',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${walletProvider.balance.toStringAsFixed(2)} TND',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showRechargeModal,
                              icon: const Icon(Icons.add),
                              label: const Text('Recharger'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Withdraw
                              },
                              icon: const Icon(Icons.remove),
                              label: const Text('Retirer'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Filter transactions
                      },
                      child: const Text('Filtrer'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Transactions List
                if (walletProvider.transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune transaction',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...walletProvider.transactions.map((transaction) {
                    return _buildTransactionCard(transaction);
                  }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    IconData icon;
    Color color;
    String sign;

    switch (transaction.type) {
      case TransactionType.recharge:
        icon = Icons.add_circle;
        color = AppTheme.successGreen;
        sign = '+';
        break;
      case TransactionType.payment:
        icon = Icons.remove_circle;
        color = AppTheme.errorRed;
        sign = '';
        break;
      case TransactionType.earning:
        icon = Icons.trending_up;
        color = AppTheme.successGreen;
        sign = '+';
        break;
      case TransactionType.refund:
        icon = Icons.refresh;
        color = AppTheme.warningOrange;
        sign = '+';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          '$sign${transaction.amount.abs().toStringAsFixed(2)} TND',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

class RechargeModal extends StatefulWidget {
  const RechargeModal({Key? key}) : super(key: key);

  @override
  State<RechargeModal> createState() => _RechargeModalState();
}

class _RechargeModalState extends State<RechargeModal> {
  final _amountController = TextEditingController(text: '50');
  final List<double> _quickAmounts = [20, 50, 100, 200];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleRecharge() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant minimum: 10 TND'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    try {
      await context.read<WalletProvider>().rechargeWallet(amount);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recharge effectuée avec succès!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recharger le portefeuille',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick amounts
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _quickAmounts.map((amount) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _amountController.text = amount.toStringAsFixed(0);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${amount.toStringAsFixed(0)} TND',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Custom amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant personnalisé',
                suffixText: 'TND',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment method info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mode démo: Le montant sera ajouté instantanément',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recharge button
            Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                return CustomButton(
                  text: 'Recharger',
                  icon: Icons.payment,
                  isLoading: walletProvider.isLoading,
                  onPressed: _handleRecharge,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

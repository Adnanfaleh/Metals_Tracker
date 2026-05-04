import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:metals_tracker/domain/models/transaction_model.dart';
import 'package:metals_tracker/presentation/providers/portfolio_provider.dart';

class TransactionListScreen extends ConsumerWidget {
  final AssetType assetType;

  const TransactionListScreen({super.key, required this.assetType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real data coming from the Isar database
    final transactionsAsync = ref.watch(transactionsProvider(assetType));

    return Scaffold(
      appBar: AppBar(
        title: Text('${assetType.name.toUpperCase()} History'),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions yet. Add one!'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isBuy = tx.type == TransactionType.buy;

              // Formatting the date (DD/MM/YYYY)
              final dateStr = DateFormat('dd/MM/yyyy').format(tx.date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isBuy
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    child: Icon(
                      isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isBuy ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text('${tx.amountGr} gr @ \$${tx.pricePerGr}'),
                  subtitle: Text(dateStr),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '\$${tx.totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

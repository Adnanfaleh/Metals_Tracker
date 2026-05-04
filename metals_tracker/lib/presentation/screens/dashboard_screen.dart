import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metals_tracker/domain/models/transaction_model.dart';
import 'package:metals_tracker/presentation/providers/portfolio_provider.dart';
import 'package:metals_tracker/presentation/widgets/live_prices_card.dart';
import 'package:metals_tracker/presentation/screens/transaction_list_screen.dart';
import 'package:metals_tracker/presentation/screens/settings_screen.dart';
import 'package:metals_tracker/presentation/widgets/add_transaction_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final silverSummary = ref.watch(portfolioSummaryProvider(AssetType.silver));
    final goldSummary = ref.watch(portfolioSummaryProvider(AssetType.gold));
    final totalPortfolio = ref.watch(totalPortfolioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metals Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text('Total Portfolio Value',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Text(
                          '\$${totalPortfolio.totalCurrentValueUsd.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        'Total P&L: \$${totalPortfolio.totalNetPnl.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: totalPortfolio.totalNetPnl >= 0
                              ? const Color.fromARGB(255, 58, 105, 61)
                              : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // The Live Price Card
              const LivePriceCard(),

              const SizedBox(height: 24),
              const Text('Individual Assets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Silver Card
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionListScreen(
                          assetType: AssetType.silver),
                    )),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('🥈 Silver Holdings',
                            style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 10),
                        Text(
                            '${silverSummary.netHoldingsGr.toStringAsFixed(2)} gr',
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          'Net P&L: \$${silverSummary.netPnl.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: silverSummary.netPnl >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Gold Card
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionListScreen(
                          assetType: AssetType.gold),
                    )),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('🥇 Gold Holdings',
                            style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 10),
                        Text(
                            '${goldSummary.netHoldingsGr.toStringAsFixed(2)} gr',
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          'Net P&L: \$${goldSummary.netPnl.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: goldSummary.netPnl >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTransactionSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

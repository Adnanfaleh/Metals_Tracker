import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metals_tracker/domain/models/transaction_model.dart';
import 'package:metals_tracker/presentation/providers/portfolio_provider.dart';

class LivePriceCard extends ConsumerWidget {
  const LivePriceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the live price streams
    final goldAsync = ref.watch(livePriceProvider(AssetType.gold));
    final silverAsync = ref.watch(livePriceProvider(AssetType.silver));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Market Prices (per gram)',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceItem(
                  context: context,
                  title: 'Gold',
                  icon: '🥇',
                  asyncValue: goldAsync,
                ),
                Container(
                    width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                _buildPriceItem(
                  context: context,
                  title: 'Silver',
                  icon: '🥈',
                  asyncValue: silverAsync,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem({
    required BuildContext context,
    required String title,
    required String icon,
    required AsyncValue<double> asyncValue,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        // Handle the loading, error, and data states of the StreamProvider
        asyncValue.when(
          data: (price) => Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          loading: () => const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
          error: (err, stack) =>
              const Text('Error', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:metals_tracker/domain/models/transaction_model.dart';
import 'package:metals_tracker/domain/repositories/transaction_repository.dart';
import 'package:metals_tracker/data/repositories/transaction_repository_impl.dart';
import 'package:metals_tracker/main.dart';

class PortfolioSummary {
  final double totalBoughtGr;
  final double totalSoldGr;
  final double netHoldingsGr;
  final double totalInvestedUsd;
  final double totalRevenueUsd;
  final double avgBuyPrice;
  final double netPnl;

  PortfolioSummary({
    required this.totalBoughtGr,
    required this.totalSoldGr,
    required this.netHoldingsGr,
    required this.totalInvestedUsd,
    required this.totalRevenueUsd,
    required this.avgBuyPrice,
    required this.netPnl,
  });
}

class TotalPortfolioSummary {
  final double totalInvestedUsd;
  final double totalCurrentValueUsd;
  final double totalNetPnl;

  TotalPortfolioSummary({
    required this.totalInvestedUsd,
    required this.totalCurrentValueUsd,
    required this.totalNetPnl,
  });
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TransactionRepositoryImpl(isar);
});

final transactionsProvider =
    FutureProvider.family<List<TransactionModel>, AssetType>(
        (ref, asset) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return await repository.getTransactions(asset);
});

final livePriceProvider =
    StreamProvider.family<double, AssetType>((ref, asset) {
  final supabase = Supabase.instance.client;
  return supabase
      .from('market_prices')
      .stream(primaryKey: ['asset_type'])
      .eq('asset_type', asset.name)
      .map((rows) {
        if (rows.isNotEmpty) {
          // Return the live price from the database
          return double.parse(rows.first['price_usd'].toString());
        }
        // Fallback safety net
        return asset == AssetType.gold ? 85.50 : 28.30;
      }); // 🌟 FIXED: Added missing closing brackets here
});

final portfolioSummaryProvider =
    Provider.family<PortfolioSummary, AssetType>((ref, asset) {
  final transactions = ref.watch(transactionsProvider(asset)).value ?? [];
  final livePrice = ref.watch(livePriceProvider(asset)).value ??
      (asset == AssetType.gold ? 85.50 : 28.30);

  double boughtGr = 0;
  double soldGr = 0;
  double invested = 0;
  double revenue = 0;

  for (var tx in transactions) {
    if (tx.type == TransactionType.buy) {
      boughtGr += tx.amountGr;
      invested += tx.totalValue;
    } else {
      soldGr += tx.amountGr;
      revenue += tx.totalValue;
    }
  }

  final netHoldings = boughtGr - soldGr;
  final avgBuyPrice = boughtGr > 0 ? invested / boughtGr : 0.0;
  final currentValue = netHoldings * livePrice;
  final netPnl = (currentValue + revenue) - invested;

  return PortfolioSummary(
    totalBoughtGr: boughtGr,
    totalSoldGr: soldGr,
    netHoldingsGr: netHoldings,
    totalInvestedUsd: invested,
    totalRevenueUsd: revenue,
    avgBuyPrice: avgBuyPrice,
    netPnl: netPnl,
  );
});

// NEW: Provider that combines Gold and Silver summaries
final totalPortfolioProvider = Provider<TotalPortfolioSummary>((ref) {
  final silver = ref.watch(portfolioSummaryProvider(AssetType.silver));
  final gold = ref.watch(portfolioSummaryProvider(AssetType.gold));

  // 🌟 FIXED: Extracted .value from the StreamProvider with a fallback
  final liveSilverPrice =
      ref.watch(livePriceProvider(AssetType.silver)).value ?? 28.30;
  final liveGoldPrice =
      ref.watch(livePriceProvider(AssetType.gold)).value ?? 85.50;

  final silverCurrentValue = silver.netHoldingsGr * liveSilverPrice;
  final goldCurrentValue = gold.netHoldingsGr * liveGoldPrice;

  return TotalPortfolioSummary(
    totalInvestedUsd: silver.totalInvestedUsd + gold.totalInvestedUsd,
    totalCurrentValueUsd: silverCurrentValue + goldCurrentValue,
    totalNetPnl: silver.netPnl + gold.netPnl,
  );
});

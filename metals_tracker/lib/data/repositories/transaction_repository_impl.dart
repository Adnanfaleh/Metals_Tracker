import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:metals_tracker/domain/models/transaction_model.dart';
import 'package:metals_tracker/domain/repositories/transaction_repository.dart';
import 'package:metals_tracker/data/local/isar_transaction.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final Isar isar;
  final SupabaseClient supabase = Supabase.instance.client;

  TransactionRepositoryImpl(this.isar);

  @override
  Future<List<TransactionModel>> getTransactions(AssetType asset) async {
    final isarAsset =
        asset == AssetType.gold ? IsarAssetType.gold : IsarAssetType.silver;

    final localData = await isar.isarTransactions
        .filter()
        .assetEqualTo(isarAsset)
        .sortByDateDesc()
        .findAll();

    return localData
        .map((e) => TransactionModel(
              id: e.remoteId,
              asset: asset,
              type: e.type == IsarTransactionType.buy
                  ? TransactionType.buy
                  : TransactionType.sell,
              amountGr: e.amountGr,
              pricePerGr: e.pricePerGr,
              date: e.date,
              notes: e.notes,
            ))
        .toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    // Push to Supabase PostgreSQL
    final response = await supabase
        .from('transactions')
        .insert({
          'user_id': supabase.auth.currentUser!.id, // RLS enforced here
          'asset_type': transaction.asset.name,
          'transaction_type': transaction.type.name,
          'amount_gr': transaction.amountGr,
          'price_per_gr': transaction.pricePerGr,
          'transaction_date': transaction.date.toIso8601String(),
          'notes': transaction.notes,
        })
        .select()
        .single();

    // Save to Isar Local Database for Offline Read-Only mode
    final isarTx = IsarTransaction()
      ..remoteId = response['id']
      ..asset = transaction.asset == AssetType.gold
          ? IsarAssetType.gold
          : IsarAssetType.silver
      ..type = transaction.type == TransactionType.buy
          ? IsarTransactionType.buy
          : IsarTransactionType.sell
      ..amountGr = transaction.amountGr
      ..pricePerGr = transaction.pricePerGr
      ..date = transaction.date
      ..notes = transaction.notes;

    await isar.writeTxn(() async {
      await isar.isarTransactions.put(isarTx);
    });
  }

  @override
  Future<void> syncWithRemote() async {
    // Add logic here to fetch all user rows from Supabase and update Isar
  }
}

import 'package:metals_tracker/domain/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions(AssetType asset);
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> syncWithRemote();
}

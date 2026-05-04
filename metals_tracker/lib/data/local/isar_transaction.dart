import 'package:isar/isar.dart';

part 'isar_transaction.g.dart';

enum IsarAssetType { gold, silver }

enum IsarTransactionType { buy, sell }

@collection
class IsarTransaction {
  Id id = Isar.autoIncrement; // Local Isar ID

  @Index(unique: true)
  late String remoteId; // Supabase UUID

  @enumerated
  late IsarAssetType asset;

  @enumerated
  late IsarTransactionType type;

  late double amountGr;
  late double pricePerGr;
  late DateTime date;
  String? notes;
}

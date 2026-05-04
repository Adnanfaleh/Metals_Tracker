enum AssetType { gold, silver }

enum TransactionType { buy, sell }

class TransactionModel {
  final String id;
  final AssetType asset;
  final TransactionType type;
  final double amountGr;
  final double pricePerGr;
  final DateTime date;
  final String? notes;

  TransactionModel({
    required this.id,
    required this.asset,
    required this.type,
    required this.amountGr,
    required this.pricePerGr,
    required this.date,
    this.notes,
  });

  double get totalValue => amountGr * pricePerGr;
}

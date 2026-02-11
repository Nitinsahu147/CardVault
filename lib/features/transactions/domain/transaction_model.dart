import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 3)
enum TransactionType {
  @HiveField(0)
  debit,
  @HiveField(1)
  credit,
}

@HiveType(typeId: 4)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cardId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String note;

  @HiveField(5)
  final TransactionType type;

  TransactionModel({
    String? id,
    required this.cardId,
    required this.amount,
    required this.date,
    required this.note,
    required this.type,
  }) : id = id ?? const Uuid().v4();
}

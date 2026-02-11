import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/storage/hive_storage.dart';
import '../domain/transaction_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

class TransactionRepository {
  Box<TransactionModel> get _box => Hive.box<TransactionModel>(HiveStorage.transactionBoxName);

  Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  List<TransactionModel> getTransactionsForCard(String cardId) {
    return _box.values.where((t) => t.cardId == cardId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }
}

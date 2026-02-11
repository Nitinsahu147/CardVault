import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/storage/hive_storage.dart';
import '../domain/card_model.dart';

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository();
});

class CardRepository {
  Box<CardModel> get _box => Hive.box<CardModel>(HiveStorage.cardBoxName);

  Future<void> addCard(CardModel card) async {
    await _box.put(card.id, card);
  }

  Future<void> updateCard(CardModel card) async {
    await _box.put(card.id, card);
  }

  Future<void> deleteCard(String id) async {
    await _box.delete(id);
  }

  List<CardModel> getAllCards() {
    return _box.values.toList();
  }

  CardModel? getCard(String id) {
    return _box.get(id);
  }

  Future<void> incrementUsageCount(String id) async {
    final card = getCard(id);
    if (card != null) {
      final updatedCard = CardModel(
        id: card.id,
        bankName: card.bankName,
        holderName: card.holderName,
        cardNumber: card.cardNumber,
        expiryDate: card.expiryDate,
        cvv: card.cvv,
        cardType: card.cardType,
        subCategory: card.subCategory, // Ensure this field exists
        creditLimit: card.creditLimit,
        colorIndex: card.colorIndex,
        usageCount: card.usageCount + 1,
      );
      await updateCard(updatedCard);
    }
  }
}

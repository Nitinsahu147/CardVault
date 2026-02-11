import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/cards/domain/card_model.dart';
import '../../features/transactions/domain/transaction_model.dart';
import 'secure_storage.dart';

class HiveStorage {
  static const String cardBoxName = 'cards_box';
  static const String transactionBoxName = 'transactions_box';
  static const String settingsBoxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CardTypeAdapter());
    Hive.registerAdapter(CardNetworkAdapter());
    Hive.registerAdapter(CardModelAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());

    final encryptionKey = await SecureStorageService.getHiveEncryptionKey();

    await Hive.openBox<CardModel>(
      cardBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    await Hive.openBox<TransactionModel>(
      transactionBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    // Settings might not need encryption, but good for privacy
    await Hive.openBox(settingsBoxName);
  }

  static Box<CardModel> get cardBox => Hive.box<CardModel>(cardBoxName);
  static Box<TransactionModel> get transactionBox => Hive.box<TransactionModel>(transactionBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
}

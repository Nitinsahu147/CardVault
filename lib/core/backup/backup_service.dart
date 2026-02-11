import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:card_vault/core/storage/hive_storage.dart';
import 'package:card_vault/features/cards/domain/card_model.dart';
import 'package:card_vault/features/transactions/domain/transaction_model.dart';

class BackupService {
  static const _backupExtension = 'cvbackup';

  // --- Export Data ---
  static Future<void> exportData(BuildContext context, String password) async {
    try {
      // 1. Gather all data
      final cardBox = HiveStorage.cardBox;
      final transactionBox = HiveStorage.transactionBox;

      final List<Map<String, dynamic>> cardsJson = cardBox.values.map((e) {
        // We need a strict toJson. Since CardModel is HiveObject, we might need manual mapping 
        // if toJson isn't generated or if we want specific format.
        // Let's assume we map manually for safety or add toJson to models.
        // For now, let's map manually here to avoid modifying models too much if not needed.
        final card = e as CardModel;
        return {
          'id': card.id,
          'bankName': card.bankName,
          'holderName': card.holderName,
          'cardNumber': card.cardNumber,
          'expiryDate': card.expiryDate,
          'cvv': card.cvv,
          'cardType': card.cardType.index, // Store index for enum
          'subCategory': card.subCategory,
          'creditLimit': card.creditLimit,
          'colorIndex': card.colorIndex,
          'usageCount': card.usageCount,
        };
      }).toList();

      final List<Map<String, dynamic>> transactionsJson = transactionBox.values.map((e) {
        final tx = e as TransactionModel;
        return {
          'id': tx.id,
          'cardId': tx.cardId,
          'amount': tx.amount,
          'date': tx.date.toIso8601String(),
          'note': tx.note,
          'type': tx.type.index,
        };
      }).toList();

      final fullData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'cards': cardsJson,
        'transactions': transactionsJson,
      };

      final jsonString = jsonEncode(fullData);

      // 2. Encrypt
      final key = encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32)); // Simple padding
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encrypted = encrypter.encrypt(jsonString, iv: iv);
      final encryptedData = iv.base64 + ":" + encrypted.base64; // Prepend IV

      // 3. Save to Temp File
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.$_backupExtension');
      await file.writeAsString(encryptedData);

      // 4. Share
      await Share.shareXFiles([XFile(file.path)], text: 'CardVault Backup');

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Backup Successful', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Backup successful! Please remember the password for restore.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Import Data ---
  static Future<void> importData(BuildContext context, String password) async {
    print('Starting Import...');
    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, 
      );

      if (result == null) {
        print('Import cancelled or no file selected');
        return;
      }
      
      print('File picked: ${result.files.single.path}');

      final file = File(result.files.single.path!);
      if (!await file.exists()) {
         throw 'File not found at path: ${result.files.single.path}';
      }

      final encryptedContent = await file.readAsString();
      print('File read. Length: ${encryptedContent.length}');

      // 2. Decrypt
      final parts = encryptedContent.split(':');
      if (parts.length != 2) throw 'Invalid backup file format';

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedData = parts[1];
      print('IV extracted. Encrypted data length: ${encryptedData.length}');

      final key = encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32));
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
      print('Decryption successful. JSON parsing...');
      
      final data = jsonDecode(decrypted);
      print('JSON parsed. Version: ${data['version']}');

      // 3. Restore (Clear and Add)
      // Verify version
      if (data['version'] != 1) throw 'Unsupported backup version';

      final cardBox = HiveStorage.cardBox;
      final transactionBox = HiveStorage.transactionBox;

      print('Clearing existing data...');
      await cardBox.clear();
      await transactionBox.clear();

      print('Restoring cards...');
      final List cards = data['cards'];
      for (var c in cards) {
        print('Restoring card: ${c['id']}');
        final card = CardModel(
          id: c['id'], // Ensure constructor supports ID override or we use reflection/manual
          bankName: c['bankName'],
          holderName: c['holderName'],
          cardNumber: c['cardNumber'],
          expiryDate: c['expiryDate'],
          cvv: c['cvv'],
          cardType: CardType.values[c['cardType']],
          subCategory: c['subCategory'] ?? 'Other',
          creditLimit: c['creditLimit'],
          colorIndex: c['colorIndex'],
          usageCount: c['usageCount'] ?? 0,
        );
        // Hive usually adds by auto-increment key if using add(), but we used put() with ID in repo?
        // CardRepository uses put(card.id, card).
        await cardBox.put(card.id, card);
      }

      final List transactions = data['transactions'];
      for (var t in transactions) {
        final tx = TransactionModel(
          id: t['id'],
          cardId: t['cardId'],
          amount: t['amount'],
          date: DateTime.parse(t['date']),
          note: t['note'],
          type: TransactionType.values[t['type']],
        );
         await transactionBox.put(tx.id, tx);
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Restore Successful', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Restore successful! Please restart the app. If the restore is not done, it means you entered an incorrect password.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

    } catch (e, stackTrace) {
       print('Import Error: $e');
       print(stackTrace);
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore Failed: $e'), backgroundColor: Colors.red),
        );
       }
    }
  }
}

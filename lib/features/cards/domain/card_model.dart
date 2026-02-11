import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'card_model.g.dart';

@HiveType(typeId: 0)
enum CardType {
  @HiveField(0)
  debit,
  @HiveField(1)
  credit,
}

@HiveType(typeId: 1)
enum CardNetwork {
  @HiveField(0)
  visa,
  @HiveField(1)
  mastercard,
  @HiveField(2)
  amex,
  @HiveField(3)
  discover,
  @HiveField(4)
  rupay,
  @HiveField(5)
  other,
}

@HiveType(typeId: 2)
class CardModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bankName;

  @HiveField(2)
  final String holderName;

  @HiveField(3)
  final String cardNumber;

  @HiveField(4)
  final String expiryDate; // MM/YY

  @HiveField(5)
  final String cvv;

  @HiveField(6)
  final CardType cardType;

  // @HiveField(7) is deprecated (was network)
  // We can keep the index 7 reserved or just use a new index. 
  // For dev, we'll replace it but in prod avoid changing types of existing fields.
  @HiveField(8)
  final double? creditLimit;

  @HiveField(9)
  final int colorIndex; 

  @HiveField(10, defaultValue: 'Other')
  final String subCategory;

  @HiveField(11, defaultValue: 0)
  final int usageCount;

  CardModel({
    String? id,
    required this.bankName,
    required this.holderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
    required this.subCategory,
    this.creditLimit,
    required this.colorIndex,
    this.usageCount = 0,
  }) : id = id ?? const Uuid().v4();
  
  String get last4Digits => cardNumber.length >= 4 
      ? cardNumber.substring(cardNumber.length - 4) 
      : cardNumber;

  String get formattedCardNumber {
    // Split into chunks of 4
    return cardNumber.replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ');
  }
}

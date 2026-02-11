// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardModelAdapter extends TypeAdapter<CardModel> {
  @override
  final int typeId = 2;

  @override
  CardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardModel(
      id: fields[0] as String?,
      bankName: fields[1] as String,
      holderName: fields[2] as String,
      cardNumber: fields[3] as String,
      expiryDate: fields[4] as String,
      cvv: fields[5] as String,
      cardType: fields[6] as CardType,
      subCategory: fields[10] == null ? 'Other' : fields[10] as String,
      creditLimit: fields[8] as double?,
      colorIndex: fields[9] as int,
      usageCount: fields[11] == null ? 0 : fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CardModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bankName)
      ..writeByte(2)
      ..write(obj.holderName)
      ..writeByte(3)
      ..write(obj.cardNumber)
      ..writeByte(4)
      ..write(obj.expiryDate)
      ..writeByte(5)
      ..write(obj.cvv)
      ..writeByte(6)
      ..write(obj.cardType)
      ..writeByte(8)
      ..write(obj.creditLimit)
      ..writeByte(9)
      ..write(obj.colorIndex)
      ..writeByte(10)
      ..write(obj.subCategory)
      ..writeByte(11)
      ..write(obj.usageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CardTypeAdapter extends TypeAdapter<CardType> {
  @override
  final int typeId = 0;

  @override
  CardType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CardType.debit;
      case 1:
        return CardType.credit;
      default:
        return CardType.debit;
    }
  }

  @override
  void write(BinaryWriter writer, CardType obj) {
    switch (obj) {
      case CardType.debit:
        writer.writeByte(0);
        break;
      case CardType.credit:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CardNetworkAdapter extends TypeAdapter<CardNetwork> {
  @override
  final int typeId = 1;

  @override
  CardNetwork read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CardNetwork.visa;
      case 1:
        return CardNetwork.mastercard;
      case 2:
        return CardNetwork.amex;
      case 3:
        return CardNetwork.discover;
      case 4:
        return CardNetwork.rupay;
      case 5:
        return CardNetwork.other;
      default:
        return CardNetwork.visa;
    }
  }

  @override
  void write(BinaryWriter writer, CardNetwork obj) {
    switch (obj) {
      case CardNetwork.visa:
        writer.writeByte(0);
        break;
      case CardNetwork.mastercard:
        writer.writeByte(1);
        break;
      case CardNetwork.amex:
        writer.writeByte(2);
        break;
      case CardNetwork.discover:
        writer.writeByte(3);
        break;
      case CardNetwork.rupay:
        writer.writeByte(4);
        break;
      case CardNetwork.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardNetworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

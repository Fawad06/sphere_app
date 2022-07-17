// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppCardModelAdapter extends TypeAdapter<AppCardModel> {
  @override
  final int typeId = 0;

  @override
  AppCardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppCardModel(
      title: fields[0] as String,
      assetIcon: fields[1] as String?,
      fileIcon: fields[2] as String?,
      timeUsedMinutes: fields[3] as int,
      backgroundImage: fields[5] as String?,
      webUrl: fields[7] as String?,
      isDeleteAble: fields[8] as bool,
      gradientColors: (fields[4] as List).cast<Color>(),
      screenRouteNamed: fields[6] as String?,
    )..lastUsed = fields[9] as DateTime;
  }

  @override
  void write(BinaryWriter writer, AppCardModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.assetIcon)
      ..writeByte(2)
      ..write(obj.fileIcon)
      ..writeByte(3)
      ..write(obj.timeUsedMinutes)
      ..writeByte(4)
      ..write(obj.gradientColors)
      ..writeByte(5)
      ..write(obj.backgroundImage)
      ..writeByte(6)
      ..write(obj.screenRouteNamed)
      ..writeByte(7)
      ..write(obj.webUrl)
      ..writeByte(8)
      ..write(obj.isDeleteAble)
      ..writeByte(9)
      ..write(obj.lastUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

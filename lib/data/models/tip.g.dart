// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipAdapter extends TypeAdapter<Tip> {
  @override
  final int typeId = 4;

  @override
  Tip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tip(
      id: fields[0] as String,
      index: fields[1] as int,
      text: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Tip obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.index)
      ..writeByte(2)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

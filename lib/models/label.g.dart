// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LabelAdapter extends TypeAdapter<Label> {
  @override
  final int typeId = 1;

  @override
  Label read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Label(
      name: fields[0] as String,
      color: (fields[1] as num).toInt(),
      categoryId: (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Label obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.categoryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

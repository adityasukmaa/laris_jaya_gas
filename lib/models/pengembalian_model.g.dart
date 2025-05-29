// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengembalian_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pengembalian _$PengembalianFromJson(Map<String, dynamic> json) => Pengembalian(
      idPengembalian: json['idPengembalian'] as String,
      idPeminjaman: json['idPeminjaman'] as String,
      tanggalKembali: DateTime.parse(json['tanggalKembali'] as String),
      kondisiTabung: json['kondisiTabung'] as String,
      keterangan: json['keterangan'] as String,
    );

Map<String, dynamic> _$PengembalianToJson(Pengembalian instance) =>
    <String, dynamic>{
      'idPengembalian': instance.idPengembalian,
      'idPeminjaman': instance.idPeminjaman,
      'tanggalKembali': instance.tanggalKembali.toIso8601String(),
      'kondisiTabung': instance.kondisiTabung,
      'keterangan': instance.keterangan,
    };

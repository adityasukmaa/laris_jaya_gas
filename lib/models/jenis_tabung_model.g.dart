// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jenis_tabung_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JenisTabung _$JenisTabungFromJson(Map<String, dynamic> json) => JenisTabung(
      idJenisTabung: json['idJenisTabung'] as String,
      kodeJenis: json['kodeJenis'] as String,
      namaJenis: json['namaJenis'] as String,
      harga: (json['harga'] as num).toDouble(),
    );

Map<String, dynamic> _$JenisTabungToJson(JenisTabung instance) =>
    <String, dynamic>{
      'idJenisTabung': instance.idJenisTabung,
      'kodeJenis': instance.kodeJenis,
      'namaJenis': instance.namaJenis,
      'harga': instance.harga,
    };

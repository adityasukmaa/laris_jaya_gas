// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perorangan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Perorangan _$PeroranganFromJson(Map<String, dynamic> json) => Perorangan(
      idPerorangan: json['idPerorangan'] as String,
      namaLengkap: json['namaLengkap'] as String,
      nik: json['nik'] as String,
      noTelepon: json['noTelepon'] as String,
      alamat: json['alamat'] as String,
      idPerusahaan: json['idPerusahaan'] as String?,
    );

Map<String, dynamic> _$PeroranganToJson(Perorangan instance) =>
    <String, dynamic>{
      'idPerorangan': instance.idPerorangan,
      'namaLengkap': instance.namaLengkap,
      'nik': instance.nik,
      'noTelepon': instance.noTelepon,
      'alamat': instance.alamat,
      'idPerusahaan': instance.idPerusahaan,
    };

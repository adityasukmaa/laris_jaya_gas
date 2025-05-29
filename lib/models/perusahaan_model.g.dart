// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perusahaan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Perusahaan _$PerusahaanFromJson(Map<String, dynamic> json) => Perusahaan(
      idPerusahaan: json['idPerusahaan'] as String,
      namaPerusahaan: json['namaPerusahaan'] as String,
      alamatPerusahaan: json['alamatPerusahaan'] as String,
      emailPerusahaan: json['emailPerusahaan'] as String,
    );

Map<String, dynamic> _$PerusahaanToJson(Perusahaan instance) =>
    <String, dynamic>{
      'idPerusahaan': instance.idPerusahaan,
      'namaPerusahaan': instance.namaPerusahaan,
      'alamatPerusahaan': instance.alamatPerusahaan,
      'emailPerusahaan': instance.emailPerusahaan,
    };

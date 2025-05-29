// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peminjaman_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Peminjaman _$PeminjamanFromJson(Map<String, dynamic> json) => Peminjaman(
      idPeminjaman: json['idPeminjaman'] as String,
      idDetailTransaksi: json['idDetailTransaksi'] as String,
      tanggalPinjam: DateTime.parse(json['tanggalPinjam'] as String),
      statusPinjam: json['statusPinjam'] as String,
    );

Map<String, dynamic> _$PeminjamanToJson(Peminjaman instance) =>
    <String, dynamic>{
      'idPeminjaman': instance.idPeminjaman,
      'idDetailTransaksi': instance.idDetailTransaksi,
      'tanggalPinjam': instance.tanggalPinjam.toIso8601String(),
      'statusPinjam': instance.statusPinjam,
    };

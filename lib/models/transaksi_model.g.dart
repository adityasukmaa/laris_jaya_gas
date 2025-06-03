// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaksi _$TransaksiFromJson(Map<String, dynamic> json) => Transaksi(
      idTransaksi: json['idTransaksi'] as String,
      idAkun: json['idAkun'] as String?,
      idPerorangan: json['idPerorangan'] as String?,
      idPerusahaan: json['idPerusahaan'] as String?,
      tanggalTransaksi: DateTime.parse(json['tanggalTransaksi'] as String),
      waktuTransaksi: json['waktuTransaksi'] as String,
      jumlahDibayar: (json['jumlahDibayar'] as num).toDouble(),
      metodePembayaran: json['metodePembayaran'] as String,
      idStatusTransaksi: json['idStatusTransaksi'] as String,
      tanggalJatuhTempo: json['tanggalJatuhTempo'] == null
          ? null
          : DateTime.parse(json['tanggalJatuhTempo'] as String),
      detailTransaksis: (json['detailTransaksis'] as List<dynamic>?)
          ?.map((e) => DetailTransaksi.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TransaksiToJson(Transaksi instance) => <String, dynamic>{
      'idTransaksi': instance.idTransaksi,
      'idAkun': instance.idAkun,
      'idPerorangan': instance.idPerorangan,
      'idPerusahaan': instance.idPerusahaan,
      'tanggalTransaksi': instance.tanggalTransaksi.toIso8601String(),
      'waktuTransaksi': instance.waktuTransaksi,
      'jumlahDibayar': instance.jumlahDibayar,
      'metodePembayaran': instance.metodePembayaran,
      'idStatusTransaksi': instance.idStatusTransaksi,
      'tanggalJatuhTempo': instance.tanggalJatuhTempo?.toIso8601String(),
      'detailTransaksis': instance.detailTransaksis,
    };

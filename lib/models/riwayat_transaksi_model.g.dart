// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riwayat_transaksi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RiwayatTransaksi _$RiwayatTransaksiFromJson(Map<String, dynamic> json) =>
    RiwayatTransaksi(
      idRiwayatTransaksi: json['idRiwayatTransaksi'] as String,
      idTransaksi: json['idTransaksi'] as String,
      idAkun: json['idAkun'] as String,
      idPerorangan: json['idPerorangan'] as String,
      idPerusahaan: json['idPerusahaan'] as String,
      tanggalTransaksi: DateTime.parse(json['tanggalTransaksi'] as String),
      totalTransaksi: (json['totalTransaksi'] as num).toDouble(),
      jumlahDibayar: (json['jumlahDibayar'] as num).toDouble(),
      metodePembayaran: json['metodePembayaran'] as String,
      tanggalJatuhTempo: json['tanggalJatuhTempo'] == null
          ? null
          : DateTime.parse(json['tanggalJatuhTempo'] as String),
      tanggalSelesai: DateTime.parse(json['tanggalSelesai'] as String),
      statusAkhir: json['statusAkhir'] as String? ?? 'success',
      totalPembayaran: (json['totalPembayaran'] as num).toDouble(),
      denda: (json['denda'] as num).toDouble(),
      durasiPeminjaman: (json['durasiPeminjaman'] as num?)?.toInt(),
      keterangan: json['keterangan'] as String,
    );

Map<String, dynamic> _$RiwayatTransaksiToJson(RiwayatTransaksi instance) =>
    <String, dynamic>{
      'idRiwayatTransaksi': instance.idRiwayatTransaksi,
      'idTransaksi': instance.idTransaksi,
      'idAkun': instance.idAkun,
      'idPerorangan': instance.idPerorangan,
      'idPerusahaan': instance.idPerusahaan,
      'tanggalTransaksi': instance.tanggalTransaksi.toIso8601String(),
      'totalTransaksi': instance.totalTransaksi,
      'jumlahDibayar': instance.jumlahDibayar,
      'metodePembayaran': instance.metodePembayaran,
      'tanggalJatuhTempo': instance.tanggalJatuhTempo?.toIso8601String(),
      'tanggalSelesai': instance.tanggalSelesai.toIso8601String(),
      'statusAkhir': instance.statusAkhir,
      'totalPembayaran': instance.totalPembayaran,
      'denda': instance.denda,
      'durasiPeminjaman': instance.durasiPeminjaman,
      'keterangan': instance.keterangan,
    };

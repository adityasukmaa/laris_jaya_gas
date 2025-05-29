  import 'package:json_annotation/json_annotation.dart';
  import 'package:laris_jaya_gas/models/jenis_transaksi_model.dart';
  import 'package:laris_jaya_gas/models/tabung_model.dart';

  part 'detail_transaksi_model.g.dart';

  @JsonSerializable()
  class DetailTransaksi {
    final String idDetailTransaksi;
    final String idTransaksi;
    final String idTabung;
    final String idJenisTransaksi;
    final double harga;
    final double totalTransaksi;
    final DateTime? batasWaktuPeminjaman;
    @JsonKey(includeFromJson: false, includeToJson: false)
    Tabung? tabung;
    @JsonKey(includeFromJson: false, includeToJson: false)
    JenisTransaksi? jenisTransaksi;

    DetailTransaksi({
      required this.idDetailTransaksi,
      required this.idTransaksi,
      required this.idTabung,
      required this.idJenisTransaksi,
      required this.harga,
      required this.totalTransaksi,
      this.batasWaktuPeminjaman,
      this.tabung,
      this.jenisTransaksi,
    });

    factory DetailTransaksi.fromJson(Map<String, dynamic> json) =>
        _$DetailTransaksiFromJson(json);
    Map<String, dynamic> toJson() => _$DetailTransaksiToJson(this);
  }
// This code defines a DetailTransaksi model class that represents the details of a transaction in a gas management system.
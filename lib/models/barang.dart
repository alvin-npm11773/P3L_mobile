class Barang {
  final String namaBarang;
  final double hargaJual;
  final String status;
  final List<BarangImage> barangImages;
  final String garansi;
  final int lamaPemakaian;

  Barang({
    required this.namaBarang,
    required this.hargaJual,
    required this.status,
    required this.barangImages,
    required this.garansi,
    required this.lamaPemakaian,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    var list = json['barang_images'] as List;
    List<BarangImage> imagesList =
        list.map((i) => BarangImage.fromJson(i)).toList();

    return Barang(
      namaBarang: json['nama_barang'],
      hargaJual: (json['harga_jual'] as num).toDouble(),
      status: json['status'],
      barangImages: imagesList,
      garansi: json['garansi'] ?? '-',
      lamaPemakaian: json['lama_pemakaian'] ?? 0,
    );
  }
}

class BarangImage {
  final String gambar;

  BarangImage({required this.gambar});

  factory BarangImage.fromJson(Map<String, dynamic> json) {
    return BarangImage(
      gambar: json['gambar'],
    );
  }
}

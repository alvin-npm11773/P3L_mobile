class Merchandise {
  final int id;
  final String namaMerchandise;
  final int stokMerchandise;
  final int harga;
  final String gambar;

  Merchandise({
    required this.id,
    required this.namaMerchandise,
    required this.stokMerchandise,
    required this.harga,
    required this.gambar,
  });

  factory Merchandise.fromJson(Map<String, dynamic> json) {
    return Merchandise(
      id: json['id'],
      namaMerchandise: json['nama_merchandise'],
      stokMerchandise: json['stok_merchandise'],
      harga: json['harga'],
      gambar: json['gambar'],
    );
  }
}

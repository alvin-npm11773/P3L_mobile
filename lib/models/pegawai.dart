class Pegawai {
  final int id;
  final String namaPegawai;
  final String email;
  final String tanggalLahir;
  final String role;
  final int? komisi;

  Pegawai({
    required this.id,
    required this.namaPegawai,
    required this.email,
    required this.tanggalLahir,
    required this.role,
    this.komisi,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    return Pegawai(
      id: json['id'],
      namaPegawai: json['nama_pegawai'],
      email: json['email'],
      tanggalLahir: json['tanggal_lahir'],
      role: json['role'],
      komisi: json['komisi'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama_pegawai': namaPegawai,
        'email': email,
        'tanggal_lahir': tanggalLahir,
        'role': role,
        'komisi': komisi,
      };
}

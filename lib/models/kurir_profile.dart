class KurirProfile {
  final int id;
  final String namaPegawai;
  final String email;
  final String tanggalLahir;
  final String role;

  KurirProfile({
    required this.id,
    required this.namaPegawai,
    required this.email,
    required this.tanggalLahir,
    required this.role,
  });

  factory KurirProfile.fromJson(Map<String, dynamic> json) {
    return KurirProfile(
      id: json['id'],
      namaPegawai: json['nama_pegawai'],
      email: json['email'],
      tanggalLahir: json['tanggal_lahir'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama_pegawai': namaPegawai,
        'email': email,
        'tanggal_lahir': tanggalLahir,
        'role': role,
      };
}

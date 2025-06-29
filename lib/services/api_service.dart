import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Pastikan baseUrl ini adalah alamat IP atau domain server Laravel Anda
  // Jika menggunakan emulator Android, '10.0.2.2' adalah alias untuk localhost di mesin development Anda.
  // Jika menggunakan perangkat fisik, gunakan IP lokal mesin development Anda (misal: '192.168.1.XX:8000')
  static const baseUrl = 'http://10.0.2.2:8000/api';
  static String? _authToken; // Variabel statis di memori
  static String? _userRole; // Tambahkan variabel untuk menyimpan peran pengguna

  // Fungsi untuk mendapatkan token yang tersimpan
  static Future<String?> getToken() async {
    print('ApiService: Mengambil token...');
    if (_authToken != null) {
      print(
        'ApiService: Token ditemukan di memori: ${_authToken!.substring(0, 10)}...',
      ); // Print sebagian untuk keamanan
      return _authToken;
    }
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    print(
      'ApiService: Token diambil dari SharedPreferences: ${_authToken != null ? _authToken!.substring(0, 10) + '...' : 'null'}',
    );
    return _authToken;
  }

  // Fungsi untuk mendapatkan peran pengguna yang tersimpan
  static Future<String?> getUserRole() async {
    print('ApiService: Mengambil peran pengguna...');
    if (_userRole != null) {
      print('ApiService: Peran pengguna ditemukan di memori: $_userRole');
      return _userRole;
    }
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('user_role');
    print(
      'ApiService: Peran pengguna diambil dari SharedPreferences: ${_userRole ?? 'null'}',
    );
    return _userRole;
  }

  // Fungsi untuk menyimpan token dan peran
  static Future<void> saveAuthData(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_role', role);
    _authToken = token;
    _userRole = role;
    print(
      'ApiService: Token (${token.substring(0, 10)}...) dan Peran ($role) berhasil disimpan ke SharedPreferences.',
    );
  }

  // Fungsi untuk menghapus token dan data pengguna (misal saat logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id'); // Hapus user_id
    await prefs.remove('user_poin');
    await prefs.remove('user_role'); // Hapus peran juga
    _authToken = null;
    _userRole = null;
    print('ApiService: Token dan user data dihapus.');
  }

  /// Melakukan login penitip dan mengembalikan data (termasuk token).
  /// Mengembalikan null jika login gagal (agar tidak langsung throw exception).
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/penitip/login');
    print('ApiService: Mencoba login Penitip ke $url dengan email: $email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('ApiService: Login Penitip Status Code: ${response.statusCode}');
      print('ApiService: Login Penitip Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final String receivedToken = responseData['token'];
          final int userId = responseData['data']['id']; // ID Penitip
          final int userPoints =
              responseData['data']['poin'] ??
              0; // Sesuaikan jika penitip punya poin

          await saveAuthData(receivedToken, 'penitip');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userId); // Simpan ID Penitip
          await prefs.setInt('user_poin', userPoints);
          print(
            'ApiService: User ID (Penitip) saved: $userId, Poin saved: $userPoints',
          );

          return responseData;
        }
      }
      return null;
    } catch (e) {
      print('ApiService: Error saat login Penitip: $e');
      return null;
    }
  }

  /// Melakukan login pembeli dan mengembalikan data (termasuk token).
  /// Mengembalikan null jika login gagal (agar tidak langsung throw exception).
  static Future<Map<String, dynamic>?> loginPembeli(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/pembeli/login'); // Endpoint untuk pembeli
    print('ApiService: Mencoba login Pembeli ke $url dengan email: $email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('ApiService: Login Pembeli Status Code: ${response.statusCode}');
      print('ApiService: Login Pembeli Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final String receivedToken = responseData['token'];
          final int userId = responseData['data']['id']; // ID Pembeli
          final int userPoints =
              responseData['data']['poin'] ??
              0; // Pastikan ini sesuai dengan nama field di API

          await saveAuthData(receivedToken, 'pembeli');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(
            'user_id',
            userId,
          ); // <--- ID PEMBELI DISIMPAN DI SINI
          await prefs.setInt('user_poin', userPoints);
          print(
            'ApiService: User ID (Pembeli) saved: $userId, Poin saved: $userPoints',
          );

          return responseData;
        }
      }
      return null;
    } catch (e) {
      print('ApiService: Error saat login Pembeli: $e');
      return null;
    }
  }

  /// Mendapatkan data profil pembeli.
  /// Membutuhkan token autentikasi.
  static Future<Map<String, dynamic>> getPembeliProfile() async {
    print('ApiService: [getPembeliProfile] - Memulai.');
    final token = await getToken();
    if (token == null) {
      print(
        'ApiService: [getPembeliProfile] - Token NULL, melempar Exception.',
      );
      throw Exception(
        'Token otentikasi tidak tersedia. Silakan login kembali.',
      );
    }
    print(
      'ApiService: [getPembeliProfile] - Token berhasil diambil, panjang: ${token.length}',
    );

    // Dapatkan ID pembeli dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id'); // Ambil ID yang sudah disimpan

    if (userId == null) {
      print(
        'ApiService: [getPembeliProfile] - User ID NULL, melempar Exception.',
      );
      throw Exception('ID pengguna tidak ditemukan. Silakan login kembali.');
    }

    // Bangun URL dengan ID pembeli yang sebenarnya
    final url = Uri.parse(
      '$baseUrl/pembeli/$userId',
    ); // <--- PERBAIKAN UTAMA DI SINI
    print(
      'ApiService: [getPembeliProfile] - Mengirim request ke $url untuk profil pembeli',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(
        'ApiService: [getPembeliProfile] - Status Code: ${response.statusCode}',
      );
      print(
        'ApiService: [getPembeliProfile] - Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Pastikan struktur respons API Anda untuk /pembeli/{id} mengembalikan
        // data profil dalam kunci 'data' dan status 'success': true.
        // Contoh respons API:
        // {
        //   "success": true,
        //   "message": "Profil berhasil diambil",
        //   "data": {
        //     "id": 1,
        //     "nama_pembeli": "John Doe",
        //     "email": "john.doe@example.com",
        //     "poin": 150,
        //     // ... data lainnya
        //   }
        // }
        if (responseData['success'] == true && responseData['data'] != null) {
          print(
            'ApiService: [getPembeliProfile] - Data profil berhasil diurai.',
          );
          return responseData['data']; // Mengembalikan hanya bagian 'data'
        } else {
          print(
            'ApiService: [getPembeliProfile] - API response success: ${responseData['success']}, data: ${responseData['data'] != null ? 'not null' : 'null'}',
          );
          throw Exception(
            'Gagal memuat profil pembeli: ${responseData['message'] ?? 'Data tidak ditemukan atau sukses: false'}',
          );
        }
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService: [getPembeliProfile] - API error body: $errorBody');
        throw Exception(
          'Gagal memuat profil pembeli: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('ApiService: [getPembeliProfile] - Error: $e');
      rethrow;
    }
  }

  /// Mendapatkan data penitipan yang H-3, menggunakan token dari login
  static Future<List<dynamic>> getPenitipanHMinus3() async {
    print('ApiService: Memanggil getPenitipanHMinus3...');
    final token = await getToken();
    if (token == null) {
      print(
        'ApiService: getPenitipanHMinus3 - Token NULL, melempar Exception.',
      );
      throw Exception(
        'Token otentikasi tidak tersedia. Silakan login kembali.',
      );
    }

    final url = Uri.parse('$baseUrl/penitipan-hminus3');
    print('ApiService: Mengirim request ke $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(
        'ApiService: getPenitipanHMinus3 Status Code: ${response.statusCode}',
      );
      print(
        'ApiService: getPenitipanHMinus3 Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}',
      ); // Potong body jika terlalu panjang

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        } else {
          throw Exception(
            'Gagal mengambil data penitipan: ${responseData['message'] ?? 'Respons tidak sukses'}',
          );
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          'Gagal mengambil data penitipan: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('ApiService: Error saat getPenitipanHMinus3: $e');
      rethrow;
    }
  }

  /// Mendapatkan data penitipan berdasarkan rentang tanggal penitipan.
  static Future<List<dynamic>> getPenitipanByTanggalTitip(
    String startDate,
    String endDate,
  ) async {
    print('ApiService: Memanggil getPenitipanByTanggalTitip...');
    final token = await getToken();
    if (token == null) {
      print(
        'ApiService: getPenitipanByTanggalTitip - Token NULL, melempar Exception.',
      );
      throw Exception(
        'Token otentikasi tidak tersedia. Silakan login kembali.',
      );
    }

    final url = Uri.parse(
      '$baseUrl/penitipan-by-date?start_date=$startDate&end_date=$endDate',
    );
    print('ApiService: Mengirim request ke $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(
        'ApiService: getPenitipanByTanggalTitip Status Code: ${response.statusCode}',
      );
      print(
        'ApiService: getPenitipanByTanggalTitip Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        } else {
          throw Exception(
            'Gagal mengambil data penitipan berdasarkan tanggal: ${responseData['message'] ?? 'Respons tidak sukses'}',
          );
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          'Gagal mengambil data penitipan berdasarkan tanggal: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('ApiService: Error saat getPenitipanByTanggalTitip: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updatePembeliProfile(
    String newNamaPembeli,
    String newEmail, {
    String? newPassword, // Password bersifat opsional
  }) async {
    print('ApiService: [updatePembeliProfile] - Memulai proses update profil.');
    final token = await getToken();
    if (token == null) {
      print(
        'ApiService: [updatePembeliProfile] - Token NULL, melempar Exception.',
      );
      throw Exception(
        'Token otentikasi tidak tersedia. Silakan login kembali.',
      );
    }
    print(
      'ApiService: [updatePembeliProfile] - Token berhasil diambil, panjang: ${token.length}',
    );

    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {
      print(
        'ApiService: [updatePembeliProfile] - User ID NULL, melempar Exception.',
      );
      throw Exception('ID pengguna tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse(
      '$baseUrl/pembeli/$userId',
    ); // Endpoint PUT/POST dengan ID
    print(
      'ApiService: [updatePembeliProfile] - Mengirim request ke $url untuk update profil pembeli',
    );

    Map<String, dynamic> body = {
      'nama_pembeli': newNamaPembeli,
      'email': newEmail,
    };
    if (newPassword != null && newPassword.isNotEmpty) {
      body['password'] = newPassword;
    }

    print(
      'ApiService: [updatePembeliProfile] - Body request: ${json.encode(body)}',
    );

    try {
      final response = await http.put(
        // Menggunakan PUT untuk update
        // Atau gunakan http.post jika rute Laravel Anda didefinisikan sebagai POST:
        // final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      print(
        'ApiService: [updatePembeliProfile] - Status Code: ${response.statusCode}',
      );
      print(
        'ApiService: [updatePembeliProfile] - Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print(
            'ApiService: [updatePembeliProfile] - Profil berhasil diupdate.',
          );
          return responseData['data']; // Mengembalikan data yang diupdate (opsional)
        } else {
          print(
            'ApiService: [updatePembeliProfile] - API response success: ${responseData['success']}, message: ${responseData['message']}',
          );
          throw Exception(
            'Gagal memperbarui profil: ${responseData['message'] ?? 'Respons tidak sukses'}',
          );
        }
      } else if (response.statusCode == 422) {
        // Validasi gagal dari Laravel
        final errorBody = json.decode(response.body);
        print(
          'ApiService: [updatePembeliProfile] - Validasi gagal: $errorBody',
        );
        throw Exception(
          'Kesalahan validasi: ${errorBody['errors'] ?? 'Input tidak valid'}',
        );
      } else {
        final errorBody = json.decode(response.body);
        print(
          'ApiService: [updatePembeliProfile] - API error body: $errorBody',
        );
        throw Exception(
          'Gagal memperbarui profil: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('ApiService: [updatePembeliProfile] - Error: $e');
      rethrow; // Melempar error agar ditangkap oleh widget
    }
  }

  /// **Fungsi BARU: Mendapatkan riwayat transaksi pembeli**
  static Future<List<dynamic>> getPembeliTransactionHistory({
    String? status,
    String? tanggalMulai,
    String? tanggalSelesai,
  }) async {
    print('ApiService: [getPembeliTransactionHistory] - Memulai.');
    final token = await getToken();
    if (token == null) {
      print(
        'ApiService: [getPembeliTransactionHistory] - Token NULL, melempar Exception.',
      );
      throw Exception(
        'Token otentikasi tidak tersedia. Silakan login kembali.',
      );
    }

    final Map<String, String> queryParams = {};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (tanggalMulai != null && tanggalMulai.isNotEmpty) {
      queryParams['tanggal_mulai'] = tanggalMulai;
    }
    if (tanggalSelesai != null && tanggalSelesai.isNotEmpty) {
      queryParams['tanggal_selesai'] = tanggalSelesai;
    }

    Uri uri = Uri.parse(
      '$baseUrl/transaksi/history',
    ).replace(queryParameters: queryParams);
    print(
      'ApiService: [getPembeliTransactionHistory] - Mengirim request ke $uri',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(
        'ApiService: [getPembeliTransactionHistory] - Status Code: ${response.statusCode}',
      );
      print(
        'ApiService: [getPembeliTransactionHistory] - Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          print(
            'ApiService: [getPembeliTransactionHistory] - Data transaksi berhasil diurai.',
          );
          return responseData['data'];
        } else {
          print(
            'ApiService: [getPembeliTransactionHistory] - API response success: ${responseData['success']}, data: ${responseData['data'] != null ? 'not null' : 'null'}',
          );
          throw Exception(
            'Gagal memuat riwayat transaksi: ${responseData['message'] ?? 'Respons tidak sukses'}',
          );
        }
      } else {
        final errorBody = json.decode(response.body);
        print(
          'ApiService: [getPembeliTransactionHistory] - API error body: $errorBody',
        );
        throw Exception(
          'Gagal memuat riwayat transaksi: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('ApiService: [getPembeliTransactionHistory] - Error: $e');
      rethrow;
    }
  }

  /// **Fungsi BARU: Mendapatkan detail transaksi berdasarkan ID**
  static Future<Map<String, dynamic>> getTransactionDetail(
    int transactionId,
  ) async {
    print(
      'ApiService: [getTransactionDetail] - Memulai untuk ID: $transactionId',
    );
    final token = await getToken();
    if (token == null) {
      print(
        'ApiService: [getTransactionDetail] - Token NULL, melempar Exception.',
      );
      throw Exception(
        'Token otentikasi tidak tersedia. Silakan login kembali.',
      );
    }

    final url = Uri.parse(
      '$baseUrl/transaksi/$transactionId',
    ); // Menggunakan endpoint show/{id}
    print('ApiService: [getTransactionDetail] - Mengirim request ke $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(
        'ApiService: [getTransactionDetail] - Status Code: ${response.statusCode}',
      );
      print(
        'ApiService: [getTransactionDetail] - Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          print(
            'ApiService: [getTransactionDetail] - Detail transaksi berhasil diurai.',
          );
          return responseData['data'];
        } else {
          print(
            'ApiService: [getTransactionDetail] - API response success: ${responseData['success']}, data: ${responseData['data'] != null ? 'not null' : 'null'}',
          );
          throw Exception(
            'Gagal memuat detail transaksi: ${responseData['message'] ?? 'Respons tidak sukses'}',
          );
        }
      } else {
        final errorBody = json.decode(response.body);
        print(
          'ApiService: [getTransactionDetail] - API error body: $errorBody',
        );
        throw Exception(
          'Gagal memuat detail transaksi: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('ApiService: [getTransactionDetail] - Error: $e');
      rethrow;
    }
  }
}

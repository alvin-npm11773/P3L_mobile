import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> saveTokenToBackend(
    String token, String role, String accessToken, int userId) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/api/fcm-token'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'fcm_token': token,
      'role': role,
      'user_id': userId,
    }),
  );

  if (response.statusCode == 200) {
    print("FCM token berhasil dikirim ke backend");
  } else {
    print("Gagal mengirim token: ${response.body}");
  }
}

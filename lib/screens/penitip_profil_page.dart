import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PenitipProfilPage extends StatefulWidget {
  @override
  _PenitipProfilPageState createState() => _PenitipProfilPageState();
}

class _PenitipProfilPageState extends State<PenitipProfilPage> {
  int _selectedIndex = 0;

  Map<String, dynamic>? profileData;

  String token = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchProfile();
  }

  Future<void> _loadTokenAndFetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');

    if (storedToken != null) {
      setState(() => token = 'Bearer $storedToken');
      fetchProfileData();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> fetchProfileData() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/penitip/profile'),
      headers: {'Authorization': token},
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() => profileData = result['data']);
    } else {
      print('Gagal memuat profil');
    }
  }

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/multilogout'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      Navigator.pushReplacementNamed(context, '/login');
    } else {
      print('Gagal logout');
    }
  }

  Widget buildProfilePage() {
    if (profileData == null) {
      return Center(child: CircularProgressIndicator());
    }

    print(jsonEncode(profileData));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nama Penitip: ${profileData!['nama_penitip']}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("Email: ${profileData!['email']}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("Komisi: ${profileData!['komisi'] ?? '0'}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 30),
          Expanded(child: Container()),
          Center(
            child: ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Log Out"),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [buildProfilePage()];

    return Scaffold(
      appBar: AppBar(title: Text("Penitip")),
      body: pages[_selectedIndex],
    );
  }
}

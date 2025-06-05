import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HunterPage extends StatefulWidget {
  @override
  _HunterPageState createState() => _HunterPageState();
}

class _HunterPageState extends State<HunterPage> {
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
      Uri.parse('http://10.0.2.2:8000/api/pegawai/profile'),
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
          Text("Nama Pegawai: ${profileData!['nama_pegawai']}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("Email: ${profileData!['email']}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text(
              "Tanggal Lahir: ${profileData!['tanggal_lahir'] ?? 'Tidak tersedia'}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("Nama Role: ${profileData!['role'] ?? 'Tidak ada role'}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("Komisi: ${profileData!['komisi'] ?? '0'}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Log Out"),
            ),
          )
        ],
      ),
    );
  }

  Widget buildHistoryPage() {
    return Center(child: Text("Halaman History"));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [buildProfilePage(), buildHistoryPage()];

    return Scaffold(
      appBar: AppBar(title: Text("Hunter")),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

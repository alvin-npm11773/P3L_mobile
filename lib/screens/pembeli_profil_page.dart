import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ReuseMart/models/merchandise.dart';
import 'package:ReuseMart/services/api_service.dart';
import 'detailMerch_page.dart';
import 'klaimMerch_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

String buildImageUrl(String path) {
  return 'http://10.0.2.2:8000/storage/$path';
}

class PembeliProfilPage extends StatefulWidget {
  @override
  _PembeliProfilPageState createState() => _PembeliProfilPageState();
}

class _PembeliProfilPageState extends State<PembeliProfilPage> {
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
      await fetchProfileData();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> fetchProfileData() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/pembeli/profile'),
      headers: {'Authorization': token},
    );

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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nama Pembeli: ${profileData!['nama_pembeli']}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("Email: ${profileData!['email']}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("Poin: ${profileData!['poin']}", style: TextStyle(fontSize: 18)),
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

  Widget buildMerchandisePage() {
    return FutureBuilder<List<Merchandise>>(
      future: fetchMerchandise(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Tidak ada merchandise tersedia'));
        }

        final merchandiseList = snapshot.data!;

        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: merchandiseList.length,
          itemBuilder: (context, index) {
            final merch = merchandiseList[index];
            return InkWell(
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailMerchandisePage(
                      merch: merch,
                      pembeliId: profileData!['id'],
                      poinUser: profileData!['poin'],
                    ),
                  ),
                );
                setState(() {});
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          buildImageUrl(merch.gambar),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            merch.namaMerchandise,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Poin: ${merch.harga}',
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Stok: ${merch.stokMerchandise}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [buildProfilePage(), buildMerchandisePage()];

    return Scaffold(
      appBar: AppBar(
        title: Text("Pembeli"),
        actions: _selectedIndex == 1
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KlaimMerchandisePage(
                              pembeliId: profileData!['id']),
                        ),
                      );
                      fetchProfileData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text("Sedang diklaim"),
                  ),
                ),
              ]
            : null,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard), label: 'Merchandise'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            fetchProfileData();
          }
        },
      ),
    );
  }
}

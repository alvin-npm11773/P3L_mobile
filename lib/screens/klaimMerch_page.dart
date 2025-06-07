import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KlaimMerchandisePage extends StatefulWidget {
  final int pembeliId;
  const KlaimMerchandisePage({required this.pembeliId});

  @override
  _KlaimMerchandisePageState createState() => _KlaimMerchandisePageState();
}

class _KlaimMerchandisePageState extends State<KlaimMerchandisePage> {
  List<dynamic> klaimList = [];
  bool isLoading = true;
  String token = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    if (storedToken != null) {
      token = 'Bearer $storedToken';
      fetchKlaimMerchandise();
    }
  }

  Future<void> fetchKlaimMerchandise() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:8000/api/klaim-merchandise/${widget.pembeliId}/pembeli'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        klaimList = result['data'];
        isLoading = false;
      });
    } else {
      print('Gagal fetch klaim merchandise');
      setState(() => isLoading = false);
    }
  }

  String buildImageUrl(String path) {
    return 'http://10.0.2.2:8000/storage/$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Sedang Diklaim")),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : klaimList.isEmpty
                ? Center(child: Text("Tidak ada klaim merchandise."))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: klaimList.length,
                    itemBuilder: (context, index) {
                      final klaim = klaimList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        margin: EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              klaim['gambar'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        buildImageUrl(klaim['gambar']),
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported),
                                    ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("ID Klaim: ${klaim['id']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 6),
                                    Text(
                                        "Nama Merchandise: ${klaim['nama_merchandise']}"),
                                    SizedBox(height: 6),
                                    Text("Status: ${klaim['status_klaim']}"),
                                    SizedBox(height: 6),
                                    Text(
                                        "Tanggal Klaim: ${klaim['tanggal_klaim'] ?? '-'}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ));
  }
}

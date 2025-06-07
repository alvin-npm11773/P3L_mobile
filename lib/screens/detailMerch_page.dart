import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/merchandise.dart';

class DetailMerchandisePage extends StatefulWidget {
  final Merchandise merch;
  final int pembeliId;
  final int poinUser;

  const DetailMerchandisePage({
    Key? key,
    required this.merch,
    required this.pembeliId,
    required this.poinUser,
  }) : super(key: key);

  @override
  _DetailMerchandisePageState createState() => _DetailMerchandisePageState();
}

class _DetailMerchandisePageState extends State<DetailMerchandisePage> {
  late int stok;
  late int poinUser;

  @override
  void initState() {
    super.initState();
    stok = widget.merch.stokMerchandise;
    poinUser = widget.poinUser;
  }

  String buildImageUrl(String path) {
    return 'http://10.0.2.2:8000/storage/$path';
  }

  void ambilMerchandise(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final authHeader = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    if (poinUser < widget.merch.harga) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Poin anda tidak mencukupi")),
      );
      return;
    }

    try {
      final klaimResponse = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/klaim-merchandise'),
        headers: authHeader,
        body: jsonEncode({
          'pembeli_id': widget.pembeliId,
          'merchandise_id': widget.merch.id,
          'status_klaim': 'Diklaim',
        }),
      );

      if (klaimResponse.statusCode != 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal klaim merchandise")),
        );
        return;
      }

      // Update poin
      await http.put(
        Uri.parse('http://10.0.2.2:8000/api/pembeli/${widget.pembeliId}/poin'),
        headers: authHeader,
        body: jsonEncode({
          'transaksi': 'Gunakan',
          'poin': widget.merch.harga,
        }),
      );

      // Update stok merchandise
      await http.put(
        Uri.parse(
            'http://10.0.2.2:8000/api/merchandise/${widget.merch.id}/stok'),
        headers: authHeader,
        body: jsonEncode({
          'stok_merchandise': -1,
        }),
      );

      // Update UI
      setState(() {
        stok -= 1;
        poinUser -= widget.merch.harga;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Merchandise berhasil diambil!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.merch.namaMerchandise),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              buildImageUrl(widget.merch.gambar),
              fit: BoxFit.contain,
              width: double.infinity,
              height: 250,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image, size: 100)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.merch.namaMerchandise,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Poin: ${widget.merch.harga}',
                    style: TextStyle(fontSize: 18, color: Colors.blue[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stok: $stok',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Poin Anda: $poinUser',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ambilMerchandise(context);
                      },
                      child: const Text('Ambil Merchandise'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

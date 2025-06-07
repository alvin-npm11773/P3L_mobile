import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/barang.dart';

class DetailBarangPage extends StatefulWidget {
  final Barang barang;

  const DetailBarangPage({Key? key, required this.barang}) : super(key: key);

  @override
  _DetailBarangPageState createState() => _DetailBarangPageState();
}

class _DetailBarangPageState extends State<DetailBarangPage> {
  int _currentIndex = 0;

  String buildImageUrl(String path) {
    return 'http://10.0.2.2:8000/storage/$path';
  }

  @override
  Widget build(BuildContext context) {
    final barang = widget.barang;

    return Scaffold(
      appBar: AppBar(
        title: Text(barang.namaBarang),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: barang.barangImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        buildImageUrl(barang.barangImages[index].gambar),
                        fit: BoxFit.contain,
                        width: double.infinity,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        barang.barangImages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == index ? 12 : 8,
                          height: _currentIndex == index ? 12 : 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.blue
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang.namaBarang,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Harga: Rp${NumberFormat("#,##0", "id_ID").format(barang.hargaJual)}',
                    style: TextStyle(fontSize: 18, color: Colors.green[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Garansi: ${barang.garansi}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lama Pemakaian: ${barang.lamaPemakaian} bulan',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
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

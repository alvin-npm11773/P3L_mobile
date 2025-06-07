import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ReuseMart/models/barang.dart';
import 'package:ReuseMart/screens/login_page.dart';
import 'package:ReuseMart/services/api_service.dart';
import 'detailBarang_page.dart';

String buildImageUrl(String path) {
  return 'http://10.0.2.2:8000/storage/$path';
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ReuseMart'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Barang>>(
        future: fetchBarang(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Tidak ada data tersedia'));
          }

          final barangList = snapshot.data!
              .where((barang) => barang.status == "Tersedia")
              .toList();

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: barangList.length,
            itemBuilder: (context, index) {
              final barang = barangList[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailBarangPage(barang: barang),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: PageView.builder(
                          itemCount: barang.barangImages?.length ?? 0,
                          itemBuilder: (context, imgIndex) {
                            final image = barang.barangImages?[imgIndex];
                            if (image == null) return SizedBox();

                            return Image.network(
                              buildImageUrl(image.gambar),
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              barang.namaBarang,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Rp${NumberFormat("#,##0", "id_ID").format(barang.hargaJual)}',
                              style: TextStyle(fontSize: 13),
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
      ),
    );
  }
}

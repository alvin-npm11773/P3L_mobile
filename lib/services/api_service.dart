import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ReuseMart/models/barang.dart';
import 'package:ReuseMart/models/merchandise.dart';

Future<List<Barang>> fetchBarang() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/barang'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)['data'];
    return jsonResponse.map((barang) => Barang.fromJson(barang)).toList();
  } else {
    throw Exception('Failed to load barang');
  }
}

Future<List<Merchandise>> fetchMerchandise(String token) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/api/merchandise'),
    headers: {
      'Authorization': token,
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)['data'];
    return jsonResponse
        .map((merchandise) => Merchandise.fromJson(merchandise))
        .toList();
  } else {
    throw Exception('Failed to load merchandise');
  }
}

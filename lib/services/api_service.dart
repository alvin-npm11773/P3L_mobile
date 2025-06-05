import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ReuseMart/models/barang.dart';

Future<List<Barang>> fetchBarang() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/barang'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)['data'];
    return jsonResponse.map((barang) => Barang.fromJson(barang)).toList();
  } else {
    throw Exception('Failed to load barang');
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/multilogin'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final data = jsonDecode(response.body);
      setState(() => _isLoading = false);

      if (response.statusCode == 200 && data['success']) {
        final redirect = data['redirect'];
        final token = data['token'];

        String role = _extractRoleFromRedirect(redirect);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', role);

        Navigator.pushReplacementNamed(context, redirect);
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Login gagal';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  String _extractRoleFromRedirect(String redirect) {
    if (redirect.contains('/role/penitip/penitip')) return 'penitip';
    if (redirect.contains('/role/organisasi')) return 'organisasi';
    if (redirect.contains('/role/pembeli/profil')) return 'pembeli';
    if (redirect.contains('/role/owner')) return 'owner';
    if (redirect.contains('/role/admin/admin')) return 'admin';
    if (redirect.contains('/role/gudang')) return 'gudang';
    if (redirect.contains('/role/cs')) return 'cs';
    if (redirect.contains('/role/hunter')) return 'hunter';
    return 'null';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}

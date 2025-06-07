import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/penitip_profil_page.dart';
import 'screens/pembeli_profil_page.dart';
import 'screens/hunter_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReuseMart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/role/penitip/penitip': (context) => PenitipProfilPage(),
        '/role/pembeli/profil': (context) => PembeliProfilPage(),
        '/role/hunter': (context) => HunterPage(),
      },
    );
  }
}

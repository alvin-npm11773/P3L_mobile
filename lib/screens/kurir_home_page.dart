import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/delivery.dart';
import '../models/kurir_profile.dart';
import 'login_page.dart';
import '../services/notification_service.dart';
import '../widgets/delivery_success_dialog.dart';

final NotificationService _notificationService = NotificationService();

class KurirHomePage extends StatefulWidget {
  const KurirHomePage({super.key});

  @override
  State<KurirHomePage> createState() => _KurirHomePageState();
}

class _KurirHomePageState extends State<KurirHomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  KurirProfile? _profile;
  List<Delivery> _deliveries = [];
  bool _isLoading = true;
  String? _token;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadToken();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      await _loadProfile();
      await _loadDeliveries();
    }
  }

  Future<void> _loadProfile() async {
    // Using dummy data for demo
    setState(() {
      _profile = KurirProfile(
        id: 1,
        namaPegawai: 'Ahmad Kurniawan',
        email: 'ahmad.kurir@reusemart.com',
        tanggalLahir: '1990-05-15',
        role: 'kurir',
      );
    });
  }

  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _deliveries = _getDummyDeliveries();
      _isLoading = false;
    });
  }

  List<Delivery> _getDummyDeliveries() {
    return [
      Delivery(
        id: '1',
        orderId: 'ORD001',
        recipientName: 'Budi Santoso',
        address: 'Jl. Malioboro No. 123, Yogyakarta',
        phone: '081234567890',
        status: 'Dalam Perjalanan',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Delivery(
        id: '2',
        orderId: 'ORD002',
        recipientName: 'Siti Aminah',
        address: 'Jl. Sudirman No. 456, Yogyakarta',
        phone: '081234567891',
        status: 'Menunggu',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Delivery(
        id: '3',
        orderId: 'ORD003',
        recipientName: 'Joko Widodo',
        address: 'Jl. Thamrin No. 789, Yogyakarta',
        phone: '081234567892',
        status: 'Selesai',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Delivery(
        id: '4',
        orderId: 'ORD004',
        recipientName: 'Dewi Sartika',
        address: 'Jl. Diponegoro No. 321, Yogyakarta',
        phone: '081234567893',
        status: 'Menunggu',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Delivery(
        id: '5',
        orderId: 'ORD005',
        recipientName: 'Rudi Hartono',
        address: 'Jl. Gajah Mada No. 654, Yogyakarta',
        phone: '081234567894',
        status: 'Dalam Perjalanan',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 7)),
      ),
    ];
  }

  Future<void> _updateDeliveryStatus(String deliveryId, String status) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      final index = _deliveries.indexWhere((d) => d.id == deliveryId);
      if (index != -1) {
        _deliveries[index] = Delivery(
          id: _deliveries[index].id,
          orderId: _deliveries[index].orderId,
          recipientName: _deliveries[index].recipientName,
          address: _deliveries[index].address,
          phone: _deliveries[index].phone,
          status: status,
          createdAt: _deliveries[index].createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Status pengiriman berhasil diperbarui!'),
          ],
        ),
        backgroundColor: const Color(0xFF6CB41C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Gagal logout'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6CB41C), Color(0xFFE8F5E8)],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildProfileTab(),
                    _buildDeliveryHistoryTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6CB41C),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history),
              label: 'Riwayat Pengiriman',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ReuseMart Kurir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Selamat datang kembali!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _signOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6CB41C), Color(0xFF8BC34A)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _profile?.namaPegawai ?? 'Ahmad Kurniawan',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6CB41C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Kurir Aktif',
              style: TextStyle(
                color: Color(0xFF6CB41C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileItem(Icons.email, 'Email', _profile?.email ?? 'ahmad.kurir@reusemart.com'),
          const SizedBox(height: 16),
          _buildProfileItem(Icons.badge, 'Role', 'Kurir'),
          const SizedBox(height: 16),
          _buildProfileItem(Icons.verified, 'Status', 'Aktif'),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6CB41C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6CB41C), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6CB41C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF6CB41C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Statistik Pengiriman',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Pengiriman',
                  _deliveries.length.toString(),
                  Icons.local_shipping,
                  const Color(0xFF6CB41C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Selesai',
                  _deliveries.where((d) => d.status == 'Selesai').length.toString(),
                  Icons.check_circle,
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Dalam Perjalanan',
                  _deliveries.where((d) => d.status == 'Dalam Perjalanan').length.toString(),
                  Icons.directions_car,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Menunggu',
                  _deliveries.where((d) => d.status == 'Menunggu').length.toString(),
                  Icons.schedule,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryHistoryTab() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6CB41C)),
            SizedBox(height: 16),
            Text('Memuat data pengiriman...'),
          ],
        ),
      );
    }

    if (_deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada tugas pengiriman',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF6CB41C),
      onRefresh: _loadDeliveries,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _deliveries.length,
        itemBuilder: (context, index) {
          final delivery = _deliveries[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${delivery.orderId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(delivery.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(delivery.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDeliveryInfo(Icons.person, 'Penerima', delivery.recipientName),
                  const SizedBox(height: 8),
                  _buildDeliveryInfo(Icons.location_on, 'Alamat', delivery.address),
                  const SizedBox(height: 8),
                  _buildDeliveryInfo(Icons.phone, 'Telepon', delivery.phone),
                  if (delivery.status != 'Selesai') ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _updateDeliveryStatus(delivery.id, 'Selesai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6CB41C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Tandai Selesai',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryInfo(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF6CB41C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: const Color(0xFF6CB41C), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'Selesai':
        color = const Color(0xFF6CB41C);
        icon = Icons.check_circle;
        break;
      case 'Dalam Perjalanan':
        color = const Color(0xFFFF9800);
        icon = Icons.directions_car;
        break;
      case 'Menunggu':
        color = const Color(0xFF9C27B0);
        icon = Icons.schedule;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
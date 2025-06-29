import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/delivery.dart';
import '../models/kurir_profile.dart';
import '../services/notification_service.dart';
// import '../widgets/delivery_success_dialog.dart';
import '../screens/login_page.dart';

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
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _notificationService.initialize();
    _loadToken();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
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
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      final index = _deliveries.indexWhere((d) => d.id == deliveryId);
      if (index != -1) {
        final updatedDelivery = Delivery(
          id: _deliveries[index].id,
          orderId: _deliveries[index].orderId,
          recipientName: _deliveries[index].recipientName,
          address: _deliveries[index].address,
          phone: _deliveries[index].phone,
          status: status,
          createdAt: _deliveries[index].createdAt,
          updatedAt: DateTime.now(),
        );
        
        _deliveries[index] = updatedDelivery;
        
        if (status == 'Selesai') {
          _showDeliveryCompletedNotification(updatedDelivery);
        }
      }
    });
  }

  void _showDeliveryCompletedNotification(Delivery delivery) {
    // Show in-app notification
    _notificationService.showDeliveryCompletedOverlay(context, delivery);
    
    // Show system notification
    _notificationService.showDeliveryCompletedNotification(
      title: 'Pengiriman Selesai!',
      body: 'Order #${delivery.orderId} telah berhasil diantar ke ${delivery.recipientName}',
      payload: delivery.id,
    );
    
    // Show success dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _DeliverySuccessDialog(
          delivery: delivery,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    });
  }

  Future<void> _signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [
              Color(0xFF6CB41C),
              Color(0xFF4A7C59),
              Color(0xFF2E5233),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FFF8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.delivery_dining, color: Color(0xFF6CB41C), size: 32),
                const SizedBox(width: 12),
                Text(
                  'Kurir ReuseMart',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5233),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF6CB41C)),
              onPressed: () {
                _loadDeliveries();
              },
              tooltip: 'Refresh Pengiriman',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Riwayat',
        ),
      ],
      selectedItemColor: Color(0xFF6CB41C),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  Widget _buildDeliveryHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_deliveries.isEmpty) {
      return const Center(child: Text('Tidak ada riwayat pengiriman.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deliveries.length,
      itemBuilder: (context, index) {
        final delivery = _deliveries[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
              delivery.status == 'Selesai'
                  ? Icons.check_circle
                  : Icons.local_shipping,
              color: delivery.status == 'Selesai'
                  ? Colors.green
                  : Colors.orange,
            ),
            title: Text('Order #${delivery.orderId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Penerima: ${delivery.recipientName}'),
                Text('Alamat: ${delivery.address}'),
                Text('Status: ${delivery.status}'),
              ],
            ),
            trailing: delivery.status != 'Selesai'
                ? ElevatedButton(
                    onPressed: () => _updateDeliveryStatus(delivery.id, 'Selesai'),
                    child: const Text('Selesaikan'),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    if (_profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFF6CB41C),
                child: Text(
                  _profile!.namaPegawai.isNotEmpty
                      ? _profile!.namaPegawai[0]
                      : '',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _profile!.namaPegawai,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E5233),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _profile!.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tanggal Lahir: ${_profile!.tanggalLahir}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Role: ${_profile!.role}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6CB41C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  }
  
  class _DeliverySuccessDialog extends StatelessWidget {
    final Delivery delivery;
    final VoidCallback onClose;
  
    const _DeliverySuccessDialog({
      Key? key,
      required this.delivery,
      required this.onClose,
    }) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Pengiriman Berhasil!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Order #${delivery.orderId} telah berhasil diantar ke ${delivery.recipientName}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onClose,
            child: const Text('Tutup'),
          ),
        ],
      );
    }
  }
  

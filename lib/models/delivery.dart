// models/delivery.dart
class Delivery {
  final String id;
  final String orderId;
  final String recipientName;
  final String address;
  final String phone;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Delivery({
    required this.id,
    required this.orderId,
    required this.recipientName,
    required this.address,
    required this.phone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      recipientName: json['recipient_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Menunggu', // Default value if null
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
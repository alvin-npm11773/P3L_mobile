import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/delivery.dart';

class DeliveryNotification extends StatefulWidget {
  final Delivery delivery;
  final VoidCallback onDismiss;

  const DeliveryNotification({
    Key? key,
    required this.delivery,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<DeliveryNotification> createState() => _DeliveryNotificationState();
}

class _DeliveryNotificationState extends State<DeliveryNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismissNotification();
      }
    });
  }

  void _dismissNotification() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _dismissNotification,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6CB41C), Color(0xFF8BC34A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6CB41C).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background particles
                      ...List.generate(10, (index) {
                        final random = math.Random(index);
                        final size = random.nextDouble() * 8 + 4;
                        final left = random.nextDouble() * MediaQuery.of(context).size.width * 0.8;
                        final top = random.nextDouble() * 120;
                        
                        return Positioned(
                          left: left,
                          top: top,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: 0.2 + (math.sin(_controller.value * math.pi * 2) + 1) / 2 * 0.2,
                                child: Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                      
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _rotateAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotateAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF6CB41C),
                                      size: 30,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pengiriman Selesai! 🎉',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Order #${widget.delivery.orderId} telah berhasil diantar ke ${widget.delivery.recipientName}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: const Text(
                                      'Ketuk untuk menutup',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Confetti animation
                      ...List.generate(20, (index) {
                        final random = math.Random(index);
                        final size = random.nextDouble() * 6 + 2;
                        final initialX = random.nextDouble() * MediaQuery.of(context).size.width * 0.8;
                        final initialY = random.nextDouble() * 120;
                        final color = [
                          Colors.white,
                          Colors.yellow,
                          Colors.green.shade200,
                          Colors.lightGreen.shade100,
                        ][random.nextInt(4)];
                        
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final animationProgress = _controller.value;
                            final fallDistance = 200.0 * animationProgress;
                            final horizontalMovement = math.sin(animationProgress * math.pi * 2) * 20;
                            
                            return Positioned(
                              left: initialX + horizontalMovement,
                              top: initialY + fallDistance,
                              child: Opacity(
                                opacity: animationProgress < 0.8 ? 1.0 : 1.0 - ((animationProgress - 0.8) * 5),
                                child: Transform.rotate(
                                  angle: animationProgress * math.pi * 4,
                                  child: Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
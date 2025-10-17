// lib/game/overlay/lucky_spin_overlay.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';

import '../../controllers/lucky_spin_controller.dart';

class LuckySpinOverlay extends StatelessWidget {
  final TiledGame game;

  const LuckySpinOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LuckySpinController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F3460),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background stars effect
          ...List.generate(50, (index) => _buildStar(index, size)),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isTablet ? 60 : 40),

                // Wheel container
                _buildWheelContainer(controller, isTablet),

                // Spin button
                _buildSpinButton(controller, isTablet),

                SizedBox(height: isTablet ? 20 : 15),
              ],
            ),
          ),

          // Top UI
          _buildTopUI(controller, isTablet, game),

          // Result popup
          Obx(() {
            if (!controller.showResultPopup.value) {
              return const SizedBox.shrink();
            }
            return _buildResultPopup(controller, isTablet, game);
          }),
        ],
      ),
    );
  }

  Widget _buildStar(int index, Size screenSize) {
    final random = Random(index);
    return Positioned(
      left: random.nextDouble() * screenSize.width,
      top: random.nextDouble() * screenSize.height,
      child: Icon(
        Icons.star,
        color: Colors.white.withOpacity(random.nextDouble() * 0.3),
        size: 2 + random.nextDouble() * 4,
      ),
    );
  }

  Widget _buildTopUI(LuckySpinController controller, bool isTablet, TiledGame game) {
    return SafeArea(
      child: Stack(
        children: [
          // Back button
          Positioned(
            top: isTablet ? 20 : 10,
            left: isTablet ? 20 : 10,
            child: GestureDetector(
              onTap: () {
                controller.dispose();
                Get.delete<LuckySpinController>();
                game.overlays.remove('lucky_spin');
                // Don't add minigames_overlay here - just go back to building popup
              },
              child: Container(
                padding: EdgeInsets.all(isTablet ? 12 : 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: isTablet ? 30 : 24,
                ),
              ),
            ),
          ),

          // Coins display
          Positioned(
            top: isTablet ? 20 : 10,
            right: isTablet ? 20 : 10,
            child: Obx(() => Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 15,
                vertical: isTablet ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/lucky_spin/coin.png',
                    width: isTablet ? 30 : 24,
                    height: isTablet ? 30 : 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.monetization_on,
                        color: Colors.orange,
                        size: isTablet ? 30 : 24,
                      );
                    },
                  ),
                  SizedBox(width: isTablet ? 10 : 8),
                  Text(
                    '${controller.playerCoins.value}',
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelContainer(LuckySpinController controller, bool isTablet) {
    final wheelSize = isTablet ? 320.0 : 260.0;

    return Container(
      width: wheelSize + 40,
      height: wheelSize + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wheel shadow
          Container(
            width: wheelSize + 20,
            height: wheelSize + 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Spinning wheel
          Obx(() => Transform.rotate(
            angle: controller.wheelRotation.value * (pi / 180),
            child: Container(
              width: wheelSize,
              height: wheelSize,
              child: Stack(
                children: [
                  // Wheel base image
                  Image.asset(
                    'assets/images/lucky_spin/wheel.png',
                    width: wheelSize,
                    height: wheelSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackWheel(controller, wheelSize);
                    },
                  ),

                  // Prize text overlay - FIXED POSITIONING
                  _buildPrizeTexts(controller, wheelSize),
                ],
              ),
            ),
          )),

          // Pointer (red triangle at top) - This stays fixed
          Positioned(
            top: 0,
            child: Image.asset(
              'assets/images/lucky_spin/wheel_point.png',
              width: isTablet ? 40 : 32,
              height: isTablet ? 50 : 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isTablet ? 40 : 32,
                  height: isTablet ? 50 : 40,
                  child: CustomPaint(
                    painter: TrianglePainter(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Prize text positioning to center in segments
  Widget _buildPrizeTexts(LuckySpinController controller, double size) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: List.generate(controller.prizes.length, (index) {
          // Fix the angle calculation to center text in segments
          // Start from top and add half segment offset to center in segments
          final segmentAngle = 360.0 / controller.prizes.length; // 45 degrees per segment
          final angle = (index * segmentAngle + segmentAngle / 2) * (pi / 180); // Center of each segment
          final radius = size * 0.32; // Slightly adjusted radius
          final x = size / 2 + radius * cos(angle - pi / 2);
          final y = size / 2 + radius * sin(angle - pi / 2);

          return Positioned(
            left: x - 40,
            top: y - 15,
            width: 80,
            height: 30,
            child: Transform.rotate(
              angle: angle,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  _getShortPrizeName(controller.prizes[index].name),
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: size > 280 ? 13 : 11, // Slightly larger for better visibility
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                      Shadow(
                        offset: const Offset(-1, -1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFallbackWheel(LuckySpinController controller, double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: WheelPainter(controller.prizes, controller),
    );
  }

  String _getShortPrizeName(String name) {
    switch (name) {
      case '100 Coins':
        return '100';
      case '50 Coins':
        return '50';
      case '25 Coins':
        return '25';
      case '10 Coins':
        return '10';
      case '5 Coins':
        return '5';
      case 'Try Tomorrow':
        return 'Try\nTomorrow';
      case 'Bonus Spin':
        return 'Bonus\nSpin';
      case 'Companion':
        return '⭐';
      default:
        return name;
    }
  }

  Widget _buildSpinButton(LuckySpinController controller, bool isTablet) {
    return Obx(() => GestureDetector(
      onTap: controller.isSpinning.value ? null : controller.spinWheel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isTablet ? 180 : 140,
        height: isTablet ? 60 : 50,
        decoration: BoxDecoration(
          gradient: controller.isSpinning.value
              ? LinearGradient(colors: [Colors.grey, Colors.grey.shade600])
              : const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: controller.isSpinning.value
              ? SizedBox(
            width: isTablet ? 30 : 24,
            height: isTablet ? 30 : 24,
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          )
              : Text(
            'SPIN',
            style: TextStyle(
              fontFamily: 'AkayaKanadaka',
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildResultPopup(LuckySpinController controller, bool isTablet, TiledGame game) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: isTablet ? 400 : 320,
          height: isTablet ? 350 : 280,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Celebration particles
              ...List.generate(10, (index) => _buildParticle(index)),

              // Content
              Padding(
                padding: EdgeInsets.all(isTablet ? 30 : 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Trophy/Star icon
                    Icon(
                      controller.lastWonPrize.value == 'Companion'
                          ? Icons.star
                          : Icons.emoji_events,
                      color: Colors.white,
                      size: isTablet ? 80 : 60,
                    ),

                    SizedBox(height: isTablet ? 20 : 15),

                    // Congratulations text
                    Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isTablet ? 15 : 10),

                    // Prize text
                    Text(
                      'You won: ${controller.lastWonPrize.value}',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 24 : 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isTablet ? 30 : 20),

                    // Continue button
                    GestureDetector(
                      onTap: () {
                        controller.resetSpin();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 40 : 30,
                          vertical: isTablet ? 15 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          controller.prizes[controller.selectedSegment].type == PrizeType.bonusSpin
                              ? 'Spin Again!'
                              : 'Continue',
                          style: TextStyle(
                            fontFamily: 'AkayaKanadaka',
                            fontSize: isTablet ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = Random(index);
    return Positioned(
      left: random.nextDouble() * 400,
      top: random.nextDouble() * 350,
      child: Icon(
        Icons.star,
        color: Colors.white.withOpacity(0.7),
        size: 4 + random.nextDouble() * 8,
      ),
    );
  }
}

// Custom painter for fallback wheel
class WheelPainter extends CustomPainter {
  final List<SpinPrize> prizes;
  final LuckySpinController controller;

  WheelPainter(this.prizes, this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final paint = Paint()
        ..color = controller.getPrizeColor(i)
        ..style = PaintingStyle.fill;

      final startAngle = i * segmentAngle - pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for triangle pointer
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
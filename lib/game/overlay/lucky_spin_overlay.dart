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
    final controller = Get.put(LuckySpinController(), permanent: true);
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Stack(
      children: [
        // Dim background
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.55)),
        ),

        // Main Card
        Center(
          child: Container(
            width: isTablet ? 520 : 400,
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2331),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopBar(controller, isTablet, context),

                SizedBox(height: isTablet ? 16 : 12),

                // Wheel area
                _buildWheelArea(controller, isTablet),

                SizedBox(height: isTablet ? 18 : 14),

                // Spin button
                Obx(() {
                  final spinning = controller.isSpinning.value;
                  return SizedBox(
                    width: double.infinity,
                    height: isTablet ? 54 : 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        spinning ? const Color(0xFF3C4154) : const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: spinning ? 0 : 3,
                      ),
                      onPressed: spinning ? null : controller.spinWheel,
                      child: Text(
                        spinning ? 'Spinning...' : 'SPIN',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: isTablet ? 18 : 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(height: isTablet ? 8 : 6),

                // Coins row (from controller)
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/lucky_spin/coin.png',
                        width: isTablet ? 26 : 20,
                        height: isTablet ? 26 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.playerCoins.value}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),

        // Result popup
        Obx(() => controller.showResultPopup.value
            ? _ResultPopup(
          onOk: () {
            controller.resetSpin();
          },
          title: 'Result',
          message: controller.lastWonPrize.value,
          amount: controller.lastWonAmount.value,
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildTopBar(LuckySpinController controller, bool isTablet, BuildContext context) {
    return Row(
      children: [
        Text(
          'Lucky Spin',
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Close',
          onPressed: () {
            // Close overlay
            game.overlays.remove('lucky_spin');
          },
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildWheelArea(LuckySpinController controller, bool isTablet) {
    final wheelSize = isTablet ? 320.0 : 260.0;

    return SizedBox(
      width: wheelSize,
      height: wheelSize + (isTablet ? 18 : 14), // extra for pointer image
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating wheel (image + labels drawn together)
          Obx(() => Transform.rotate(
            angle: controller.wheelRotation.value * (pi / 180),
            child: SizedBox(
              width: wheelSize,
              height: wheelSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Base wheel image (your asset)
                  Image.asset(
                    'assets/images/lucky_spin/wheel.png',
                    width: wheelSize,
                    height: wheelSize,
                    fit: BoxFit.contain,
                  ),
                  // Labels & slice dividers (keeps your design look)
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size(wheelSize, wheelSize),
                      painter: WheelPainter(controller.prizes, controller),
                    ),
                  ),
                ],
              ),
            ),
          )),

          // Fixed pointer at top (your asset)
          Positioned(
            top: 0,
            child: Image.asset(
              'assets/images/lucky_spin/wheel_point.png',
              width: isTablet ? 46 : 160,
              height: isTablet ? 46 : 160,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Painter: labels and subtle dividers over the wheel image ----------------

class WheelPainter extends CustomPainter {
  final List<SpinPrize> prizes;
  final LuckySpinController controller;

  WheelPainter(this.prizes, this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final n = prizes.length;
    final segmentAngle = 2 * pi / n;

    // Subtle dividers and labels
    final dividerPaint = Paint()
      ..color = Colors.white.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: size.width >= 300 ? 14 : 12,
      shadows: const [
        Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(0, 1)),
      ],
    );

    // Draw slice dividers (optional – aligns with your existing wheel art)
    for (int i = 0; i < n; i++) {
      final start = i * segmentAngle;
      final p1 = center;
      final p2 = Offset(
        center.dx + radius * cos(start - pi / 2),
        center.dy + radius * sin(start - pi / 2),
      );
      canvas.drawLine(p1, p2, dividerPaint);
    }

    // Draw labels at each slice center
    for (int i = 0; i < n; i++) {
      final centerAngle = i * segmentAngle + segmentAngle / 2;

      final labelRadius = radius * 0.63;
      final pos = Offset(
        center.dx + labelRadius * cos(centerAngle - pi / 2),
        center.dy + labelRadius * sin(centerAngle - pi / 2),
      );

      final tp = _makeLabel(_short(prizes[i].name), textStyle);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      // Keep labels upright-ish
      canvas.rotate(centerAngle);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  TextPainter _makeLabel(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textAlign: TextAlign.center,
    )..layout();
    return tp;
  }

  String _short(String name) {
    // Match your existing short labels:
    if (name.contains('Coins')) {
      // "100 Coins" -> "100"
      return name.split(' ').first;
    }
    if (name.toLowerCase().contains('spin')) return 'Spin Again';
    if (name.toLowerCase().contains('no reward') ||
        name.toLowerCase().contains('try')) return 'No Reward';
    if (name.toLowerCase().contains('companion')) return '1 Companion';
    return name;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------- Result Popup ----------------

class _ResultPopup extends StatelessWidget {
  final VoidCallback onOk;
  final String title;
  final String message;
  final int amount;

  const _ResultPopup({
    required this.onOk,
    required this.title,
    required this.message,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return Center(
      child: Container(
        width: isTablet ? 420 : 320,
        padding: EdgeInsets.all(isTablet ? 18 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFF272D3E),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 10),
            Text(
              message.isEmpty ? '—' : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (amount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/lucky_spin/coin.png',
                    width: isTablet ? 24 : 20,
                    height: isTablet ? 24 : 20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+$amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: isTablet ? 48 : 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                onPressed: onOk,
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

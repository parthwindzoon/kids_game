// lib/game/overlay/lucky_spin_overlay.dart

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:get_storage/get_storage.dart';

import '../../controllers/lucky_spin_controller.dart';
import '../../controllers/coin_controller.dart';
import '../../controllers/companion_controller.dart';

class LuckySpinOverlay extends StatefulWidget {
  final TiledGame game;

  const LuckySpinOverlay({super.key, required this.game});

  @override
  State<LuckySpinOverlay> createState() => _LuckySpinOverlayState();
}

class _LuckySpinOverlayState extends State<LuckySpinOverlay> {
  ui.Image? penguinImage;
  ui.Image? coinImage;

  @override
  void initState() {
    super.initState();
    _loadPenguinImage();
    _loadCoinImage();
  }

  Future<void> _loadPenguinImage() async {
    final data = await rootBundle.load('assets/images/companions/penguin.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        penguinImage = frame.image;
      });
    }
  }

  Future<void> _loadCoinImage() async {
    final data = await rootBundle.load('assets/images/lucky_spin/coin.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        coinImage = frame.image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final controller = Get.put(LuckySpinController(), permanent: true);
    final coinController = Get.find<CoinController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/home/background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF87CEEB),
                      const Color(0xFFA8E6CF),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Back Button (top-left)
        Positioned(
          top: isTablet ? 20 : 15,
          left: isTablet ? 20 : 15,
          child: GestureDetector(
            onTap: () {
              game.overlays.remove('lucky_spin');
              Get.delete<LuckySpinController>();
            },
            child: Image.asset(
              'assets/images/back_btn.png',
              width: isTablet ? 70 : 55,
              height: isTablet ? 70 : 55,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isTablet ? 70 : 55,
                  height: isTablet ? 70 : 55,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: isTablet ? 30 : 24,
                  ),
                );
              },
            ),
          ),
        ),

        // Coin Container (top-right) - Using coin.png as background
        Positioned(
          top: isTablet ? 20 : 15,
          right: isTablet ? 20 : 15,
          child: Obx(() => Container(
            width: isTablet ? 200 : 150,
            height: isTablet ? 70 : 55,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background coin image
                Image.asset(
                  'assets/images/home/coin.png',
                  width: isTablet ? 200 : 150,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    );
                  },
                ),
                // Coin count text
                Positioned(
                  right: isTablet ? 70 : 40,
                  bottom: isTablet ? 20 : 15,
                  child: Text(
                    '${coinController.coins.value}',
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ),

        // Main Wheel Area (centered)
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wheel
              _buildWheelArea(controller, isTablet),

              SizedBox(height: isTablet ? 30 : 20),

              // Spin button with gradient
              Obx(() {
                final spinning = controller.isSpinning.value;
                final canSpin = controller.canSpin.value;

                return GestureDetector(
                  onTap: (spinning || !canSpin) ? null : controller.spinWheel,
                  child: Container(
                    width: isTablet ? 200 : 160,
                    height: isTablet ? 60 : 50,
                    decoration: BoxDecoration(
                      gradient: (spinning || !canSpin)
                          ? LinearGradient(
                        colors: [
                          Colors.grey.shade400,
                          Colors.grey.shade600,
                        ],
                      )
                          : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFF9800), // Orange
                          Color(0xFFFFFFFF), // White
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        spinning
                            ? 'Spinning...'
                            : !canSpin
                            ? 'Spin Tomorrow'
                            : 'SPIN',
                        style: TextStyle(
                          fontFamily: 'AkayaKanadaka',
                          fontWeight: FontWeight.w800,
                          fontSize: isTablet ? 20 : 16,
                          letterSpacing: 1.2,
                          color: (spinning || !canSpin) ? Colors.white : Colors.black87,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
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
          prizeType: controller.lastWonPrizeType.value,
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildWheelArea(LuckySpinController controller, bool isTablet) {
    final wheelSize = isTablet ? 350.0 : 280.0;

    return SizedBox(
      width: wheelSize,
      height: wheelSize + (isTablet ? 20 : 15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating wheel
          Obx(() => Transform.rotate(
            angle: controller.wheelRotation.value * (pi / 180),
            child: SizedBox(
              width: wheelSize,
              height: wheelSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Base wheel image
                  Image.asset(
                    'assets/images/lucky_spin/wheel-1.png',
                    width: wheelSize,
                    height: wheelSize,
                    fit: BoxFit.contain,
                  ),
                  // Labels with icons
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size(wheelSize, wheelSize),
                      painter: WheelPainter(
                        controller.prizes,
                        controller,
                        isTablet,
                        penguinImage,
                        coinImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),

          // Fixed pointer at top
          Positioned(
            top: 0,
            child: Image.asset(
              'assets/images/lucky_spin/wheel_point.png',
              width: isTablet ? 200 : 160,
              height: isTablet ? 200 : 160,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// Painter: labels with icons
class WheelPainter extends CustomPainter {
  final List<SpinPrize> prizes;
  final LuckySpinController controller;
  final bool isTablet;
  final ui.Image? penguinImage;
  final ui.Image? coinImage;

  WheelPainter(
      this.prizes,
      this.controller,
      this.isTablet,
      this.penguinImage,
      this.coinImage,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final n = prizes.length;
    final segmentAngle = 2 * pi / n;

    // Draw labels at each slice center
    for (int i = 0; i < n; i++) {
      final centerAngle = i * segmentAngle + segmentAngle / 2;
      final labelRadius = radius * 0.63;
      final pos = Offset(
        center.dx + labelRadius * cos(centerAngle - pi / 2),
        center.dy + labelRadius * sin(centerAngle - pi / 2),
      );

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(centerAngle);

      _drawPrizeLabel(canvas, prizes[i], size);

      canvas.restore();
    }
  }

  void _drawPrizeLabel(Canvas canvas, SpinPrize prize, Size size) {
    if (prize.type == PrizeType.companion) {
      // Draw penguin icon for companion
      if (penguinImage != null) {
        final iconSize = isTablet ? 50.0 : 40.0;
        final srcRect = Rect.fromLTWH(
          0,
          0,
          penguinImage!.width.toDouble(),
          penguinImage!.height.toDouble(),
        );
        final dstRect = Rect.fromCenter(
          center: Offset.zero,
          width: iconSize,
          height: iconSize,
        );
        canvas.drawImageRect(penguinImage!, srcRect, dstRect, Paint());
      } else {
        // Fallback while image is loading
        final iconSize = isTablet ? 50.0 : 40.0;
        final paint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, iconSize / 2, paint);
      }
    } else if (prize.type == PrizeType.coins) {
      // Draw coin icon + amount for coins
      if (coinImage != null) {
        final iconSize = isTablet ? 30.0 : 24.0;

        // Calculate total width to center both coin and text together
        final textStyle = TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size.width >= 300 ? 16 : 14,
          shadows: const [
            Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(0, 1)),
          ],
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${prize.amount}',
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        final spacing = 5.0; // 5 pixels spacing between coin and text
        final totalWidth = iconSize + spacing + textPainter.width;
        final startX = -totalWidth / 2;

        // Draw coin image
        final srcRect = Rect.fromLTWH(
          0,
          0,
          coinImage!.width.toDouble(),
          coinImage!.height.toDouble(),
        );
        final dstRect = Rect.fromCenter(
          center: Offset(startX + iconSize / 2, 0),
          width: iconSize,
          height: iconSize,
        );
        canvas.drawImageRect(coinImage!, srcRect, dstRect, Paint());

        // Draw amount text
        textPainter.paint(
          canvas,
          Offset(startX + iconSize + spacing, -textPainter.height / 2),
        );
      } else {
        // Fallback if image not loaded yet
        final textStyle = TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size.width >= 300 ? 14 : 12,
          shadows: const [
            Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(0, 1)),
          ],
        );

        final tp = TextPainter(
          text: TextSpan(text: '${prize.amount}', style: textStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      }
    } else {
      // Draw text for other prizes
      final textStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: size.width >= 300 ? 13 : 11,
        shadows: const [
          Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(0, 1)),
        ],
      );

      final tp = TextPainter(
        text: TextSpan(text: _short(prize.name), style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        textAlign: TextAlign.center,
      )..layout(maxWidth: isTablet ? 60 : 50);

      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    }
  }

  String _short(String name) {
    if (name.toLowerCase().contains('spin')) return 'Spin\nAgain';
    if (name.toLowerCase().contains('no reward') ||
        name.toLowerCase().contains('try')) return 'No\nReward';
    return name;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Result Popup
class _ResultPopup extends StatelessWidget {
  final VoidCallback onOk;
  final String title;
  final String message;
  final int amount;
  final PrizeType prizeType;

  const _ResultPopup({
    required this.onOk,
    required this.title,
    required this.message,
    required this.amount,
    required this.prizeType,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return Center(
      child: Container(
        width: isTablet ? 450 : 350,
        height: isTablet ? 320 : 260,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/overlays/Group 67.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            // Content
            Positioned(
              top: isTablet ? 60 : 50,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      color: const Color(0xFF4CAF50),
                      fontSize: isTablet ? 28 : 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (prizeType == PrizeType.companion) ...[
                    // Show penguin image for companion
                    Image.asset(
                      'assets/images/companions/penguin.png',
                      width: isTablet ? 100 : 80,
                      height: isTablet ? 100 : 80,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.pets,
                          size: isTablet ? 80 : 60,
                          color: Colors.blue,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Penguin Companion!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        color: Colors.black87,
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else if (prizeType == PrizeType.coins && amount > 0) ...[
                    // Show coin for coins
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/home/coin_simple.png',
                          width: isTablet ? 40 : 32,
                          height: isTablet ? 40 : 32,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.monetization_on,
                              color: Colors.orange,
                              size: isTablet ? 40 : 32,
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '+$amount',
                          style: TextStyle(
                            fontFamily: 'AkayaKanadaka',
                            color: Colors.orange,
                            fontSize: isTablet ? 32 : 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Show text for other prizes
                    Text(
                      message.isEmpty ? '—' : message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        color: Colors.black87,
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // OK Button
            Positioned(
              bottom: isTablet ? 40 : 30,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: isTablet ? 160 : 130,
                  height: isTablet ? 50 : 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 4,
                    ),
                    onPressed: onOk,
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontWeight: FontWeight.w800,
                        fontSize: isTablet ? 22 : 18,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

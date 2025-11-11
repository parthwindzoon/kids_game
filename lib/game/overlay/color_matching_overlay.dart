// lib/game/overlay/color_matching_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import '../../controllers/color_matching_controller.dart';

class ColorMatchingOverlay extends StatelessWidget {
  final TiledGame game;

  const ColorMatchingOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ColorMatchingController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Sky blue
            Color(0xFFB0E0E6), // Powder blue
          ],
        ),
      ),
      child: Stack(
        children: [
          // Main Content
          Center(
            child: Container(
              width: size.width * (isTablet ? 0.75 : 0.85),
              height: size.height * (isTablet ? 0.65 : 0.70),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isTablet ? 30 : 15),

                  // Instruction text
                  Text(
                    'Tap the matching color!',
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 36 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: isTablet ? 30 : 15),

                  // Target color box
                  Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isTablet ? 280 : 220,
                    height: isTablet ? 120 : 90,
                    decoration: BoxDecoration(
                      color: controller.targetColor.value,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  )),

                  SizedBox(height: isTablet ? 30 : 15),

                  // Color options (circles)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                    child: Wrap(
                      spacing: isTablet ? 20 : 15,
                      runSpacing: isTablet ? 20 : 15,
                      alignment: WrapAlignment.center,
                      children: controller.availableColors
                          .map((color) => _buildColorOption(color, controller, isTablet))
                          .toList(),
                    ),
                  ),

                  SizedBox(height: isTablet ? 40 : 30),
                ],
              ),
            ),
          ),

          // Back Button (top-left)
          Positioned(
            top: isTablet ? 20 : 10,
            left: isTablet ? 20 : 10,
            child: GestureDetector(
              onTap: () {
                controller.dispose();
                Get.delete<ColorMatchingController>();
                game.overlays.remove('color_matching');
                game.overlays.add('minigames_overlay');

                game.resumeBackgroundMusic();
              },
              child: Image.asset('assets/images/back_btn.png')  ,
            ),
          ),

          // Title
          Positioned(
            top: isTablet ? 30 : 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Color Matching',
                style: TextStyle(
                  fontFamily: 'AkayaKanadaka',
                  fontSize: isTablet ? 42 : 32,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Title text (filled)
          Positioned(
            top: isTablet ? 30 : 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Color Matching',
                style: TextStyle(
                  fontFamily: 'AkayaKanadaka',
                  fontSize: isTablet ? 42 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),

          // Score Display (top-right)
          Positioned(
            top: isTablet ? 20 : 15,
            right: isTablet ? 20 : 15,
            child: Obx(() => Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 15,
                vertical: isTablet ? 10 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Score-${controller.score.value}',
                style: TextStyle(
                  fontFamily: 'AkayaKanadaka',
                  fontSize: isTablet ? 24 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )),
          ),

          // Success Popup
          Obx(() {
            if (!controller.showSuccessPopup.value) {
              return const SizedBox.shrink();
            }
            return _buildSuccessPopup(controller, isTablet);
          }),

          // Wrong Answer Popup
          Obx(() {
            if (!controller.showWrongPopup.value) {
              return const SizedBox.shrink();
            }
            return _buildWrongPopup(controller, isTablet);
          }),

          // Completion Popup
          Obx(() {
            if (!controller.showCompletionPopup.value) {
              return const SizedBox.shrink();
            }
            return _buildCompletionPopup(controller, isTablet, game);
          }),
        ],
      ),
    );
  }

  Widget _buildColorOption(
      Color color, ColorMatchingController controller, bool isTablet) {
    final size = isTablet ? 70.0 : 55.0;

    return GestureDetector(
      onTap: () => controller.selectColor(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessPopup(ColorMatchingController controller, bool isTablet) {
    return Obx(() {
      final scale = controller.successPopupScale.value;
      final opacity = controller.successPopupOpacity.value;

      return Container(
        color: Colors.black.withOpacity(0.6 * opacity),
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: isTablet ? 400 : 320,
                height: isTablet ? 280 : 220,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/overlays/Group 67.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: isTablet ? 60 : 50,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: isTablet ? 60 : 50,
                          ),
                          SizedBox(height: isTablet ? 15 : 10),
                          Text(
                            'Perfect!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 10 : 8),
                          Text(
                            'You matched the color!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 18 : 14,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWrongPopup(ColorMatchingController controller, bool isTablet) {
    return Obx(() {
      final scale = controller.wrongPopupScale.value;
      final opacity = controller.wrongPopupOpacity.value;

      return Container(
        color: Colors.black.withOpacity(0.6 * opacity),
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: isTablet ? 400 : 320,
                height: isTablet ? 280 : 220,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/overlays/Group 67.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: isTablet ? 60 : 50,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Icon(
                            Icons.close,
                            color: Colors.red,
                            size: isTablet ? 60 : 50,
                          ),
                          SizedBox(height: isTablet ? 15 : 10),
                          Text(
                            'Oops!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFDC3545),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 10 : 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 15),
                            child: Text(
                              'Try again!',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 18 : 14,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCompletionPopup(
      ColorMatchingController controller, bool isTablet, TiledGame game) {
    return Obx(() {
      final scale = controller.popupScale.value;
      final opacity = controller.popupOpacity.value;

      return Container(
        color: Colors.black.withOpacity(0.6 * opacity),
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: isTablet ? 500 : 400,
                height: isTablet ? 350 : 280,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/overlays/Group 67.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: isTablet ? 60 : 50,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: isTablet ? 80 : 60,
                          ),
                          SizedBox(height: isTablet ? 20 : 15),
                          Text(
                            'Amazing!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 32 : 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 10 : 8),
                          Text(
                            'You matched all colors!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 20 : 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 5 : 3),
                          Text(
                            'Score: ${controller.score.value}',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Play Again Button
                    Positioned(
                      bottom: isTablet ? 40 : 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            controller.resetGame();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 30 : 25,
                              vertical: isTablet ? 12 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'Play Again',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          controller.closeCompletionPopup();
                          Get.delete<ColorMatchingController>();
                          game.overlays.remove('color_matching');
                          game.overlays.add('minigames_overlay');

                          game.resumeBackgroundMusic();
                        },
                        child: Image.asset(
                          'assets/images/overlays/Group 86.png',
                          width: isTablet ? 50 : 40,
                          height: isTablet ? 50 : 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
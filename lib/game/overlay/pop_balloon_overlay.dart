// lib/game/overlay/pop_balloon_overlay.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';

import '../../controllers/pop_balloon_controller.dart';

class PopBalloonOverlay extends StatelessWidget {
  final TiledGame game;

  const PopBalloonOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PopBalloonController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/pop_the_baloon/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Main Game Area - Balloons
          Positioned.fill(
            child: Obx(
              () => Stack(
                children: controller.balloons.map((balloon) {
                  if (balloon.isPopped) {
                    return const SizedBox.shrink();
                  }

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    left: balloon.x,
                    top: balloon.currentY,
                    child: _buildBalloon(balloon, controller, isTablet),
                  );
                }).toList(),
              ),
            ),
          ),

          Positioned(
            top: isTablet ? 20 : 10,
            right: isTablet ? 20 : 10,
            child: // Score Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 15,
                      vertical: isTablet ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: isTablet ? 28 : 22,
                        ),
                        SizedBox(width: isTablet ? 8 : 5),
                        Text(
                          'Score: ${controller.score.value}',
                          style: TextStyle(
                            fontFamily: 'AkayaKanadaka',
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top UI - Title, Task, and Score
          _buildTopUI(controller, isTablet),

          // Back Button (top-left corner)
          Positioned(
            top: isTablet ? 20 : 10,
            left: isTablet ? 20 : 10,
            child: GestureDetector(
              onTap: () {
                controller.dispose();
                Get.delete<PopBalloonController>();
                game.overlays.remove('pop_balloon');
                game.overlays.add('minigames_overlay');

                game.resumeBackgroundMusic();
              },
              child: Image.asset(
                'assets/images/back_btn.png',
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
              ),
            ),
          ),

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

  Widget _buildTopUI(PopBalloonController controller, bool isTablet) {
    return Positioned(
      top: isTablet ? 20 : 10,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Title
          Text(
            'Pop the Balloon',
            style: TextStyle(
              fontFamily: 'AkayaKanadaka',
              fontSize: isTablet ? 48 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFA500),
              shadows: [
                Shadow(
                  offset: const Offset(3, 3),
                  blurRadius: 5,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 10 : 5),

          // Task Description
          Obx(
            () => Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 25 : 20,
                vertical: isTablet ? 8 : 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFFFA500), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                controller.currentTask.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AkayaKanadaka',
                  fontSize: isTablet ? 24 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalloon(
    BalloonData balloon,
    PopBalloonController controller,
    bool isTablet,
  ) {
    final balloonSize = isTablet ? 100.0 : 75.0; // Made smaller as requested

    return GestureDetector(
      onTap: () {
        controller.popBalloon(balloon.id);
      },
      child: Container(
        width: balloonSize,
        height: balloonSize * 1.3, // Balloons are taller than they are wide
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Balloon Image
            Positioned(
              top: 0,
              child: Image.asset(
                'assets/images/pop_the_baloon/${balloon.colorAsset}',
                width: balloonSize,
                height: balloonSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackBalloon(balloon, balloonSize);
                },
              ),
            ),

            // Letter/Number on Balloon
            Positioned(
              top: -10,
              child: Container(
                width: balloonSize * 0.6,
                height: balloonSize * 0.6,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    balloon.letter,
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet
                          ? 28
                          : 20, // Adjusted for smaller balloons
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 3,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
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

  Widget _buildFallbackBalloon(BalloonData balloon, double size) {
    final colors = {
      'yellow_baloon.png': Colors.yellow,
      'red_baloon.png': Colors.red,
      'green_baloon.png': Colors.green,
      'blue_baloon.png': Colors.blue,
      'orange_baloon.png': Colors.orange,
    };

    final color = colors[balloon.colorAsset] ?? Colors.blue;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionPopup(
    PopBalloonController controller,
    bool isTablet,
    TiledGame game,
  ) {
    return Obx(() {
      final scale = controller.popupScale.value;
      final opacity = controller.popupOpacity.value;

      return Container(
        color: Colors.black.withValues(alpha: 0.6 * opacity),
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
                    // Congratulations Content
                    Positioned(
                      top: isTablet ? 60 : 50,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          // Trophy Icon
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: isTablet ? 80 : 60,
                          ),
                          SizedBox(height: isTablet ? 20 : 15),

                          // Congratulations Text
                          Text(
                            'Well Done!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 32 : 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 10 : 8),

                          // Score Display
                          Text(
                            'You earned ${controller.score.value} points!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 20 : 16,
                              color: Colors.grey.shade700,
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
                                  color: Colors.black.withValues(alpha: 0.2),
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
                          Get.delete<PopBalloonController>();
                          game.overlays.remove('pop_balloon');
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

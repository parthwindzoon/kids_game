// lib/game/overlay/garden_cleaning_overlay.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

class GardenCleaningOverlay extends StatelessWidget {
  final TiledGame game;

  const GardenCleaningOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GardenCleaningController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/garden_cleaning/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Main Game Area
          Positioned.fill(
            child: Obx(() => Stack(
              children: [
                // Dustbin (left side)
                _buildDustbin(controller, isTablet),

                // Trash Items
                ...controller.trashItems.map((item) {
                  return _buildTrashItem(item, controller, isTablet);
                }).toList(),
              ],
            )),
          ),

          // Top UI Elements
          SafeArea(
            child: Stack(
              children: [
                // Title
                Positioned(
                  top: isTablet ? 20 : 15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 30 : 20,
                        vertical: isTablet ? 15 : 10,
                      ),
                      // decoration: BoxDecoration(
                      //   color: Colors.white.withOpacity(0.9),
                      //   borderRadius: BorderRadius.circular(30),
                      //   border: Border.all(
                      //     color: const Color(0xFF4CAF50),
                      //     width: 3,
                      //   ),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.black.withOpacity(0.2),
                      //       blurRadius: 10,
                      //       offset: const Offset(0, 4),
                      //     ),
                      //   ],
                      // ),
                      child: Text(
                        'Clean the garden',
                        style: TextStyle(
                          fontFamily: 'AkayaKanadaka',
                          fontSize: isTablet ? 36 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF0000),
                          shadows: [
                            Shadow(
                              offset: const Offset(2, 2),
                              blurRadius: 3,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Back Button (top-left)
                Positioned(
                  top: isTablet ? 20 : 15,
                  left: isTablet ? 20 : 15,
                  child: GestureDetector(
                    onTap: () {
                      controller.dispose();
                      Get.delete<GardenCleaningController>();
                      game.overlays.remove('garden_cleaning');
                      game.overlays.add('minigames_overlay');
                    },
                    child: Image.asset(
                      'assets/images/back_btn.png',
                      width: isTablet ? 70 : 55,
                      height: isTablet ? 70 : 55,
                    ),
                  ),
                ),

                // Score Display (top-right)
                Positioned(
                  top: isTablet ? 20 : 15,
                  right: isTablet ? 20 : 15,
                  child: Obx(() => Container(
                    width: isTablet ? 180 : 140,
                    height: isTablet ? 70 : 55,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/score_bg.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: isTablet ? 8 : 6),
                        child: Text(
                          'Score-${controller.score.value}',
                          style: TextStyle(
                            fontFamily: 'AkayaKanadaka',
                            fontSize: isTablet ? 24 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
              ],
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

  Widget _buildDustbin(GardenCleaningController controller, bool isTablet) {
    return Positioned(
      left: isTablet ? 40 : 20,
      bottom: isTablet ? 80 : 40,
      child: Obx(() {
        // Get current animation frame
        final frameIndex = controller.dustbinAnimationFrame.value;

        return DragTarget<TrashItem>(
          onWillAccept: (data) => data != null,
          onAccept: (item) {
            controller.collectTrash(item);
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..scale(isHovering ? 1.1 : 1.0),
              child: Container(
                width: isTablet ? 220 : 160,
                height: isTablet ? 220 : 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: isHovering
                      ? Border.all(
                    color: const Color(0xFF4CAF50),
                    width: 4,
                  )
                      : null,
                ),
                child: Image.asset(
                  'assets/images/garden_cleaning/dustbin.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to static dustbin if animation frames not available
                    return Image.asset(
                      'assets/images/garden_cleaning/dustbin.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTrashItem(TrashItem item, GardenCleaningController controller, bool isTablet) {
    if (item.isCollected) {
      return const SizedBox.shrink();
    }

    final size = isTablet ? 80.0 : 60.0;

    return Positioned(
      left: item.position.dx,
      top: item.position.dy,
      child: Draggable<TrashItem>(
        data: item,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.2,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                item.imagePath,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: Image.asset(
            item.imagePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
        child: Image.asset(
          item.imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.brown.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_outline,
                size: size * 0.6,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompletionPopup(
      GardenCleaningController controller,
      bool isTablet,
      TiledGame game,
      ) {
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
                    // Congratulations Content
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
                            'Garden Cleaned!',
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
                          Get.delete<GardenCleaningController>();
                          game.overlays.remove('garden_cleaning');
                          game.overlays.add('minigames_overlay');
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

class GardenCleaningController extends GetxController {
  final RxList<TrashItem> trashItems = <TrashItem>[].obs;
  final RxInt score = 0.obs;
  final RxBool showCompletionPopup = false.obs;
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;
  final RxInt dustbinAnimationFrame = 0.obs;

  // Trash types available
  final List<String> trashTypes = [
    'bottle',
    'can',
    'mapple',
    'coffeeglass',
    'page',
    'chocolate',
    'banana',
  ];

  int totalTrash = 15;

  @override
  void onInit() {
    super.onInit();
    _preloadAudio();
    _startDustbinAnimation();

    // Delay initialization to ensure screen is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeTrash();
    });
  }

  void _startDustbinAnimation() {
    void animate() {
      if (isClosed) return;

      dustbinAnimationFrame.value = (dustbinAnimationFrame.value + 1) % 10;

      Future.delayed(const Duration(milliseconds: 100), animate);
    }

    animate();
  }

  Future<void> _preloadAudio() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'success.mp3',
        'celebration.mp3',
      ]);
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  void _initializeTrash() {
    final random = Random();
    final screenWidth = Get.width;
    final screenHeight = Get.height;

    // Define safe zones (avoiding dustbin and UI elements)
    final safeLeft = screenWidth * 0.25; // Start after dustbin
    final safeRight = screenWidth * 0.9; // Before score
    final safeTop = screenHeight * 0.2; // Below title
    final safeBottom = screenHeight * 0.85; // Above bottom

    trashItems.clear();

    for (int i = 0; i < totalTrash; i++) {
      final trashType = trashTypes[random.nextInt(trashTypes.length)];

      // Generate random position in safe zone
      final x = safeLeft + random.nextDouble() * (safeRight - safeLeft);
      final y = safeTop + random.nextDouble() * (safeBottom - safeTop);

      trashItems.add(
        TrashItem(
          id: i,
          type: trashType,
          position: Offset(x, y),
          imagePath: 'assets/images/garden_cleaning/$trashType.png',
        ),
      );
    }
  }

  void collectTrash(TrashItem item) {
    final index = trashItems.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      trashItems[index] = trashItems[index].copyWith(isCollected: true);
      score.value++;
      _playSuccessSound();

      // Check if all trash is collected
      if (score.value == totalTrash) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showCompletionPopup();
          _playCelebrationSound();
        });
      }
    }
  }

  Future<void> _playSuccessSound() async {
    try {
      await FlameAudio.play('success.mp3');
    } catch (e) {
      print('⚠️ Error playing success sound: $e');
    }
  }

  Future<void> _playCelebrationSound() async {
    try {
      await FlameAudio.play('celebration.mp3');
    } catch (e) {
      print('⚠️ Error playing celebration sound: $e');
    }
  }

  void _showCompletionPopup() {
    showCompletionPopup.value = true;
    _animatePopupIn();
  }

  void _animatePopupIn() {
    popupScale.value = 0.3;
    popupOpacity.value = 0.0;

    final duration = 500;
    final steps = 30;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (showCompletionPopup.value) {
          final progress = i / steps;
          final easeProgress = 1 - (1 - progress) * (1 - progress);
          popupScale.value = 0.3 + (0.7 * easeProgress);
          popupOpacity.value = progress;
        }
      });
    }
  }

  void closeCompletionPopup() {
    final duration = 300;
    final steps = 20;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        final progress = i / steps;
        popupScale.value = 1.0 - (0.3 * progress);
        popupOpacity.value = 1.0 - progress;

        if (i == steps) {
          showCompletionPopup.value = false;
        }
      });
    }
  }

  void resetGame() {
    score.value = 0;
    closeCompletionPopup();
    _initializeTrash();
  }

  @override
  void dispose() {
    trashItems.clear();
    super.dispose();
  }
}

class TrashItem {
  final int id;
  final String type;
  final Offset position;
  final String imagePath;
  final bool isCollected;

  TrashItem({
    required this.id,
    required this.type,
    required this.position,
    required this.imagePath,
    this.isCollected = false,
  });

  TrashItem copyWith({
    int? id,
    String? type,
    Offset? position,
    String? imagePath,
    bool? isCollected,
  }) {
    return TrashItem(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      imagePath: imagePath ?? this.imagePath,
      isCollected: isCollected ?? this.isCollected,
    );
  }
}
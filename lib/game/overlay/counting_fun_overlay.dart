// lib/game/overlay/counting_fun_overlay.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

class CountingFunOverlay extends StatelessWidget {
  final TiledGame game;

  const CountingFunOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CountingFunController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/counting_fun/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isTablet ? 60 : 40),

                // Title - Red outline text
                Text(
                  'Counting Fun',
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 48 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                        color: Colors.white,
                      ),
                      Shadow(
                        offset: const Offset(-2, -2),
                        blurRadius: 0,
                        color: Colors.white,
                      ),
                      Shadow(
                        offset: const Offset(2, -2),
                        blurRadius: 0,
                        color: Colors.white,
                      ),
                      Shadow(
                        offset: const Offset(-2, 2),
                        blurRadius: 0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 15 : 10),

                // Subtitle - White text
                Text(
                  'Count the objects and pic the right number!',
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 24 : 18,
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

                SizedBox(height: isTablet ? 30 : 20),

                // Objects to count
                Obx(() => _buildCountingObjects(controller, isTablet)),

                SizedBox(height: isTablet ? 30 : 20),

                // Train with numbered carriages
                _buildTrain(controller, isTablet),

                SizedBox(height: isTablet ? 20 : 15),
              ],
            ),
          ),

          // Back Button (top-left corner)
          Positioned(
            top: isTablet ? 20 : 10,
            left: isTablet ? 20 : 10,
            child: GestureDetector(
              onTap: () {
                controller.dispose();
                Get.delete<CountingFunController>();
                game.overlays.remove('counting_fun');
                game.overlays.add('minigames_overlay');
              },
              child: Image.asset('assets/images/back_btn.png'),
            ),
          ),

          // Score Display (top-right with score_bg)
          Positioned(
            top: isTablet ? 20 : 15,
            right: isTablet ? 20 : 15,
            child: Obx(() => Container(
              width: isTablet ? 200 : 160,
              height: isTablet ? 60 : 50,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/score_bg.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: Text(
                  'Score-${controller.score.value}',
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )),
          ),

          // Next Level Popup
          Obx(() {
            if (!controller.showNextLevelPopup.value) {
              return const SizedBox.shrink();
            }
            return _buildNextLevelPopup(controller, isTablet, game);
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

  Widget _buildCountingObjects(CountingFunController controller, bool isTablet) {
    final objectSize = isTablet ? 40.0 : 32.0;

    return Container(
      height: isTablet ? 120 : 100,
      width: double.infinity,
      child: Stack(
        children: List.generate(controller.currentObjectCount.value, (index) {
          // Random positioning for scattered look
          final positions = controller.getObjectPositions(isTablet);
          if (index >= positions.length) return const SizedBox.shrink();

          return Positioned(
            left: positions[index].dx,
            top: positions[index].dy,
            child: Image.asset(
              controller.currentObjectImage.value,
              width: objectSize,
              height: objectSize,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to flower emoji
                return Container(
                  width: objectSize,
                  height: objectSize,
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🌸', style: TextStyle(fontSize: 20)),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTrain(CountingFunController controller, bool isTablet) {
    final engineSize = isTablet ? 80.0 : 65.0;
    final carriageSize = isTablet ? 70.0 : 55.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Engine
          Image.asset(
            'assets/images/counting_fun/Engine.png',
            width: engineSize,
            height: engineSize,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: engineSize,
                height: engineSize,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('🚂', style: TextStyle(fontSize: 40)),
                ),
              );
            },
          ),

          // Carriages (1-10)
          ...List.generate(10, (index) {
            final number = index + 1;
            return Obx(() {
              final isCorrectAnswer = number == controller.currentObjectCount.value;
              final isSelected = controller.selectedNumber.value == number;
              final hasAnswered = controller.hasAnswered.value;

              return GestureDetector(
                onTap: () {
                  if (!hasAnswered) {
                    controller.selectNumber(number);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  transform: Matrix4.identity()
                    ..scale(isSelected ? 1.1 : 1.0),
                  child: Stack(
                    children: [
                      // Carriage image
                      Image.asset(
                        'assets/images/counting_fun/${number}.png', // Individual carriage images
                        width: carriageSize,
                        height: carriageSize,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback carriage design
                          return Container(
                            width: carriageSize,
                            height: carriageSize,
                            decoration: BoxDecoration(
                              color: _getCarriageColor(number),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '$number',
                                style: TextStyle(
                                  fontFamily: 'AkayaKanadaka',
                                  fontSize: isTablet ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Selection indicator
                      if (isSelected && !hasAnswered)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.yellow,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                      // Correct/Wrong indicator after answer
                      if (hasAnswered && isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCorrectAnswer
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                              border: Border.all(
                                color: isCorrectAnswer ? Colors.green : Colors.red,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                isCorrectAnswer ? Icons.check : Icons.close,
                                color: isCorrectAnswer ? Colors.green : Colors.red,
                                size: isTablet ? 30 : 25,
                              ),
                            ),
                          ),
                        ),

                      // Show correct answer if wrong was selected
                      if (hasAnswered && !isSelected && isCorrectAnswer)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            });
          }),
        ],
      ),
    );
  }

  Color _getCarriageColor(int number) {
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.pink, Colors.yellow, Colors.cyan, Colors.brown, Colors.indigo,
    ];
    return colors[(number - 1) % colors.length];
  }

  Widget _buildNextLevelPopup(
      CountingFunController controller,
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
                            'Great Job!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: isTablet ? 30 : 25,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            controller.nextLevel();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 25 : 20,
                              vertical: isTablet ? 10 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Next Level',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 20 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
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

  Widget _buildCompletionPopup(
      CountingFunController controller,
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
                            'Excellent!',
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
                            'You completed all levels!',
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

                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          controller.closeCompletionPopup();
                          Get.delete<CountingFunController>();
                          game.overlays.remove('counting_fun');
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

class CountingFunController extends GetxController {
  final RxInt currentObjectCount = 1.obs;
  final RxString currentObjectImage = 'assets/images/flower.png'.obs;
  final RxInt selectedNumber = 0.obs;
  final RxBool hasAnswered = false.obs;
  final RxInt score = 0.obs;
  final RxInt currentLevel = 1.obs;
  final RxBool showNextLevelPopup = false.obs;
  final RxBool showCompletionPopup = false.obs;
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;

  final List<String> objectImages = [
    'assets/images/flower.png',
    'assets/images/star.png',
    'assets/images/heart.png',
    'assets/images/sun.png',
    'assets/images/butterfly.png',
    'assets/images/apple.png',
    'assets/images/ball.png',
    'assets/images/car.png',
  ];

  @override
  void onInit() {
    super.onInit();
    _generateLevel();
    _preloadAudio();
  }

  void _generateLevel() {
    // Generate random count (1-10)
    currentObjectCount.value = Random().nextInt(10) + 1;

    // Select random object
    currentObjectImage.value = objectImages[Random().nextInt(objectImages.length)];

    // Reset selection
    selectedNumber.value = 0;
    hasAnswered.value = false;
  }

  List<Offset> getObjectPositions(bool isTablet) {
    final count = currentObjectCount.value;
    final maxWidth = isTablet ? 600.0 : 400.0;
    final maxHeight = isTablet ? 100.0 : 80.0;
    final positions = <Offset>[];

    // Generate scattered positions
    final random = Random(count); // Use count as seed for consistent positions

    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * (maxWidth - 50);
      final y = random.nextDouble() * (maxHeight - 50);
      positions.add(Offset(x, y));
    }

    return positions;
  }

  void selectNumber(int number) {
    selectedNumber.value = number;
    hasAnswered.value = true;

    if (number == currentObjectCount.value) {
      // Correct answer
      score.value += 10;
      _playSuccessSound();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (currentLevel.value >= 10) {
          // Game completed
          _showCompletionPopup();
          _playCelebrationSound();
        } else {
          // Show next level popup
          _showNextLevelPopup();
        }
      });
    } else {
      // Wrong answer
      _playWrongSound();

      Future.delayed(const Duration(milliseconds: 2000), () {
        // Generate new level after showing correct answer
        currentLevel.value++;
        _generateLevel();
      });
    }
  }

  void nextLevel() {
    closeNextLevelPopup();
    currentLevel.value++;
    _generateLevel();
  }

  void _showNextLevelPopup() {
    showNextLevelPopup.value = true;
    _animatePopupIn();
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
        if (showNextLevelPopup.value || showCompletionPopup.value) {
          final progress = i / steps;
          final easeProgress = 1 - (1 - progress) * (1 - progress);
          popupScale.value = 0.3 + (0.7 * easeProgress);
          popupOpacity.value = progress;
        }
      });
    }
  }

  void closeNextLevelPopup() {
    showNextLevelPopup.value = false;
  }

  void closeCompletionPopup() {
    showCompletionPopup.value = false;
  }

  void resetGame() {
    currentLevel.value = 1;
    score.value = 0;
    closeCompletionPopup();
    _generateLevel();
  }

  Future<void> _preloadAudio() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'success.mp3',
        'wrong.mp3',
        'celebration.mp3',
      ]);
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  Future<void> _playSuccessSound() async {
    try {
      await FlameAudio.play('success.mp3');
    } catch (e) {
      print('⚠️ Error playing success sound: $e');
    }
  }

  Future<void> _playWrongSound() async {
    try {
      await FlameAudio.play('wrong.mp3');
    } catch (e) {
      print('⚠️ Error playing wrong sound: $e');
    }
  }

  Future<void> _playCelebrationSound() async {
    try {
      await FlameAudio.play('celebration.mp3');
    } catch (e) {
      print('⚠️ Error playing celebration sound: $e');
    }
  }
}
// lib/game/overlay/counting_fun_overlay.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

import '../../controllers/coin_controller.dart';

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
                SizedBox(height: isTablet ? 40 : 30),

                // Title - "Counting Fun" with white text and red outline
                Stack(
                  children: [
                    // Outline
                    Text(
                      'Counting Fun',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 48 : 36,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = Colors.red,
                      ),
                    ),
                    // Fill
                    Text(
                      'Counting Fun',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 48 : 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 15 : 10),

                // Subtitle
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
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 30 : 20),

                // Objects to count area
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

                game.resumeBackgroundMusic();
              },
              child: Image.asset(
                'assets/images/back_btn.png',
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
              ),
            ),
          ),

          // Score Display (top-right with custom design)
          Positioned(
            top: isTablet ? 20 : 15,
            right: isTablet ? 20 : 15,
            child: Obx(() => Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 25 : 20,
                vertical: isTablet ? 12 : 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Score-${controller.score.value}',
                style: TextStyle(
                  fontFamily: 'AkayaKanadaka',
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
    final objectSize = isTablet ? 60.0 : 50.0;

    return Container(
      height: isTablet ? 160 : 140,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
      child: Stack(
        children: List.generate(controller.currentObjectCount.value, (index) {
          final positions = controller.getObjectPositions(isTablet);
          if (index >= positions.length) return const SizedBox.shrink();

          return Positioned(
            left: positions[index].dx,
            top: positions[index].dy,
            child: Image.asset(
              'assets/images/counting_fun/object.png',
              width: objectSize,
              height: objectSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('❌ Error loading object.png: $error');
                return Container(
                  width: objectSize,
                  height: objectSize,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: objectSize * 0.4,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
    final engineSize = isTablet ? 110.0 : 85.0;
    final carriageSize = isTablet ? 95.0 : 75.0;
    final horizontalSpacing = isTablet ? 5.0 : 3.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Engine
            Image.asset(
              'assets/images/counting_fun/Engine.png',
              width: engineSize,
              height: engineSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('❌ Error loading Engine.png: $error');
                return Container(
                  width: engineSize,
                  height: engineSize,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🚂', style: TextStyle(fontSize: 50)),
                  ),
                );
              },
            ),

            SizedBox(width: horizontalSpacing),

            // Carriages (1-10)
            ...List.generate(10, (index) {
              final number = index + 1;
              return Obx(() {
                final isCorrectAnswer = number == controller.currentObjectCount.value;
                final isSelected = controller.selectedNumber.value == number;
                final hasAnswered = controller.hasAnswered.value;

                return Padding(
                  padding: EdgeInsets.only(right: horizontalSpacing),
                  child: GestureDetector(
                    onTap: () {
                      if (!hasAnswered) {
                        controller.selectNumber(number);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      transform: Matrix4.identity()
                        ..scale(isSelected ? 1.1 : 1.0),
                      child: Stack(
                        children: [
                          // Carriage image
                          Image.asset(
                            'assets/images/counting_fun/$number.png',
                            width: carriageSize,
                            height: carriageSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ Error loading $number.png: $error');
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
                                    width: 4,
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
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.red.withValues(alpha: 0.3),
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
                                    width: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            }),
          ],
        ),
      ),
    );
  }

  Color _getCarriageColor(int number) {
    final colors = [
      const Color(0xFFE74C3C), // Red
      const Color(0xFF3498DB), // Blue
      const Color(0xFF2ECC71), // Green
      const Color(0xFFF39C12), // Orange
      const Color(0xFFF1C40F), // Yellow
      const Color(0xFF9B59B6), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
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
        color: Colors.black.withValues(alpha: 0.6 * opacity),
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
                                  color: Colors.black.withValues(alpha: 0.2),
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
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          controller.closeCompletionPopup();
                          Get.delete<CountingFunController>();
                          game.overlays.remove('counting_fun');
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

class CountingFunController extends GetxController {
  final RxInt currentObjectCount = 1.obs;
  final RxString currentObjectImage = 'assets/images/counting_fun/object.png'.obs;
  final RxInt selectedNumber = 0.obs;
  final RxBool hasAnswered = false.obs;
  final RxInt score = 0.obs;
  final RxInt currentLevel = 1.obs;
  final RxBool showNextLevelPopup = false.obs;
  final RxBool showCompletionPopup = false.obs;
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;

  List<Offset> _cachedPositions = [];

  @override
  void onInit() {
    super.onInit();
    _generateLevel();
    _preloadAudio();
  }

  void _generateLevel() {
    currentObjectCount.value = Random().nextInt(10) + 1;
    currentObjectImage.value = 'assets/images/counting_fun/object.png';
    selectedNumber.value = 0;
    hasAnswered.value = false;
    _cachedPositions.clear();
  }

  List<Offset> getObjectPositions(bool isTablet) {
    if (_cachedPositions.isNotEmpty &&
        _cachedPositions.length == currentObjectCount.value) {
      return _cachedPositions;
    }

    final count = currentObjectCount.value;
    final maxWidth = isTablet ? 800.0 : 600.0;
    final maxHeight = isTablet ? 140.0 : 120.0;
    final objectSize = isTablet ? 60.0 : 50.0;
    final minDistance = objectSize * 1.3;

    final positions = <Offset>[];
    final random = Random();
    int maxAttempts = 100;

    for (int i = 0; i < count; i++) {
      bool positionFound = false;
      int attempts = 0;

      while (!positionFound && attempts < maxAttempts) {
        final x = random.nextDouble() * (maxWidth - objectSize);
        final y = random.nextDouble() * (maxHeight - objectSize);
        final newPosition = Offset(x, y);

        bool isFarEnough = true;
        for (final existingPosition in positions) {
          final distance = (newPosition - existingPosition).distance;
          if (distance < minDistance) {
            isFarEnough = false;
            break;
          }
        }

        if (isFarEnough) {
          positions.add(newPosition);
          positionFound = true;
        }

        attempts++;
      }

      if (!positionFound) {
        final x = random.nextDouble() * (maxWidth - objectSize);
        final y = random.nextDouble() * (maxHeight - objectSize);
        positions.add(Offset(x, y));
      }
    }

    _cachedPositions = positions;
    return positions;
  }

  void selectNumber(int number) {
    selectedNumber.value = number;
    hasAnswered.value = true;

    if (number == currentObjectCount.value) {
      score.value += 10;
      _playSuccessSound();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (currentLevel.value >= 10) {
          _showCompletionPopup();
          _playCelebrationSound();
        } else {
          _showNextLevelPopup();
        }
      });
    } else {
      _playWrongSound();

      Future.delayed(const Duration(milliseconds: 2000), () {
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

    // Award coins
    final coinController = Get.find<CoinController>();
    coinController.addCoins(5);
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
  final List<String> _audioFiles = [
    'success.mp3',
    'wrong.mp3',
    'celebration.mp3',
  ];
  Future<void> _preloadAudio() async {
    try {
      await FlameAudio.audioCache.loadAll(_audioFiles);
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

  @override
  void dispose() {
    _cachedPositions.clear();

    for (final file in _audioFiles) {
      FlameAudio.audioCache.clear(file);
    }
    print('✅ Cleared counting_fun audio cache');
    super.dispose();
  }
}
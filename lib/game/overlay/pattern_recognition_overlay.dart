// lib/game/overlay/pattern_recognition_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

import '../../controllers/coin_controller.dart';

class PatternRecognitionOverlay extends StatelessWidget {
  final TiledGame game;

  const PatternRecognitionOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatternRecognitionController(game));
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    final titleStyle = TextStyle(
      fontFamily: 'AkayaKanadaka',
      fontSize: isTablet ? 42 : 28,
      fontWeight: FontWeight.bold,
      color: Colors.red.shade800,
      shadows: [
        Shadow(
          offset: const Offset(2, 2),
          blurRadius: 3,
          color: Colors.black.withValues(alpha: 0.2),
        ),
      ],
    );

    final scoreStyle = TextStyle(
      fontFamily: 'AkayaKanadaka',
      fontSize: isTablet ? 24 : 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    final instructionStyle = TextStyle(
      fontFamily: 'AkayaKanadaka',
      fontSize: isTablet ? 32 : 24,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return WillPopScope(
      onWillPop: () async {
        controller.handleBackButton();
        return false;
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Top Bar: Back Button
              Positioned(
                top: isTablet ? 20 : 15,
                left: isTablet ? 20 : 15,
                child: GestureDetector(
                  onTap: controller.handleBackButton,
                  child: Image.asset(
                    'assets/images/back_btn.png',
                    height: isTablet ? 60 : 45,
                  ),
                ),
              ),

              // Top Bar: Title
              Positioned(
                top: isTablet ? 30 : 22,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Pattern Recognition',
                    style: titleStyle,
                  ),
                ),
              ),

              // Top Bar: Score
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
                      style: scoreStyle,
                    ),
                  ),
                )),
              ),

              // Game Content Area
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // White background box
                    Image.asset(
                      'assets/images/pattern_recognition/Rectangle 70.png',
                      width: size.width * (isTablet ? 0.8 : 0.60),
                      height: size.height * (isTablet ? 0.6 : 0.65),
                      fit: BoxFit.fill,
                    ),

                    // Game elements inside the white box
                    Obx(() => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // "Complete the pattern!" text
                        Text(
                          'Complete the pattern!',
                          style: instructionStyle,
                        ),
                        SizedBox(height: isTablet ? 30 : 20),

                        // Pattern Row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...controller.currentPattern
                                .map((color) => _buildColorBox(color, isTablet))
                                .toList(),
                            // Question Mark Box
                            Image.asset(
                              'assets/images/pattern_recognition/box.png',
                              height: isTablet ? 80 : 60,
                              width: isTablet ? 80 : 60,
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 40 : 25),

                        // Options Row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: controller.currentOptions
                              .map((color) => _buildColorOption(
                              color, isTablet, controller))
                              .toList(),
                        ),
                      ],
                    )),
                  ],
                ),
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
        ),
      ),
    );
  }

  Widget _buildColorBox(Color color, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 5),
      height: isTablet ? 80 : 60,
      width: isTablet ? 80 : 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        border: Border.all(color: Colors.black54, width: 2),
      ),
    );
  }

  Widget _buildColorOption(
      Color color, bool isTablet, PatternRecognitionController controller) {
    return GestureDetector(
      onTap: () => controller.selectAnswer(color),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8),
        height: isTablet ? 70 : 55,
        width: isTablet ? 70 : 55,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessPopup(
      PatternRecognitionController controller, bool isTablet) {
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
                          SizedBox(height: isTablet ? 10 : 8),
                          Text(
                            'You are correct!',
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

  Widget _buildWrongPopup(
      PatternRecognitionController controller, bool isTablet) {
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
                            Icons.close,
                            color: Colors.red,
                            size: isTablet ? 60 : 50,
                          ),
                          SizedBox(height: isTablet ? 15 : 10),
                          Text(
                            'Uh Oh!',
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
                              'That\'s not the one.\nTry again!',
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
      PatternRecognitionController controller, bool isTablet, TiledGame game) {
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
                            'You finished!',
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
                            'Final Score: ${controller.score.value}',
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
                          Get.delete<PatternRecognitionController>();
                          game.overlays.remove('pattern_recognition');
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

// Controller for game logic
class PatternRecognitionController extends GetxController {
  final TiledGame game;
  PatternRecognitionController(this.game);

  // --- Game State ---
  final score = 0.obs;
  final level = 0.obs;

  // Popup states
  final showSuccessPopup = false.obs;
  final showWrongPopup = false.obs;
  final showCompletionPopup = false.obs;
  final popupScale = 0.0.obs;
  final popupOpacity = 0.0.obs;

  // --- Pattern Definitions ---
  static const Color blue = Color(0xFF007BFF);
  static const Color red = Color(0xFFDC3545);
  static const Color green = Color(0xFF28A745);
  static const Color yellow = Color(0xFFFFC107);
  static const Color orange = Color(0xFFFD7E14);

  final List<Map<String, dynamic>> _levels = [
    {
      'pattern': [blue, red, blue, red],
      'options': [green, yellow, orange, blue],
      'answer': blue,
    },
    {
      'pattern': [green, yellow, green, yellow],
      'options': [green, red, orange, blue],
      'answer': green,
    },
    {
      'pattern': [red, blue, orange, red],
      'options': [yellow, blue, orange, green],
      'answer': blue,
    },
    {
      'pattern': [yellow, green, yellow, green],
      'options': [yellow, red, blue, orange],
      'answer': yellow,
    },
    {
      'pattern': [orange, blue, orange, blue],
      'options': [orange, green, yellow, red],
      'answer': orange,
    },
  ];

  // --- Rx Variables for UI ---
  final currentPattern = <Color>[].obs;
  final currentOptions = <Color>[].obs;
  late Color correctAnswer;

  @override
  void onInit() {
    super.onInit();
    _preloadAudio();
    _loadLevel(level.value);
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

  void _loadLevel(int levelIndex) {
    if (levelIndex >= _levels.length) {
      // Game finished
      _showCompletionPopup();
      return;
    }

    final levelData = _levels[levelIndex];
    currentPattern.value = List<Color>.from(levelData['pattern']);
    currentOptions.value = List<Color>.from(levelData['options']);
    currentOptions.shuffle();
    correctAnswer = levelData['answer'] as Color;
  }

  void selectAnswer(Color selectedColor) {
    if (selectedColor == correctAnswer) {
      // --- Correct Answer ---
      score.value += 10;
      _playSuccessSound();
      _showSuccessPopup();

      // Move to next level after delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        closeSuccessPopup();
        level.value++;
        _loadLevel(level.value);
      });
    } else {
      // --- Incorrect Answer ---
      if (score.value > 0) {
        score.value -= 5;
      }
      _playWrongSound();
      _showWrongPopup();

      // Hide popup after delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        closeWrongPopup();
      });
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

  void _showSuccessPopup() {
    showSuccessPopup.value = true;
    _animatePopupIn();
  }

  void _showWrongPopup() {
    showWrongPopup.value = true;
    _animatePopupIn();
  }

  void _showCompletionPopup() {
    showCompletionPopup.value = true;
    _animatePopupIn();
    _playCelebrationSound();

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
        final progress = i / steps;
        final easeProgress = 1 - (1 - progress) * (1 - progress);
        popupScale.value = 0.3 + (0.7 * easeProgress);
        popupOpacity.value = progress;
      });
    }
  }

  void closeSuccessPopup() {
    showSuccessPopup.value = false;
  }

  void closeWrongPopup() {
    showWrongPopup.value = false;
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
    level.value = 0;
    closeCompletionPopup();
    _loadLevel(0);
  }

  @override
  void onClose() {
    for (final file in _audioFiles) {
      FlameAudio.audioCache.clear(file);
    }
    print('✅ Cleared pattern_recognition audio cache on close');
    super.onClose();
  }

  // @override
  // void dispose() {
  //   for (final file in _audioFiles) {
  //     FlameAudio.audioCache.clear(file);
  //   }
  //   print('✅ Cleared pattern_recognition audio cache');
  //   super.dispose();
  // }

  void handleBackButton() {
    game.overlays.remove('pattern_recognition');
    game.overlays.add('minigames_overlay');

    game.resumeBackgroundMusic();
    Get.delete<PatternRecognitionController>();
  }
}
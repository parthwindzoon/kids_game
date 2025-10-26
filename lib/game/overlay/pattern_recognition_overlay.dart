// lib/game/overlay/pattern_recognition_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';

class PatternRecognitionOverlay extends StatelessWidget {
  final TiledGame game;

  const PatternRecognitionOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatternRecognitionController(game));
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    // Define text styles based on tablet or phone
    final titleStyle = TextStyle(
      fontFamily: 'AkayaKanadaka',
      fontSize: isTablet ? 42 : 28,
      fontWeight: FontWeight.bold,
      color: Colors.red.shade800,
      shadows: [
        Shadow(
          offset: const Offset(2, 2),
          blurRadius: 3,
          color: Colors.black.withOpacity(0.2),
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
        child: SafeArea(
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/score_bg.png', // Your score box asset
                        height: isTablet ? 60 : 50,
                      ),
                      Obx(
                            () => Text(
                          'Score: ${controller.score.value}',
                          style: scoreStyle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Game Content Area
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // White background box
                      Image.asset(
                        'assets/images/pattern_recognition/Rectangle 70.png', // Assuming this is the white box asset
                        width: size.width * (isTablet ? 0.8 : 0.60),
                        height: size.height * (isTablet ? 0.6 : 0.65),
                        fit: BoxFit.fill,
                      ),

                      // Game elements inside the white box
                      Obx(
                            () => Column(
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
                                ...controller.currentPattern.value
                                    .map((color) => _buildColorBox(
                                    color, isTablet))
                                    .toList(),
                                // Question Mark Box
                                Image.asset(
                                  'assets/images/pattern_recognition/box.png', // Your question mark box asset
                                  height: isTablet ? 80 : 60,
                                  width: isTablet ? 80 : 60,
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 40 : 25),

                            // Options Row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: controller.currentOptions.value
                                  .map((color) => _buildColorOption(
                                  color, isTablet, controller))
                                  .toList(),
                            ),
                          ],
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
    );
  }

  // Helper widget for pattern boxes (squares)
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

  // Helper widget for answer options (circles)
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
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
      ),
    );
  }
}

// Controller for game logic
class PatternRecognitionController extends GetxController {
  final TiledGame game;
  PatternRecognitionController(this.game);

  // --- Game State ---
  final score = 10.obs;
  final level = 0.obs;

  // --- Pattern Definitions ---
  // Using Color objects directly. You can replace these with asset paths if needed.
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
    // Add more levels here...
  ];

  // --- Rx Variables for UI ---
  late RxList<Color> currentPattern;
  late RxList<Color> currentOptions;
  late Color correctAnswer;

  @override
  void onInit() {
    super.onInit();
    _loadLevel(level.value);
  }

  void _loadLevel(int levelIndex) {
    if (levelIndex >= _levels.length) {
      // Game finished, show final score or reset
      _showGameEndDialog();
      return;
    }

    final levelData = _levels[levelIndex];
    currentPattern = (levelData['pattern'] as List<Color>).obs;
    currentOptions = (levelData['options'] as List<Color>).obs;
    currentOptions.shuffle(); // Randomize options
    correctAnswer = levelData['answer'] as Color;
  }

  void selectAnswer(Color selectedColor) {
    if (selectedColor == correctAnswer) {
      // --- Correct Answer ---
      score.value += 10;
      level.value++;
      _loadLevel(level.value);
      _showFeedbackDialog(
          'Great Job!', 'You are correct!', const Color(0xFF28A745));
    } else {
      // --- Incorrect Answer ---
      if (score.value > 0) {
        score.value -= 5;
      }
      _showFeedbackDialog(
          'Uh Oh!', 'That\'s not the one. Try again!', const Color(0xFFDC3545));
    }
  }

  void _showFeedbackDialog(String title, String message, Color titleColor) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'AkayaKanadaka',
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'AkayaKanadaka', fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(fontFamily: 'AkayaKanadaka', fontSize: 16),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showGameEndDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'You finished!',
          style: TextStyle(
            fontFamily: 'AkayaKanadaka',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You completed all patterns!\nYour final score is: ${score.value}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'AkayaKanadaka', fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              handleBackButton(); // Go back to mini-game menu
            },
            child: const Text(
              'Awesome!',
              style: TextStyle(fontFamily: 'AkayaKanadaka', fontSize: 16),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void handleBackButton() {
    game.overlays.remove('pattern_recognition');
    Get.delete<PatternRecognitionController>();
  }
}
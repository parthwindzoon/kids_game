// lib/game/overlay/simple_math_overlay.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

import '../../controllers/coin_controller.dart';

class SimpleMathOverlay extends StatelessWidget {
  final TiledGame game;

  const SimpleMathOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SimpleMathController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/simple_math/background.png'),
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
                SizedBox(height: isTablet ? 80 : 60),

                // Title - "Simple Math" with white text and red outline
                Stack(
                  children: [
                    // Outline
                    Text(
                      'Simple Math',
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
                      'Simple Math',
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
                  'Solve the math problem!',
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: isTablet ? 30 : 20),

                // Math Problem Display
                Obx(() => _buildMathProblem(controller, isTablet)),

                SizedBox(height: isTablet ? 30 : 20),

                // Train with numbered answer carriages
                _buildAnswerTrain(controller, isTablet),

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
                Get.delete<SimpleMathController>();
                game.overlays.remove('simple_math');
                game.overlays.add('minigames_overlay');
              },
              child: Image.asset(
                'assets/images/back_btn.png',
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: isTablet ? 60 : 50,
                    height: isTablet ? 60 : 50,
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

          // Score Display (top-right with score_bg)
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
                    color: Colors.black.withOpacity(0.3),
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

  Widget _buildMathProblem(SimpleMathController controller, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 40 : 30,
        vertical: isTablet ? 20 : 15,
      ),
      child: Text(
        controller.currentProblem.value,
        style: TextStyle(
          fontFamily: 'AkayaKanadaka',
          fontSize: isTablet ? 56 : 42,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildAnswerTrain(SimpleMathController controller, bool isTablet) {
    final engineSize = isTablet ? 110.0 : 85.0;
    final carriageSize = isTablet ? 95.0 : 75.0;
    final horizontalSpacing = isTablet ? 5.0 : 3.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
        child: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Engine
            Image.asset(
              'assets/images/simple_math/Engine.png',
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

            // Answer option carriages
            ...List.generate(controller.answerOptions.length, (index) {
              final answer = controller.answerOptions[index];
              final isSelected = controller.selectedAnswer.value == answer;
              final hasAnswered = controller.hasAnswered.value;
              final isCorrectAnswer = answer == controller.correctAnswer.value;

              return Padding(
                padding: EdgeInsets.only(right: horizontalSpacing),
                child: GestureDetector(
                  onTap: () {
                    if (!hasAnswered) {
                      controller.selectAnswer(answer);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..scale(isSelected ? 1.1 : 1.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Boggy background
                        Image.asset(
                          'assets/images/simple_math/boggy.png',
                          width: carriageSize,
                          height: carriageSize,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Error loading boggy.png: $error');
                            return Container(
                              width: carriageSize,
                              height: carriageSize,
                              decoration: BoxDecoration(
                                color: _getCarriageColor(index),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                            );
                          },
                        ),

                        // Number overlay - CENTERED and BLACK
                        Center(
                          child: Text(
                            '$answer',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 36 : 28, // Slightly larger
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // BLACK COLOR
                              shadows: [
                                Shadow(
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.white.withOpacity(0.5), // White shadow for contrast
                                ),
                              ],
                            ),
                          ),
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
            }),
          ],
        )),
      ),
    );
  }

  Color _getCarriageColor(int index) {
    final colors = [
      const Color(0xFFE74C3C), // Red
      const Color(0xFF3498DB), // Blue
      const Color(0xFF9B59B6), // Purple
      const Color(0xFFF39C12), // Orange
    ];
    return colors[index % colors.length];
  }

  Widget _buildSuccessPopup(SimpleMathController controller, bool isTablet) {
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
                            'Correct answer!',
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

  Widget _buildWrongPopup(SimpleMathController controller, bool isTablet) {
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
      SimpleMathController controller,
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
                            'You solved all problems!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 18 : 14,
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
                          Get.delete<SimpleMathController>();
                          game.overlays.remove('simple_math');
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

class SimpleMathController extends GetxController {
  // Game state
  final RxInt score = 0.obs;
  final RxString currentProblem = ''.obs;
  final RxInt correctAnswer = 0.obs;
  final RxList<int> answerOptions = <int>[].obs;
  final RxInt selectedAnswer = 0.obs;
  final RxBool hasAnswered = false.obs;
  final RxInt currentLevel = 1.obs;
  final RxInt correctAnswersCount = 0.obs;

  // Popup states
  final RxBool showSuccessPopup = false.obs;
  final RxBool showWrongPopup = false.obs;
  final RxBool showCompletionPopup = false.obs;
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;

  final Random random = Random();
  final int totalProblems = 10;

  @override
  void onInit() {
    super.onInit();
    _preloadAudio();
    _generateProblem();
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

  void _generateProblem() {
    // EASIER MATH: Use smaller numbers (1-5 for beginners, max 10)
    int maxNumber = min(5 + currentLevel.value, 10); // Starts at 5, max 10

    // Only use addition for now (easier for kids)
    final operations = ['+'];
    final operation = operations[random.nextInt(operations.length)];

    int num1, num2, answer;

    if (operation == '+') {
      // Addition with small numbers (1-5 to start)
      num1 = random.nextInt(maxNumber) + 1;
      num2 = random.nextInt(maxNumber) + 1;

      // Make sure sum doesn't exceed 10 for easy mode
      if (num1 + num2 > 10 && currentLevel.value < 5) {
        num2 = random.nextInt(5) + 1; // Keep it simple
      }

      answer = num1 + num2;
      currentProblem.value = '$num1 + $num2 = ?';
    } else {
      // Subtraction - ensure positive result and small numbers
      num1 = random.nextInt(maxNumber) + 1;
      num2 = random.nextInt(min(num1, 5)) + 1; // Keep subtraction small
      answer = num1 - num2;
      currentProblem.value = '$num1 - $num2 = ?';
    }

    correctAnswer.value = answer;

    // Generate answer options (4 options total)
    answerOptions.clear();
    answerOptions.add(answer);

    // Add 3 wrong answers (closer to correct answer for kids)
    while (answerOptions.length < 4) {
      int wrongAnswer;
      // Make wrong answers close to the correct one (+/- 1 or 2)
      if (random.nextBool()) {
        wrongAnswer = answer + random.nextInt(2) + 1; // +1 or +2
      } else {
        wrongAnswer = max(0, answer - random.nextInt(2) - 1); // -1 or -2
      }

      if (!answerOptions.contains(wrongAnswer) && wrongAnswer >= 0 && wrongAnswer <= 20) {
        answerOptions.add(wrongAnswer);
      }
    }

    // Shuffle answer options
    answerOptions.shuffle();

    // Reset selection
    selectedAnswer.value = 0;
    hasAnswered.value = false;
  }

  void selectAnswer(int answer) {
    selectedAnswer.value = answer;
    hasAnswered.value = true;

    if (answer == correctAnswer.value) {
      // Correct answer
      score.value += 10;
      correctAnswersCount.value++;
      _playSuccessSound();
      _showSuccessPopup();

      // Check if game is complete
      if (correctAnswersCount.value >= totalProblems) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          closeSuccessPopup();
          Future.delayed(const Duration(milliseconds: 300), () {
            _showCompletionPopup();
            _playCelebrationSound();
          });
        });
      } else {
        // Generate new problem after popup
        Future.delayed(const Duration(milliseconds: 1200), () {
          closeSuccessPopup();
          currentLevel.value++;
          _generateProblem();
        });
      }
    } else {
      // Wrong answer
      if (score.value > 0) {
        score.value -= 5;
      }
      _playWrongSound();
      _showWrongPopup();

      // Hide wrong popup and show next problem
      Future.delayed(const Duration(milliseconds: 1200), () {
        closeWrongPopup();
        _generateProblem();
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

    // Award coins
    final coinController = Get.find<CoinController>();
    coinController.addCoins(5);
  }

  void _animatePopupIn() {
    popupScale.value = 0.3;
    popupOpacity.value = 0.0;

    final duration = 400;
    final steps = 25;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (showSuccessPopup.value || showWrongPopup.value || showCompletionPopup.value) {
          final progress = i / steps;
          final easeProgress = 1 - (1 - progress) * (1 - progress);
          popupScale.value = 0.3 + (0.7 * easeProgress);
          popupOpacity.value = progress;
        }
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
    correctAnswersCount.value = 0;
    currentLevel.value = 1;
    closeCompletionPopup();
    _generateProblem();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
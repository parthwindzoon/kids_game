// lib/game/overlay/animal_quiz_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import '../../controllers/animal_quiz_controller.dart';

class AnimalQuizOverlay extends StatelessWidget {
  final TiledGame game;

  const AnimalQuizOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnimalQuizController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1a2332),
            const Color(0xFF2d3e50),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern overlay (optional - matches the mountain pattern in design)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/animal_quiz/background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          Stack(
            children: [
              // Back Button (top-left)
              Positioned(
                top: isTablet ? 20 : 10,
                left: isTablet ? 20 : 10,
                child: GestureDetector(
                  onTap: () {
                    controller.dispose();
                    Get.delete<AnimalQuizController>();
                    game.overlays.remove('animal_quiz');
                    game.overlays.add('minigames_overlay');
                  },
                  child: Image.asset('assets/images/back_btn.png'),
                ),
              ),

              // Title (top-center)
              Positioned(
                top: isTablet ? 20 : 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Animal Quiz',
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 42 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: const Color(0xFFFF6B6B),
                        ),
                        Shadow(
                          offset: const Offset(0, -2),
                          blurRadius: 4,
                          color: const Color(0xFFFF6B6B),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Score (top-right)
              Positioned(
                top: isTablet ? 20 : 10,
                right: isTablet ? 20 : 10,
                child: Obx(() => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 25 : 20,
                    vertical: isTablet ? 12 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Text(
                    'Score-${controller.score.value}',
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )),
              ),

              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isTablet ? 100 : 80),

                    // Question Text
                    Text(
                      'which animal is this?',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 32 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: isTablet ? 40 : 30),

                    // Game Layout (Animal Image + Options in Grid)
                    Obx(() => _buildGameLayout(controller, isTablet)),

                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),

          // Success Popup
          Obx(() {
            if (!controller.showSuccessPopup.value) {
              return const SizedBox.shrink();
            }
            return _buildSuccessPopup(controller, isTablet);
          }),

          // Wrong Popup
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

  Widget _buildGameLayout(AnimalQuizController controller, bool isTablet) {
    final animalImageSize = isTablet ? 220.0 : 180.0;
    final optionWidth = isTablet ? 180.0 : 140.0;
    final optionHeight = isTablet ? 65.0 : 55.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Side - Animal Image
          Container(
            width: animalImageSize,
            height: animalImageSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 15),
              child: Image.asset(
                controller.currentQuestion.correctAnimal.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.pets,
                    size: animalImageSize * 0.5,
                    color: Colors.grey.shade400,
                  );
                },
              ),
            ),
          ),

          SizedBox(width: isTablet ? 40 : 30),

          // Right Side - Options in 2x2 Grid
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row - 2 options
              Row(
                children: [
                  _buildOptionButton(
                    controller.currentQuestion.options[0],
                    controller,
                    optionWidth,
                    optionHeight,
                    isTablet,
                  ),
                  SizedBox(width: isTablet ? 15 : 12),
                  _buildOptionButton(
                    controller.currentQuestion.options[1],
                    controller,
                    optionWidth,
                    optionHeight,
                    isTablet,
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 15 : 12),

              // Bottom Row - 2 options
              Row(
                children: [
                  _buildOptionButton(
                    controller.currentQuestion.options[2],
                    controller,
                    optionWidth,
                    optionHeight,
                    isTablet,
                  ),
                  SizedBox(width: isTablet ? 15 : 12),
                  _buildOptionButton(
                    controller.currentQuestion.options[3],
                    controller,
                    optionWidth,
                    optionHeight,
                    isTablet,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
      String option,
      AnimalQuizController controller,
      double width,
      double height,
      bool isTablet,
      ) {
    final isSelected = controller.selectedAnswer.value == option;
    final isCorrect = option == controller.currentQuestion.correctAnimal.name;
    final showResult = controller.isAnswered.value;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.transparent;

    if (showResult) {
      if (isSelected && isCorrect) {
        // Correct answer - Green
        backgroundColor = const Color(0xFF4CAF50);
      } else if (isSelected && !isCorrect) {
        // Wrong answer - Red
        backgroundColor = const Color(0xFFFF0000);
      }
    }

    return GestureDetector(
      onTap: () => controller.selectAnswer(option),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            option,
            style: TextStyle(
              fontFamily: 'AkayaKanadaka',
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: showResult && isSelected ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPopup(AnimalQuizController controller, bool isTablet) {
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
                            Icons.check_circle,
                            color: Colors.green,
                            size: isTablet ? 60 : 50,
                          ),
                          SizedBox(height: isTablet ? 15 : 10),
                          Text(
                            'Correct!',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWrongPopup(AnimalQuizController controller, bool isTablet) {
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
                            'Try Again!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFDC3545),
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

  Widget _buildCompletionPopup(
      AnimalQuizController controller,
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
                            'Quiz Complete!',
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
                          Get.delete<AnimalQuizController>();
                          game.overlays.remove('animal_quiz');
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
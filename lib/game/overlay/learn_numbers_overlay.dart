// lib/game/overlay/learn_numbers_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

class LearnNumbersOverlay extends StatelessWidget {
  final TiledGame game;

  const LearnNumbersOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LearnNumbersController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/number_learning/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Main Content - Number Grid
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 60 : 40,
                  vertical: isTablet ? 40 : 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isTablet ? 60 : 40),
                    // Row 1: 1 to 10
                    _buildNumberRow(
                      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                      isTablet,
                      controller,
                    ),
                    SizedBox(height: isTablet ? 20 : 15),
                    // Row 2: 11 to 20
                    _buildNumberRow(
                      [11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
                      isTablet,
                      controller,
                    ),
                    SizedBox(height: isTablet ? 20 : 15),
                    // Row 3: 21 to 30
                    _buildNumberRow(
                      [21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
                      isTablet,
                      controller,
                    ),
                    SizedBox(height: isTablet ? 20 : 15),
                    // Row 4: 31 to 40
                    _buildNumberRow(
                      [31, 32, 33, 34, 35, 36, 37, 38, 39, 40],
                      isTablet,
                      controller,
                    ),
                    SizedBox(height: isTablet ? 40 : 20),
                  ],
                ),
              ),
            ),
          ),

          // Title at the top
          Positioned(
            top: isTablet ? 20 : 10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Number Learning',
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
            ),
          ),

          // Back Button (top-left corner)
          Positioned(
            top: isTablet ? 20 : 10,
            left: isTablet ? 20 : 10,
            child: GestureDetector(
              onTap: () {
                controller.dispose();
                Get.delete<LearnNumbersController>();
                game.overlays.remove('learn_numbers');
                game.overlays.add('minigames_overlay');
              },
              child: Image.asset('assets/images/back_btn.png'),
            ),
          ),

          // Number Detail Popup
          Obx(() {
            if (controller.selectedNumber.value == 0) {
              return const SizedBox.shrink();
            }
            return _buildNumberPopup(controller, isTablet);
          }),
        ],
      ),
    );
  }

  Widget _buildNumberRow(
      List<int> numbers,
      bool isTablet,
      LearnNumbersController controller,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers
          .map((number) => _buildNumberCircle(number, isTablet, controller))
          .toList(),
    );
  }

  Widget _buildNumberCircle(
      int number,
      bool isTablet,
      LearnNumbersController controller,
      ) {
    return GestureDetector(
      onTap: () {
        controller.showNumberDetail(number);
      },
      child: Container(
        width: isTablet ? 90 : 70,
        height: isTablet ? 90 : 70,
        margin: EdgeInsets.all(isTablet ? 5 : 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circle background image
            Image.asset(
              'assets/images/number_learning/circle.png',
              width: isTablet ? 90 : 70,
              height: isTablet ? 90 : 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback circle if image not found
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue.shade300,
                      width: 3,
                    ),
                  ),
                );
              },
            ),
            // Number text
            Text(
              '$number',
              style: TextStyle(
                fontFamily: 'AkayaKanadaka',
                fontSize: isTablet ? 36 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPopup(LearnNumbersController controller, bool isTablet) {
    final number = controller.selectedNumber.value;

    return Obx(() {
      final scale = controller.popupScale.value;
      final opacity = controller.popupOpacity.value;

      return GestureDetector(
        onTap: () {
          // Close when tapping outside
          controller.closePopup();
        },
        child: Container(
          color: Colors.black.withOpacity(0.5 * opacity),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping inside popup
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: isTablet ? 600 : 450,
                    height: isTablet ? 400 : 320,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/overlays/Group 67.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Close button (top-right)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              controller.closePopup();
                            },
                            child: Image.asset(
                              'assets/images/overlays/Group 86.png',
                              width: isTablet ? 60 : 50,
                              height: isTablet ? 60 : 50,
                            ),
                          ),
                        ),

                        // Number Display
                        Positioned(
                          top: isTablet ? 80 : 60,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              '$number',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 120 : 90,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(3, 3),
                                    blurRadius: 5,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Number word
                        Positioned(
                          bottom: isTablet ? 80 : 60,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              controller.getNumberWord(number),
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 32 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
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
          ),
        ),
      );
    });
  }
}

class LearnNumbersController extends GetxController {
  final selectedNumber = 0.obs;
  final popupScale = 0.0.obs;
  final popupOpacity = 0.0.obs;

  // Map of numbers to words
  final Map<int, String> numberWords = {
    1: 'One', 2: 'Two', 3: 'Three', 4: 'Four', 5: 'Five',
    6: 'Six', 7: 'Seven', 8: 'Eight', 9: 'Nine', 10: 'Ten',
    11: 'Eleven', 12: 'Twelve', 13: 'Thirteen', 14: 'Fourteen', 15: 'Fifteen',
    16: 'Sixteen', 17: 'Seventeen', 18: 'Eighteen', 19: 'Nineteen', 20: 'Twenty',
    21: 'Twenty One', 22: 'Twenty Two', 23: 'Twenty Three', 24: 'Twenty Four', 25: 'Twenty Five',
    26: 'Twenty Six', 27: 'Twenty Seven', 28: 'Twenty Eight', 29: 'Twenty Nine', 30: 'Thirty',
    31: 'Thirty One', 32: 'Thirty Two', 33: 'Thirty Three', 34: 'Thirty Four', 35: 'Thirty Five',
    36: 'Thirty Six', 37: 'Thirty Seven', 38: 'Thirty Eight', 39: 'Thirty Nine', 40: 'Forty',
  };

  @override
  void onInit() {
    super.onInit();
    _preloadAudio();
  }

  // Preload audio files
  Future<void> _preloadAudio() async {
    try {
      final audioFiles = <String>[];
      for (int i = 1; i <= 40; i++) {
        audioFiles.add('numbers/$i.mp3');
      }
      await FlameAudio.audioCache.loadAll(audioFiles);
      print('✅ All number audio files preloaded successfully');
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  String getNumberWord(int number) {
    return numberWords[number] ?? '$number';
  }

  void showNumberDetail(int number) {
    selectedNumber.value = number;
    _animatePopupIn();
    _playNumberAudio(number);
  }

  void closePopup() {
    _animatePopupOut();
  }

  // Play audio for the selected number
  Future<void> _playNumberAudio(int number) async {
    try {
      final audioFile = 'numbers/$number.mp3';
      print('🔊 Playing audio: $audioFile');
      await FlameAudio.play(audioFile);
    } catch (e) {
      print('⚠️ Error playing audio for $number: $e');
    }
  }

  void _animatePopupIn() {
    // Reset values
    popupScale.value = 0.3;
    popupOpacity.value = 0.0;

    // Animate scale and opacity
    final duration = 400;
    final steps = 30;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (selectedNumber.value != 0) {
          final progress = i / steps;
          // Ease out animation
          final easeProgress = 1 - (1 - progress) * (1 - progress);
          popupScale.value = 0.3 + (0.7 * easeProgress);
          popupOpacity.value = progress;
        }
      });
    }
  }

  void _animatePopupOut() {
    final duration = 300;
    final steps = 20;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        final progress = i / steps;
        popupScale.value = 1.0 - (0.3 * progress);
        popupOpacity.value = 1.0 - progress;

        if (i == steps) {
          selectedNumber.value = 0;
        }
      });
    }
  }

  @override
  void dispose() {
    // Clean up audio cache if needed
    super.dispose();
  }
}
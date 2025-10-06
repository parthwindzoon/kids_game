// lib/game/overlay/learn_alphabets_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

class LearnAlphabetsOverlay extends StatelessWidget {
  final TiledGame game;

  const LearnAlphabetsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LearnAlphabetsController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Main Content - Alphabet Grid
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
                      // Row 1: A to H
                      _buildAlphabetRow(
                        ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
                        isTablet,
                        controller,
                      ),
                      SizedBox(height: isTablet ? 20 : 15),
                      // Row 2: I to P
                      _buildAlphabetRow(
                        ['I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'],
                        isTablet,
                        controller,
                      ),
                      SizedBox(height: isTablet ? 20 : 15),
                      // Row 3: Q to X
                      _buildAlphabetRow(
                        ['Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X'],
                        isTablet,
                        controller,
                      ),
                      SizedBox(height: isTablet ? 20 : 15),
                      // Row 4: Y, Z (centered)
                      _buildAlphabetRow(
                        ['Y', 'Z'],
                        isTablet,
                        controller,
                        centered: true,
                      ),
                      SizedBox(height: isTablet ? 40 : 20),
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
                  Get.delete<LearnAlphabetsController>();
                  game.overlays.remove('learn_alphabets');
                  game.overlays.add('minigames_overlay');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 15,
                    vertical: isTablet ? 10 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: Colors.grey.shade700,
                        size: isTablet ? 24 : 18,
                      ),
                      SizedBox(width: isTablet ? 8 : 5),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontFamily: 'AkayaKanadaka',
                          fontSize: isTablet ? 18 : 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Letter Detail Popup
            Obx(() {
              if (controller.selectedLetter.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildLetterPopup(controller, isTablet);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAlphabetRow(
      List<String> letters,
      bool isTablet,
      LearnAlphabetsController controller, {
        bool centered = false,
      }) {
    return Row(
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
      children: letters
          .map((letter) => _buildAlphabetBlock(letter, isTablet, controller))
          .toList(),
    );
  }

  Widget _buildAlphabetBlock(
      String letter,
      bool isTablet,
      LearnAlphabetsController controller,
      ) {
    return GestureDetector(
      onTap: () {
        controller.showLetterDetail(letter);
      },
      child: Container(
        width: isTablet ? 90 : 50,
        height: isTablet ? 90 : 50,
        margin: EdgeInsets.all(isTablet ? 8 : 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          // borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            'assets/images/alphabets/$letter.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              final colors = [
                Colors.red.shade300,
                Colors.yellow.shade300,
                Colors.brown.shade300,
                Colors.grey.shade300,
                Colors.blue.shade300,
                Colors.green.shade300,
                Colors.lime.shade300,
                Colors.orange.shade300,
              ];
              final colorIndex = letter.codeUnitAt(0) % colors.length;

              return Container(
                decoration: BoxDecoration(
                  color: colors[colorIndex],
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${letter}${letter.toLowerCase()}',
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 36 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLetterPopup(LearnAlphabetsController controller, bool isTablet) {
    final letter = controller.selectedLetter.value;

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
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/images/overlays/Group 67.png'),
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

                        // Image only - FULL SIZE (image already contains letter and word)
                        Positioned(
                          top: isTablet ? 40 : 30,
                          bottom: isTablet ? 40 : 30,
                          left: isTablet ? 80 : 60,
                          right: isTablet ? 80 : 60,
                          child: Center(
                            child: Image.asset(
                              'assets/images/alphabet_words/${letter.toLowerCase()}${letter.toLowerCase()}.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback icon if image not found
                                return Icon(
                                  Icons.image,
                                  size: isTablet ? 200 : 160,
                                  color: Colors.grey.shade400,
                                );
                              },
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

class LearnAlphabetsController extends GetxController {
  final selectedLetter = ''.obs;
  final popupScale = 0.0.obs;
  final popupOpacity = 0.0.obs;

  // Map of letters to words - based on your reference image
  final Map<String, String> letterWords = {
    'A': 'Apple',
    'B': 'Banana',
    'C': 'Cat',
    'D': 'Dog',
    'E': 'Elephant',
    'F': 'Fox',
    'G': 'Giraffe',
    'H': 'Horse',
    'I': 'Icecream',
    'J': 'Jug',
    'K': 'Kite',
    'L': 'Lion',
    'M': 'Mango',
    'N': 'Notebook',
    'O': 'Owl',
    'P': 'Pig',
    'Q': 'Queen',
    'R': 'Rabbit',
    'S': 'Strawberry',
    'T': 'Tree',
    'U': 'Umbrella',
    'V': 'Violin',
    'W': 'Watermelon',
    'X': 'Xylophone',
    'Y': 'Yoyo',
    'Z': 'Zebra',
  };

  @override
  void onInit() {
    super.onInit();
    _preloadAudio();
  }

  // Preload all audio files for better performance
  Future<void> _preloadAudio() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'alphabets/A for Apple.mp3',
        'alphabets/B for Banana.mp3',
        'alphabets/C for Cat.mp3',
        'alphabets/D for Dog.mp3',
        'alphabets/E for Elephant.mp3',
        'alphabets/F for Fox.mp3',
        'alphabets/G for Giraffe.mp3',
        'alphabets/H for Horse.mp3',
        'alphabets/I for Icecream.mp3',
        'alphabets/J for Jug.mp3',
        'alphabets/K for Kite.mp3',
        'alphabets/L for Lion.mp3',
        'alphabets/M for Mango.mp3',
        'alphabets/N for Notebook.mp3',
        'alphabets/O for Owl.mp3',
        'alphabets/P for Pig.mp3',
        'alphabets/Q for Queen.mp3',
        'alphabets/R for Rabbit.mp3',
        'alphabets/S for Strawberry.mp3',
        'alphabets/T for Tree.mp3',
        'alphabets/U for Umbrella.mp3',
        'alphabets/V for Violin.mp3',
        'alphabets/W for Watermelon.mp3',
        'alphabets/X for Xylophone.mp3',
        'alphabets/Y for Yoyo.mp3',
        'alphabets/Z for Zebra.mp3',
      ]);
      print('✅ All alphabet audio files preloaded successfully');
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  String getWordForLetter(String letter) {
    return letterWords[letter] ?? letter;
  }

  void showLetterDetail(String letter) {
    selectedLetter.value = letter;
    _animatePopupIn();
    _playLetterAudio(letter);
  }

  void closePopup() {
    _animatePopupOut();
  }

  // Play audio for the selected letter
  Future<void> _playLetterAudio(String letter) async {
    try {
      final word = getWordForLetter(letter);
      final audioFile = 'alphabets/$letter for $word.mp3';

      print('🔊 Playing audio: $audioFile');
      await FlameAudio.play(audioFile);
    } catch (e) {
      print('⚠️ Error playing audio for $letter: $e');
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
        if (selectedLetter.value.isNotEmpty) {
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
          selectedLetter.value = '';
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
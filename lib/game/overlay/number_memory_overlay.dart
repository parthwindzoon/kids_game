// lib/game/overlay/number_memory_overlay.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

import '../../controllers/coin_controller.dart';

class NumberMemoryOverlay extends StatelessWidget {
  final TiledGame game;

  const NumberMemoryOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NumberMemoryController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/number_memory/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Main Content
          // Replace your main content with this exact layout
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title - Red outline text on wood background
                Text(
                  'Number Memory',
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

                SizedBox(height: isTablet ? 20 : 15),

                // Subtitle - White text
                Text(
                  'Match the number pairs!',
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 28 : 22,
                    fontStyle: FontStyle.italic,
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

                SizedBox(height: isTablet ? 40 : 30),

                // Game Grid (no extra background)
                _buildGameGrid(controller, isTablet),

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
                Get.delete<NumberMemoryController>();
                game.overlays.remove('number_memory');
                game.overlays.add('minigames_overlay');

                game.resumeBackgroundMusic();
              },
              child: Image.asset('assets/images/back_btn.png'),
            ),
          ),

          Positioned(
            top: isTablet ? 20 : 15,
            right: isTablet ? 20 : 15,
            child: Obx(() => Container(
              width: isTablet ? 200 : 160,
              height: isTablet ? 60 : 50,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/score_bg.png'), // Your score background
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

  Widget _buildGameGrid(NumberMemoryController controller, bool isTablet) {
    final cardSize = isTablet ? 95.0 : 75.0;
    final horizontalSpacing = isTablet ? 8.0 : 6.0;
    final verticalSpacing = isTablet ? 10.0 : 8.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // First Row - 6 cards
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(controller, 0, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 1, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 2, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 3, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 4, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 5, cardSize),
          ],
        ),

        SizedBox(height: verticalSpacing),

        // Second Row - 6 cards
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(controller, 6, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 7, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 8, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 9, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 10, cardSize),
            SizedBox(width: horizontalSpacing),
            _buildCard(controller, 11, cardSize),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(NumberMemoryController controller, int index, double cardSize) {
    return Obx(() {
      final card = controller.cards[index];
      final isFlipped = card.isFlipped.value;
      final isMatched = card.isMatched.value;

      return GestureDetector(
        onTap: () {
          if (!isFlipped && !isMatched && !controller.isProcessing.value) {
            controller.flipCard(index);
          }
        },
        child: Container(
          width: cardSize,
          height: cardSize,
          child: Stack(
            children: [
              // Simple flip without inversion
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: isFlipped || isMatched
                    ? _buildCardBack(card.number, isMatched, cardSize)
                    : _buildCardFront(cardSize),
              ),

              // Matched overlay
              if (isMatched)
                Container(
                  width: cardSize,
                  height: cardSize,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green,
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCardFront(double cardSize) {
    return Container(
      key: const ValueKey('front'),
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            fontFamily: 'AkayaKanadaka',
            fontSize: cardSize * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(int number, bool isMatched, double cardSize) {
    return Container(
      key: ValueKey('back-$number'),
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isMatched
            ? Border.all(color: Colors.green, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontFamily: 'AkayaKanadaka',
            fontSize: cardSize * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionPopup(
      NumberMemoryController controller,
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
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: isTablet ? 80 : 60,
                          ),
                          SizedBox(height: isTablet ? 20 : 15),
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
                          Text(
                            'Score: ${controller.score.value}',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E88E5),
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
                          Get.delete<NumberMemoryController>();
                          game.overlays.remove('number_memory');
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

class NumberMemoryController extends GetxController {
  final RxList<MemoryCard> cards = <MemoryCard>[].obs;
  final RxInt score = 0.obs;
  final RxInt flippedCards = 0.obs;
  final RxBool isProcessing = false.obs;
  final RxBool showCompletionPopup = false.obs;
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;

  List<int> flippedIndices = [];
  int matchedPairs = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
    _preloadAudio();
  }

  void _initializeGame() {
    // Create pairs of numbers (1-6, each appearing twice)
    List<int> numbers = [];
    for (int i = 1; i <= 6; i++) {
      numbers.add(i);
      numbers.add(i);
    }

    // Shuffle the numbers
    numbers.shuffle();

    // Create cards
    cards.clear();
    for (int i = 0; i < 12; i++) {
      cards.add(MemoryCard(
        id: i,
        number: numbers[i],
        isFlipped: false.obs,
        isMatched: false.obs,
      ));
    }

    score.value = 0;
    flippedCards.value = 0;
    matchedPairs = 0;
    flippedIndices.clear();
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

  void flipCard(int index) {
    if (isProcessing.value || flippedCards.value >= 2) return;

    final card = cards[index];
    if (card.isFlipped.value || card.isMatched.value) return;

    // Flip the card
    card.isFlipped.value = true;
    flippedIndices.add(index);
    flippedCards.value++;

    if (flippedCards.value == 2) {
      isProcessing.value = true;
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      final firstCard = cards[flippedIndices[0]];
      final secondCard = cards[flippedIndices[1]];

      if (firstCard.number == secondCard.number) {
        // Match found!
        firstCard.isMatched.value = true;
        secondCard.isMatched.value = true;
        matchedPairs++;
        score.value += 10;
        _playSuccessSound();

        // Check if game is complete
        if (matchedPairs == 6) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _showCompletionPopup();
            _playCelebrationSound();
          });
        }
      } else {
        // No match, flip cards back
        firstCard.isFlipped.value = false;
        secondCard.isFlipped.value = false;
      }

      // Reset for next turn
      flippedIndices.clear();
      flippedCards.value = 0;
      isProcessing.value = false;
    });
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
    closeCompletionPopup();
    _initializeGame();
  }
}

class MemoryCard {
  final int id;
  final int number;
  final RxBool isFlipped;
  final RxBool isMatched;

  MemoryCard({
    required this.id,
    required this.number,
    required this.isFlipped,
    required this.isMatched,
  });
}
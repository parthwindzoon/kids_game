// lib/game/overlay/pop_balloon_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flame_audio/flame_audio.dart';

import 'coin_controller.dart';

class PopBalloonController extends GetxController with GetSingleTickerProviderStateMixin {
  // Game state
  final RxInt score = 0.obs;
  final RxInt targetScore = 10.obs;
  final RxString currentTask = ''.obs;
  final RxString targetLetter = ''.obs;
  final RxBool isGameComplete = false.obs;
  final RxBool showCompletionPopup = false.obs;

  // Popup animation
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;

  // Balloons list
  final RxList<BalloonData> balloons = <BalloonData>[].obs;

  // Available balloon colors and letters
  final List<String> balloonColors = [
    'yellow_baloon.png',
    'red_baloon.png',
    'green_baloon.png',
    'blue_baloon.png',
    'orange_baloon.png',
  ];

  final List<String> availableLetters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
    'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  final List<String> availableNumbers = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'
  ];

  late AnimationController animationController;
  final Random random = Random();

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _initializeGame();
    _preloadAudio();
  }

  Future<void> _preloadAudio() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'balloon_pop.mp3',
        'success.mp3',
        'celebration.mp3',
      ]);
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  void _initializeGame() {
    // Generate a random task
    _generateNewTask();
    // Create initial balloons
    _generateBalloons();
    // Start balloon animation
    _startBalloonAnimation();
  }

  void _generateNewTask() {
    final taskTypes = ['letter', 'number'];
    final taskType = taskTypes[random.nextInt(taskTypes.length)];

    if (taskType == 'letter') {
      targetLetter.value = availableLetters[random.nextInt(availableLetters.length)];
      currentTask.value = 'Pop all balloons with letter "${targetLetter.value}"';
    } else {
      targetLetter.value = availableNumbers[random.nextInt(availableNumbers.length)];
      currentTask.value = 'Pop all balloons with number "${targetLetter.value}"';
    }
  }

  void _generateBalloons() {
    balloons.clear();
    final screenWidth = Get.width;
    final screenHeight = Get.height;

    // Create 15-20 balloons (increased number)
    final balloonCount = 15 + random.nextInt(6);

    // Ensure at least 4-6 target balloons exist
    final targetCount = 4 + random.nextInt(3);
    int targetCreated = 0;

    for (int i = 0; i < balloonCount; i++) {
      String letter;
      bool isTarget = false;

      // Ensure we have enough target balloons
      if (targetCreated < targetCount && (i < targetCount || random.nextBool())) {
        letter = targetLetter.value;
        isTarget = true;
        targetCreated++;
      } else {
        // Create random non-target letter/number
        if (targetLetter.value.contains(RegExp(r'[A-Z]'))) {
          // If target is letter, create other letters
          do {
            letter = availableLetters[random.nextInt(availableLetters.length)];
          } while (letter == targetLetter.value);
        } else {
          // If target is number, create other numbers
          do {
            letter = availableNumbers[random.nextInt(availableNumbers.length)];
          } while (letter == targetLetter.value);
        }
      }

      final balloon = BalloonData(
        id: i.toString(),
        letter: letter,
        isTarget: isTarget,
        colorAsset: balloonColors[random.nextInt(balloonColors.length)],
        // Random position with more spacing
        x: 30 + random.nextDouble() * (screenWidth - 120),
        y: screenHeight * 0.25 + random.nextDouble() * (screenHeight * 0.5),
        // Random floating parameters
        floatingOffset: random.nextDouble() * 20 - 10,
        floatingSpeed: 0.6 + random.nextDouble() * 0.6,
        isPopped: false,
      );

      balloons.add(balloon);
    }
  }

  void _startBalloonAnimation() {
    animationController.repeat();

    // Update balloon positions for floating effect
    void updateBalloons() {
      if (isClosed || isGameComplete.value) return;

      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

      for (var balloon in balloons) {
        if (!balloon.isPopped) {
          balloon.currentY = balloon.y +
              sin(currentTime * balloon.floatingSpeed + balloon.floatingOffset) * 15;
        }
      }
      balloons.refresh();

      Future.delayed(const Duration(milliseconds: 50), updateBalloons);
    }

    updateBalloons();
  }

  void popBalloon(String balloonId) async {
    final balloonIndex = balloons.indexWhere((b) => b.id == balloonId);
    if (balloonIndex == -1) return;

    final balloon = balloons[balloonIndex];
    if (balloon.isPopped) return;

    // Mark balloon as popped
    balloon.isPopped = true;
    balloons.refresh();

    // Play pop sound
    _playPopSound();

    // Check if it was a target balloon
    if (balloon.isTarget) {
      score.value++;

      // Check if task is complete
      final remainingTargets = balloons.where((b) => b.isTarget && !b.isPopped).length;
      if (remainingTargets == 0) {
        _completeGame();
      }
    }
  }

  Future<void> _playPopSound() async {
    try {
      await FlameAudio.play('balloon_pop.mp3');
    } catch (e) {
      print('⚠️ Error playing pop sound: $e');
    }
  }

  Future<void> _playCelebrationSound() async {
    try {
      await FlameAudio.play('celebration.mp3');
    } catch (e) {
      print('⚠️ Error playing celebration sound: $e');
    }
  }

  void _completeGame() {
    isGameComplete.value = true;
    animationController.stop();

    // Add bonus points (10 points as requested)
    score.value += 10;

    Future.delayed(const Duration(milliseconds: 500), () {
      _showCompletionPopup();
      _playCelebrationSound();
    });
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
    score.value = 0;
    isGameComplete.value = false;
    closeCompletionPopup();
    _generateNewTask();
    _generateBalloons();
    _startBalloonAnimation();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

class BalloonData {
  final String id;
  final String letter;
  final bool isTarget;
  final String colorAsset;
  final double x;
  final double y;
  double currentY;
  final double floatingOffset;
  final double floatingSpeed;
  bool isPopped;

  BalloonData({
    required this.id,
    required this.letter,
    required this.isTarget,
    required this.colorAsset,
    required this.x,
    required this.y,
    required this.floatingOffset,
    required this.floatingSpeed,
    required this.isPopped,
  }) : currentY = y;
}
// lib/controllers/color_matching_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flame_audio/flame_audio.dart';

import 'coin_controller.dart';

class ColorMatchingController extends GetxController {
  // Game state
  final RxInt score = 0.obs;
  final Rx<Color> targetColor = const Color(0xFF3498DB).obs;
  final RxBool showCompletionPopup = false.obs;
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;
  final RxInt correctAnswers = 0.obs;

  // Success popup
  final RxBool showSuccessPopup = false.obs;
  final RxDouble successPopupScale = 0.0.obs;
  final RxDouble successPopupOpacity = 0.0.obs;

  // Wrong answer popup
  final RxBool showWrongPopup = false.obs;
  final RxDouble wrongPopupScale = 0.0.obs;
  final RxDouble wrongPopupOpacity = 0.0.obs;

  // Available colors for the game
  final List<Color> availableColors = [
    const Color(0xFFE74C3C), // Red
    const Color(0xFF3498DB), // Blue
    const Color(0xFF2ECC71), // Green
    const Color(0xFFF1C40F), // Yellow
    const Color(0xFFE67E22), // Orange
    const Color(0xFF9B59B6), // Purple
    const Color(0xFFE91E63), // Pink/Magenta
    const Color(0xFF00BCD4), // Cyan
  ];

  final List<String> _audioFiles = [
    'success.mp3',
    'wrong.mp3',
    'celebration.mp3',
  ];

  final int totalRounds = 10; // Complete game after 10 correct answers
  final Random random = Random();

  @override
  void onInit() {
    super.onInit();
    _preloadAudio();
    _generateNewColor();
  }

  Future<void> _preloadAudio() async {
    try {
      await FlameAudio.audioCache.loadAll(_audioFiles);
      print('✅ Audio files preloaded successfully');
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  void _generateNewColor() {
    targetColor.value = availableColors[random.nextInt(availableColors.length)];
  }

  void selectColor(Color selectedColor) {
    if (_colorsMatch(selectedColor, targetColor.value)) {
      // Correct answer
      score.value += 10;
      correctAnswers.value++;
      _playSuccessSound();
      _showSuccessPopup();

      // Check if game is complete
      if (correctAnswers.value >= totalRounds) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          closeSuccessPopup();
          Future.delayed(const Duration(milliseconds: 300), () {
            _showCompletionPopup();
            _playCelebrationSound();
          });
        });
      } else {
        // Generate new color after popup
        Future.delayed(const Duration(milliseconds: 1200), () {
          closeSuccessPopup();
          _generateNewColor();
        });
      }
    } else {
      // Wrong answer
      if (score.value > 0) {
        score.value -= 5;
      }
      _playWrongSound();
      _showWrongPopup();

      // Hide wrong popup after delay
      Future.delayed(const Duration(milliseconds: 1200), () {
        closeWrongPopup();
      });
    }
  }

  bool _colorsMatch(Color color1, Color color2) {
    return color1.value == color2.value;
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
    _animateSuccessPopupIn();
  }

  void _showWrongPopup() {
    showWrongPopup.value = true;
    _animateWrongPopupIn();
  }

  void _showCompletionPopup() {
    showCompletionPopup.value = true;
    _animatePopupIn();

    final coinController = Get.find<CoinController>();
    coinController.addCoins(5);
  }

  void _animateSuccessPopupIn() {
    successPopupScale.value = 0.3;
    successPopupOpacity.value = 0.0;

    final duration = 400;
    final steps = 25;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (showSuccessPopup.value) {
          final progress = i / steps;
          final easeProgress = 1 - (1 - progress) * (1 - progress);
          successPopupScale.value = 0.3 + (0.7 * easeProgress);
          successPopupOpacity.value = progress;
        }
      });
    }
  }

  void _animateWrongPopupIn() {
    wrongPopupScale.value = 0.3;
    wrongPopupOpacity.value = 0.0;

    final duration = 400;
    final steps = 25;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (showWrongPopup.value) {
          final progress = i / steps;
          final easeProgress = 1 - (1 - progress) * (1 - progress);
          wrongPopupScale.value = 0.3 + (0.7 * easeProgress);
          wrongPopupOpacity.value = progress;
        }
      });
    }
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
    correctAnswers.value = 0;
    closeCompletionPopup();
    _generateNewColor();
  }

  @override
  void onClose() {

    for (final file in _audioFiles) {
      FlameAudio.audioCache.clear(file);
    }
    print('✅ Cleared color_matching audio cache on close');
    super.onClose();
  }
}
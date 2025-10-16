// lib/controllers/lucky_spin_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flame_audio/flame_audio.dart';

class LuckySpinController extends GetxController with GetSingleTickerProviderStateMixin {
  // Animation controller for wheel spinning
  late AnimationController animationController;
  late Animation<double> spinAnimation;

  // Game state
  final RxBool isSpinning = false.obs;
  final RxDouble wheelRotation = 0.0.obs;
  final RxInt playerCoins = 1000.obs; // Starting coins
  final RxBool showResultPopup = false.obs;
  final RxString lastWonPrize = ''.obs;
  final RxInt lastWonAmount = 0.obs;

  // Prize configuration - 8 segments
  final List<SpinPrize> prizes = [
    SpinPrize(name: '100 Coins', type: PrizeType.coins, amount: 100, probability: 0.08), // 8%
    SpinPrize(name: 'Try Tomorrow', type: PrizeType.tryTomorrow, amount: 0, probability: 0.25), // 25%
    SpinPrize(name: '50 Coins', type: PrizeType.coins, amount: 50, probability: 0.12), // 12%
    SpinPrize(name: 'Bonus Spin', type: PrizeType.bonusSpin, amount: 0, probability: 0.15), // 15%
    SpinPrize(name: '25 Coins', type: PrizeType.coins, amount: 25, probability: 0.15), // 15%
    SpinPrize(name: 'Companion', type: PrizeType.companion, amount: 0, probability: 0.0005), // 0.05%
    SpinPrize(name: '10 Coins', type: PrizeType.coins, amount: 10, probability: 0.12), // 12%
    SpinPrize(name: '5 Coins', type: PrizeType.coins, amount: 5, probability: 0.1295), // 12.95%
  ];

  final Random random = Random();
  int selectedSegment = 0;

  @override
  void onInit() {
    super.onInit();

    // Initialize animation controller
    animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _preloadAudio();
  }

  Future<void> _preloadAudio() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'spin_wheel.mp3',
        'success.mp3',
        'celebration.mp3',
      ]);
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  // Main spin function
  Future<void> spinWheel() async {
    if (isSpinning.value) return;

    isSpinning.value = true;
    _playSpinSound();

    // Select prize based on probability
    selectedSegment = _selectPrizeSegment();

    // Calculate target rotation
    final segmentAngle = 360.0 / prizes.length; // 45 degrees per segment
    final targetSegmentCenter = selectedSegment * segmentAngle;

    // Add multiple full rotations + random offset within segment
    final baseRotations = 1800 + random.nextInt(720); // 5-7 full rotations
    final segmentOffset = random.nextDouble() * segmentAngle - (segmentAngle / 2);
    final finalRotation = baseRotations + targetSegmentCenter + segmentOffset;

    // Create spinning animation
    spinAnimation = Tween<double>(
      begin: wheelRotation.value,
      end: wheelRotation.value + finalRotation,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    // Listen to animation updates
    spinAnimation.addListener(() {
      wheelRotation.value = spinAnimation.value % 360;
    });

    // Start animation
    animationController.forward().then((_) {
      _handleSpinResult();
    });
  }

  // Select prize segment based on probability
  int _selectPrizeSegment() {
    double randomValue = random.nextDouble();
    double cumulativeProbability = 0.0;

    for (int i = 0; i < prizes.length; i++) {
      cumulativeProbability += prizes[i].probability;
      if (randomValue <= cumulativeProbability) {
        return i;
      }
    }

    // Fallback to last segment
    return prizes.length - 1;
  }

  // Handle the result after spinning
  void _handleSpinResult() {
    final wonPrize = prizes[selectedSegment];
    lastWonPrize.value = wonPrize.name;
    lastWonAmount.value = wonPrize.amount;

    // Apply prize effects
    switch (wonPrize.type) {
      case PrizeType.coins:
        playerCoins.value += wonPrize.amount;
        _playSuccessSound();
        break;
      case PrizeType.companion:
      // TODO: Unlock companion
        _playCelebrationSound();
        break;
      case PrizeType.bonusSpin:
      // Allow another spin
        _playSuccessSound();
        break;
      case PrizeType.tryTomorrow:
      // No reward
        break;
    }

    // Show result popup
    Future.delayed(const Duration(milliseconds: 500), () {
      showResultPopup.value = true;
      isSpinning.value = false;
    });
  }

  // Reset for next spin
  void resetSpin() {
    animationController.reset();
    showResultPopup.value = false;

    // If it was a bonus spin, allow immediate next spin
    if (prizes[selectedSegment].type != PrizeType.bonusSpin) {
      // Could add daily limit logic here
    }
  }

  // Audio functions
  Future<void> _playSpinSound() async {
    try {
      await FlameAudio.play('spin_wheel.mp3');
    } catch (e) {
      print('⚠️ Error playing spin sound: $e');
    }
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

  // Get prize color for UI
  Color getPrizeColor(int index) {
    final colors = [
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4ECDC4), // Cyan
      const Color(0xFFFFBE0B), // Yellow
      const Color(0xFF95E1D3), // Mint
      const Color(0xFF9B59B6), // Purple
      const Color(0xFFF38181), // Pink
      const Color(0xFF74B9FF), // Blue
      const Color(0xFF00B894), // Green
    ];
    return colors[index % colors.length];
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

// Prize data model
class SpinPrize {
  final String name;
  final PrizeType type;
  final int amount;
  final double probability;

  SpinPrize({
    required this.name,
    required this.type,
    required this.amount,
    required this.probability,
  });
}

enum PrizeType {
  coins,
  companion,
  bonusSpin,
  tryTomorrow,
}
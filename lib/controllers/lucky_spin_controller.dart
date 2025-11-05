// lib/controllers/lucky_spin_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flame_audio/flame_audio.dart';

class LuckySpinController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Animation
  late AnimationController animationController;
  late Animation<double> spinAnimation;

  // State
  final RxBool isSpinning = false.obs;
  final RxDouble wheelRotation = 0.0
      .obs; // degrees; overlay already converts to radians with *(pi/180)
  final RxInt playerCoins = 1000.obs;

  final RxBool showResultPopup = false.obs;
  final RxString lastWonPrize = ''.obs;
  final RxInt lastWonAmount = 0.obs;

  final Random random = Random();

  // —————————————————————————————————————————————
  // Configure segments (order must match your wheel art)
  // Keep PrizeType.bonusSpin name because overlay references it.
  // ‘No Reward’ uses PrizeType.tryTomorrow to avoid overlay changes.
  // final List<SpinPrize> prizes = [
  //   SpinPrize(name: '5 Coins', type: PrizeType.coins, amount: 5, probability: 0.30),      // 30%
  //   SpinPrize(name: '10 Coins', type: PrizeType.coins, amount: 10, probability: 0.24),    // 24%
  //   SpinPrize(name: '25 Coins', type: PrizeType.coins, amount: 25, probability: 0.15),    // 15%
  //   SpinPrize(name: '50 Coins', type: PrizeType.coins, amount: 50, probability: 0.10),    // 10%
  //   SpinPrize(name: '100 Coins', type: PrizeType.coins, amount: 100, probability: 0.05),  // 5%
  //   SpinPrize(name: 'Spin Again', type: PrizeType.bonusSpin, amount: 0, probability: 0.0595), // 5.95%
  //   SpinPrize(name: 'No Reward', type: PrizeType.tryTomorrow, amount: 0, probability: 0.10),  // 10%
  //   SpinPrize(name: '1 Companion', type: PrizeType.companion, amount: 0, probability: 0.0005), // 0.05%
  // ];
  final List<SpinPrize> prizes = [
    // Index 0 (Visual: 5 Coins)
    SpinPrize(name: '5 Coins',      type: PrizeType.coins,      amount: 5,   probability: 0.30),   // 30%

    // Index 1 (Visual: 10 Coins)
    SpinPrize(name: '10 Coins',     type: PrizeType.coins,      amount: 10,  probability: 0.24),   // 24%

    // Index 2 (Visual: 25 Coins)
    SpinPrize(name: '25 Coins',     type: PrizeType.coins,      amount: 25,  probability: 0.15),   // 15%

    // Index 3 (Visual: 50 Coins)
    SpinPrize(name: '50 Coins',     type: PrizeType.coins,      amount: 50,  probability: 0.10),   // 10%

    // Index 4 (Visual: 100 Coins)
    SpinPrize(name: '100 Coins',    type: PrizeType.coins,      amount: 100, probability: 0.05),   // 5%

    // Index 5 (Visual: Spin Again)
    SpinPrize(name: 'Spin Again',   type: PrizeType.bonusSpin,  amount: 0,   probability: 0.0595), // 5.95%

    // Index 6 (Visual: No Reward)
    SpinPrize(name: 'No Reward',    type: PrizeType.tryTomorrow,amount: 0,   probability: 0.10),   // 10%

    // Index 7 (Visual: 1 Companion)
    SpinPrize(name: '1 Companion',  type: PrizeType.companion,  amount: 0,   probability: 0.0005), // 0.05%
  ];
  // If your wheel image’s clockwise order is different, reorder the list above
  // to match the exact visual order. The math below will stay correct.

  // Runtime
  int selectedSegment = 0;

  // static const double _phaseOffsetDeg = 45.0;  // one slice (360/8)

  // One full wheel has N slices
  int get _sliceCount => prizes.length;             // 8
  double get _sliceDeg => 360.0 / _sliceCount;      // 45.0 for 8 slices

// Your rough artwork phase guess (keep -40 if that's what worked best visually)
  static const double _phaseOffsetDeg = -60.0;

// We snap the rough value to the nearest slice multiple to avoid boundary drift.
  double get _snappedPhaseDeg {
    final k = (_phaseOffsetDeg / _sliceDeg).round(); // nearest integer multiple
    return k * _sliceDeg;
  }

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  // Main spin
  Future<void> spinWheel() async {
    if (isSpinning.value) return;

    isSpinning.value = true;
    _playSpinSound();

    // 1) pick prize by weighted probability
    selectedSegment = _selectPrizeSegment(); // index into `prizes`

    // 2) compute target rotation so the selected slice center is under the pointer
    final int n = prizes.length;
    final double segmentAngle = 360.0 / n;              // degrees
    final double current = wheelRotation.value % 360.0; // normalize
    final double targetCenterDeg =
        -(selectedSegment * segmentAngle) + (segmentAngle / 2.0) + _snappedPhaseDeg;

    // delta to move forward (0..360) from current to target center
    double delta = (targetCenterDeg - current) % 360.0;
    if (delta < 0) delta += 360.0;

    // add whole rotations (5–7 full spins), always forward
    final int wholeSpins = 5 + random.nextInt(3); // 5,6,7
    final double finalRotation =
        (wholeSpins * 360.0) + delta; // no random offset crossing boundaries

    // 3) animate to that exact angle
    final double begin = wheelRotation.value;
    final double end = begin + finalRotation;

    spinAnimation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    )..addListener(() {
      wheelRotation.value = spinAnimation.value;
    });

    await animationController.forward();
    animationController.reset();

    _stopSpinSound();
    _applyPrizeOutcome(prizes[selectedSegment]);

    // small delay for UX, then show popup
    await Future<void>.delayed(const Duration(milliseconds: 350));
    showResultPopup.value = true;
    isSpinning.value = false;
  }

  // Weighted selection with cumulative distribution (probabilities sum to 1.0)
  int _selectPrizeSegment() {
    final double r = random.nextDouble();
    double cum = 0.0;
    for (int i = 0; i < prizes.length; i++) {
      cum += prizes[i].probability;
      if (r <= cum) return i;
    }
    return prizes.length - 1; // safety
  }

  void _applyPrizeOutcome(SpinPrize prize) {
    lastWonPrize.value = prize.name;
    lastWonAmount.value = prize.amount;

    switch (prize.type) {
      case PrizeType.coins:
        playerCoins.value += prize.amount;
        _playSuccessSound();
        break;
      case PrizeType.companion:
      // TODO: grant companion item in your inventory system
        _playSuccessSound();
        break;
      case PrizeType.bonusSpin:
      // You can auto-trigger another spin if desired:
      // Future.delayed(const Duration(milliseconds: 400), () => spinWheel());
        _playSuccessSound();
        break;
      case PrizeType.tryTomorrow:
      // No reward
        break;
    }
  }

  void resetSpin() {
    showResultPopup.value = false;
    lastWonPrize.value = '';
    lastWonAmount.value = 0;
  }

  // —————————————————————————————————————————————
  // Audio (reuse your existing assets)
  void _playSpinSound() {
    try {
      FlameAudio.playLongAudio('spin.mp3', volume: 0.6);
    } catch (_) {}
  }

  void _stopSpinSound() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  void _playSuccessSound() {
    try {
      FlameAudio.play('win.mp3', volume: 0.8);
    } catch (_) {}
  }
}

// Data model
class SpinPrize {
  final String name;
  final PrizeType type;
  final int amount;
  final double probability; // fraction (e.g., 0.30 = 30%)

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
  bonusSpin,   // “Spin Again” in UI
  tryTomorrow, // “No Reward” in UI
}

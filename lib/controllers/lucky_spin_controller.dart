// lib/controllers/lucky_spin_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:get_storage/get_storage.dart';
import '../service/ad_service.dart';
import 'coin_controller.dart';
import 'companion_controller.dart';

class LuckySpinController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> spinAnimation;

  final RxBool isSpinning = false.obs;
  final RxDouble wheelRotation = 0.0.obs;
  final RxBool canSpin = true.obs; // This is the daily free spin

  final RxBool showResultPopup = false.obs;
  final RxString lastWonPrize = ''.obs;
  final RxInt lastWonAmount = 0.obs;
  final Rx<PrizeType> lastWonPrizeType = PrizeType.tryTomorrow.obs;

  final Random random = Random();
  final _storage = GetStorage();

  static const String _lastSpinDateKey = 'last_spin_date';

  // --- NEW: Ad-related State ---
  //TODO: after live uncomment this
  // final AdService _adService = Get.find<AdService>();
  final RxInt adSpinsWatched = 0.obs; // Tracks progress from 0 to 3
  final RxInt bonusSpinsAvailable = 0.obs; // Spins earned from ads

  /// The number of ads a user must watch to earn one bonus spin.
  static const int maxAdsPerSpin = 3;
  static const String _adWatchCountKey = 'ad_watch_count';
  // --- End NEW ---

  final List<SpinPrize> prizes = [
    SpinPrize(name: '5 Coins', type: PrizeType.coins, amount: 5, probability: 0.30),
    SpinPrize(name: '10 Coins', type: PrizeType.coins, amount: 10, probability: 0.24),
    SpinPrize(name: '25 Coins', type: PrizeType.coins, amount: 25, probability: 0.15),
    SpinPrize(name: '50 Coins', type: PrizeType.coins, amount: 50, probability: 0.10),
    SpinPrize(name: '100 Coins', type: PrizeType.coins, amount: 100, probability: 0.05),
    SpinPrize(name: 'Spin Again', type: PrizeType.bonusSpin, amount: 0, probability: 0.0595),
    SpinPrize(name: 'No Reward', type: PrizeType.tryTomorrow, amount: 0, probability: 0.10),
    SpinPrize(name: '1 Companion', type: PrizeType.companion, amount: 0, probability: 0.0005),
  ];

  int selectedSegment = 0;
  int get _sliceCount => prizes.length;
  double get _sliceDeg => 360.0 / _sliceCount;
  static const double _phaseOffsetDeg = -60.0;

  double get _snappedPhaseDeg {
    final k = (_phaseOffsetDeg / _sliceDeg).round();
    return k * _sliceDeg;
  }

  // --- NEW: Computed Properties ---
  /// Can the user watch an ad?
  /// Yes, if their daily spin is used AND they don't have a bonus spin waiting.
  RxBool get canWatchAd =>
      (!canSpin.value && bonusSpinsAvailable.value == 0).obs;

  /// Does the user have *any* way to spin? (Daily OR bonus)
  RxBool get hasAnySpin => (canSpin.value || bonusSpinsAvailable.value > 0).obs;

  /// Is the rewarded ad ready to be shown?
  /// //TODO: after live uncomment this
  // RxBool get isAdReady => _adService.isRewardedAdReady;
  // --- End NEW ---

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _checkSpinAvailability();

    // <-- NEW: Load ad watch progress -->
    adSpinsWatched.value = _storage.read<int>(_adWatchCountKey) ?? 0;
  }

  void _checkSpinAvailability() {
    final lastSpinDate = _storage.read(_lastSpinDateKey);
    if (lastSpinDate != null) {
      final lastSpin = DateTime.parse(lastSpinDate);
      final today = DateTime.now();

      // Check if it's a different day
      if (lastSpin.year == today.year &&
          lastSpin.month == today.month &&
          lastSpin.day == today.day) {
        canSpin.value = false;
      } else {
        canSpin.value = true;
      }
    } else {
      canSpin.value = true;
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  // --- NEW: Ad Methods ---
  /// Called by the UI when the "Watch Ad" button is pressed.
  /// //TODO: after live uncomment this
  // void showAdForSpin() {
  //   _adService.showRewardedAd(
  //     onReward: () {
  //       // This callback runs after the ad is successfully watched.
  //       _onAdRewardGranted();
  //     },
  //   );
  // }

  /// Handles the logic after a reward is granted.
  void _onAdRewardGranted() {
    adSpinsWatched.value++;
    _storage.write(_adWatchCountKey, adSpinsWatched.value);

    // Check if they have watched enough ads
    if (adSpinsWatched.value >= maxAdsPerSpin) {
      bonusSpinsAvailable.value++; // Grant one bonus spin
      adSpinsWatched.value = 0; // Reset the counter
      _storage.write(_adWatchCountKey, 0); // Save the reset
    }
  }
  // --- End NEW ---

  Future<void> spinWheel() async {
    // <-- MODIFIED: Check for *any* spin -->
    if (isSpinning.value || !hasAnySpin.value) return;

    // <-- NEW: Determine which spin type is being used -->
    bool isBonusSpin = false;
    if (bonusSpinsAvailable.value > 0) {
      bonusSpinsAvailable.value--;
      isBonusSpin = true;
    } else if (canSpin.value) {
      // This is the daily spin
      isBonusSpin = false;
    } else {
      return; // Should not happen if UI is correct
    }
    // --- End NEW ---

    isSpinning.value = true;
    _playSpinSound();

    selectedSegment = _selectPrizeSegment();

    // ... (Animation logic remains the same) ...
    final int n = prizes.length;
    final double segmentAngle = 360.0 / n;
    final double current = wheelRotation.value % 360.0;
    final double targetCenterDeg =
        -(selectedSegment * segmentAngle) + (segmentAngle / 2.0) + _snappedPhaseDeg;

    double delta = (targetCenterDeg - current) % 360.0;
    if (delta < 0) delta += 360.0;

    final int wholeSpins = 5 + random.nextInt(3);
    final double finalRotation = (wholeSpins * 360.0) + delta;

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
    // <-- MODIFIED: Pass spin type to outcome -->
    await _applyPrizeOutcome(prizes[selectedSegment], isBonusSpin: isBonusSpin);

    await Future<void>.delayed(const Duration(milliseconds: 350));
    showResultPopup.value = true;
    isSpinning.value = false;
  }

  int _selectPrizeSegment() {
    final double r = random.nextDouble();
    double cum = 0.0;
    for (int i = 0; i < prizes.length; i++) {
      cum += prizes[i].probability;
      if (r <= cum) return i;
    }
    return prizes.length - 1;
  }

  // <-- MODIFIED: Accept `isBonusSpin` to know when to call _markSpinUsed -->
  Future<void> _applyPrizeOutcome(SpinPrize prize,
      {required bool isBonusSpin}) async {
    lastWonPrize.value = prize.name;
    lastWonAmount.value = prize.amount;
    lastWonPrizeType.value = prize.type;

    switch (prize.type) {
      case PrizeType.coins:
      // Add coins using CoinController
        final coinController = Get.find<CoinController>();
        await coinController.addCoins(prize.amount);
        _playSuccessSound();
        // Only mark daily spin as used
        if (!isBonusSpin) _markSpinUsed();
        break;

      case PrizeType.companion:
      // Unlock penguin companion
        if (Get.isRegistered<CompanionController>()) {
          final companionController = Get.find<CompanionController>();
          if (!companionController.isCompanionUnlocked('penguin')) {
            companionController.unlockCompanion('penguin');
            _playSuccessSound();
          } else {
            lastWonPrize.value = 'Already Owned!';
          }
        }
        if (!isBonusSpin) _markSpinUsed();
        break;

      case PrizeType.bonusSpin:
      // Don't mark spin as used - user can spin again
        _playSuccessSound();
        // <-- MODIFIED: Grant a bonus spin -->
        bonusSpinsAvailable.value++;
        break;

      case PrizeType.tryTomorrow:
      // No reward - mark spin as used
        if (!isBonusSpin) _markSpinUsed();
        break;
    }
  }

  void _markSpinUsed() {
    // This function now *only* marks the DAILY spin as used
    final now = DateTime.now();
    _storage.write(_lastSpinDateKey, now.toIso8601String());
    canSpin.value = false;
  }

  void resetSpin() {
    showResultPopup.value = false;
    lastWonPrize.value = '';
    lastWonAmount.value = 0;
    lastWonPrizeType.value = PrizeType.tryTomorrow;

    // <-- MODIFIED: Removed old logic -->
    // State is now handled by `hasAnySpin` computed property
  }

  Future<void> _playSpinSound() async {
    try {
      FlameAudio.playLongAudio('spin.mp3', volume: 0.6);
    } catch (_) {}
  }

  void _stopSpinSound() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  Future<void> _playSuccessSound() async {
    try {
      await FlameAudio.play('success.mp3', volume: 0.8);
    } catch (_) {}
  }
}

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
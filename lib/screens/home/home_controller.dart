// lib/screens/home/home_controller.dart

import 'package:get/get.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  // Animation states
  final RxBool showPlayGameGroup = false.obs;
  final RxBool showOwl = false.obs;
  final RxBool showLion = false.obs;
  final RxBool showDeer = false.obs;
  final RxBool showSettings = false.obs;
  final RxBool showCoins = false.obs;
  final RxBool showTitle = false.obs;

  // Character selection overlay state
  final RxBool showCharacterSelection = false.obs;

  @override
  void onInit() {
    super.onInit();
    startAnimationSequence();
  }

  Future<void> startAnimationSequence() async {
    // Wait a bit before starting
    await Future.delayed(const Duration(milliseconds: 300));

    // 1. Show Play Game group from bottom
    showPlayGameGroup.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    // 2. Show animals
    showOwl.value = true;
    await Future.delayed(const Duration(milliseconds: 200));
    showLion.value = true;
    await Future.delayed(const Duration(milliseconds: 200));
    showDeer.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    // 3. Show top elements
    showSettings.value = true;
    await Future.delayed(const Duration(milliseconds: 200));
    showCoins.value = true;
    await Future.delayed(const Duration(milliseconds: 200));
    showTitle.value = true;
  }

  void navigateToGame() {
    Get.toNamed('/game');
  }

  void openCharacterSelection() {
    // Show character selection overlay instead of navigating to new page
    showCharacterSelection.value = true;
  }

  void closeCharacterSelection() {
    showCharacterSelection.value = false;
  }

  void openCompanionSelection() {
    // TODO: Implement companion selection
    Get.snackbar(
      'Coming Soon',
      'Companion selection will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openSettings() {
    // TODO: Implement settings
    Get.snackbar(
      'Settings',
      'Settings panel coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
// lib/screens/home/home_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/character_controller.dart';
import '../../controllers/companion_controller.dart';
import '../../controllers/coin_controller.dart';

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

  // Companion selection overlay state
  final RxBool showCompanionSelection = false.obs;

  // Preloading state
  final RxBool isPreloadingCharacters = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _preloadAllAssets();
  }

  void _initializeControllers() {
    // Initialize character controller if not already initialized
    if (!Get.isRegistered<CharacterController>()) {
      Get.put(CharacterController());
    }

    // Initialize companion controller
    if (!Get.isRegistered<CompanionController>()) {
      Get.put(CompanionController());
    }

    // Initialize coin controller and wait for it to load coins
    if (!Get.isRegistered<CoinController>()) {
      Get.put(CoinController());
    }

    // Ensure coin controller loads data from storage first
    final coinController = Get.find<CoinController>();
    // Force a refresh of coin display after controller is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      coinController.coins.refresh();
    });
  }

  Future<void> _preloadAllAssets() async {
    try {
      print('🔄 Starting to preload all assets...');

      final characterController = Get.find<CharacterController>();
      final companionController = Get.find<CompanionController>();
      final context = Get.context;

      if (context == null) {
        print('⚠️ Context is null, waiting...');
        await Future.delayed(const Duration(milliseconds: 100));
        if (Get.context != null) {
          await _preloadAllAssets();
        }
        return;
      }

      final List<Future<void>> allPreloadTasks = [];

      // Preload all characters' walk animations
      for (final character in characterController.characters) {
        for (int i = 1; i <= 10; i++) {
          final walkImagePath = '${character.walkPath}$i.png';
          allPreloadTasks.add(
            precacheImage(
              AssetImage(walkImagePath),
              context,
            ).catchError((error) {
              print('⚠️ Failed to preload $walkImagePath: $error');
              return null;
            }),
          );
        }

        final selectionImagePath = character.selectionAssetPath;
        allPreloadTasks.add(
          precacheImage(
            AssetImage(selectionImagePath),
            context,
          ).catchError((error) {
            print('⚠️ Failed to preload $selectionImagePath: $error');
            return null;
          }),
        );
      }

      // Preload companion display images (main selection images)
      for (final companion in companionController.companions) {
        allPreloadTasks.add(
          precacheImage(
            AssetImage(companion.displayImagePath),
            context,
          ).catchError((error) {
            print('⚠️ Failed to preload companion display image ${companion.displayImagePath}: $error');
            return null;
          }),
        );
      }

      await Future.wait(allPreloadTasks);

      print('✅ All assets preloaded successfully!');

      await Future.delayed(const Duration(milliseconds: 100));

      isPreloadingCharacters.value = false;

      startAnimationSequence();

    } catch (e) {
      print('❌ Error preloading assets: $e');
      // Continue anyway to prevent app crash
      isPreloadingCharacters.value = false;
      startAnimationSequence();
    }
  }

  Future<void> startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    showPlayGameGroup.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    showOwl.value = true;
    await Future.delayed(const Duration(milliseconds: 200));
    showLion.value = true;
    await Future.delayed(const Duration(milliseconds: 200));
    showDeer.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

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
    showCharacterSelection.value = true;
  }

  void closeCharacterSelection() {
    showCharacterSelection.value = false;
  }

  void openCompanionSelection() {
    showCompanionSelection.value = true;
  }

  void closeCompanionSelection() {
    showCompanionSelection.value = false;
  }

  void openSettings() {
    Get.snackbar(
      'Settings',
      'Settings panel coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
// lib/screens/home/home_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/character_controller.dart';

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

  // Preloading state
  final RxBool isPreloadingCharacters = true.obs;

  @override
  void onInit() {
    super.onInit();
    _preloadAllCharacters();
  }

  Future<void> _preloadAllCharacters() async {
    try {
      print('🔄 Starting to preload all character animations...');

      final characterController = Get.find<CharacterController>();
      final context = Get.context;

      if (context == null) {
        print('⚠️ Context is null, waiting...');
        await Future.delayed(const Duration(milliseconds: 100));
        if (Get.context != null) {
          await _preloadAllCharacters();
        }
        return;
      }

      // Preload all characters' walk animations
      final List<Future<void>> allPreloadTasks = [];

      for (final character in characterController.characters) {
        // Preload walk animation frames (1-10)
        for (int i = 1; i <= 10; i++) {
          final walkImagePath = '${character.walkPath}$i.png';
          allPreloadTasks.add(
            precacheImage(
              AssetImage(walkImagePath),
              context,
            ).catchError((error) {
              print('⚠️ Failed to preload $walkImagePath: $error');
            }),
          );
        }

        // Also preload the character selection image
        final selectionImagePath = character.selectionAssetPath;
        allPreloadTasks.add(
          precacheImage(
            AssetImage(selectionImagePath),
            context,
          ).catchError((error) {
            print('⚠️ Failed to preload $selectionImagePath: $error');
          }),
        );
      }

      // Wait for all images to preload
      await Future.wait(allPreloadTasks);

      print('✅ All character animations preloaded successfully!');

      // Small delay to ensure everything is cached
      await Future.delayed(const Duration(milliseconds: 100));

      isPreloadingCharacters.value = false;

      // Now start the home screen animations
      startAnimationSequence();

    } catch (e) {
      print('❌ Error preloading characters: $e');
      // Continue anyway
      isPreloadingCharacters.value = false;
      startAnimationSequence();
    }
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
    // Show character selection overlay
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
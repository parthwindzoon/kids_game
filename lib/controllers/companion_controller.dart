// lib/controllers/companion_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'coin_controller.dart';

class CompanionController extends GetxController {
  final _storage = GetStorage();

  // Current selected companion (default is robo)
  final selectedCompanion = 'robo'.obs;

  // Popup states for pet shop
  final showPurchasePopup = false.obs;
  final showInsufficientCoinsPopup = false.obs;
  final popupScale = 0.0.obs;
  final popupOpacity = 0.0.obs;

  // List of available companions - Updated with idle frames
  final List<CompanionData> companions = [
    CompanionData(
      id: 'robo',
      name: 'Robo',
      folderName: 'robo',
      color: 0xFF808080,
      totalFrames: 21,
      idleFrames: 21, // NEW: Robo has 21 idle frames
      displayImageName: 'robo.png',
      price: 0, // Free companion
    ),
    CompanionData(
      id: 'teddy',
      name: 'Teddy',
      folderName: 'teddy',
      color: 0xFFD4A574,
      totalFrames: 12,
      idleFrames: 12, // NEW: Teddy has 12 idle frames
      displayImageName: 'teddy.png',
      price: 1000,
    ),
    CompanionData(
      id: 'ducky',
      name: 'Ducky',
      folderName: 'ducky',
      color: 0xFFFFF4E0,
      totalFrames: 12,
      idleFrames: 12, // NEW: Ducky has 12 idle frames
      displayImageName: 'ducky.png',
      price: 1000,
    ),
    CompanionData(
      id: 'penguin',
      name: 'Penguin',
      folderName: 'penguin',
      color: 0xFF4A90E2,
      totalFrames: 12,
      idleFrames: 12, // NEW: Penguin has 12 idle frames
      displayImageName: 'penguin.png',
      price: 1000,
    ),
    CompanionData(
      id: 'bear',
      name: 'Bear',
      folderName: 'bear',
      color: 0xFFFFB6C1,
      totalFrames: 12,
      idleFrames: 12, // NEW: Bear has 12 idle frames
      displayImageName: 'bear.png',
      price: 1000,
    ),
  ];

  // ... rest of the controller methods remain the same ...

  void selectCompanion(String companionId) {
    if (isCompanionUnlocked(companionId)) {
      selectedCompanion.value = companionId;
      update();
      _saveSelectedCompanion();
    }
  }

  bool isCompanionUnlocked(String companionId) {
    if (companionId == 'robo') return true; // Robo is always unlocked
    return _storage.read('companion_$companionId') ?? false;
  }

  void unlockCompanion(String companionId) {
    _storage.write('companion_$companionId', true);
    print('✅ Companion $companionId unlocked');
  }

  void purchaseCompanion(String companionId, CoinController coinController) {
    final companion = companions.firstWhere((c) => c.id == companionId);

    if (isCompanionUnlocked(companionId)) {
      selectCompanion(companionId);
      return;
    }

    if (coinController.coins.value >= companion.price) {
      coinController.spendCoins(companion.price);
      unlockCompanion(companionId);
      selectCompanion(companionId);
      _showPurchaseSuccessPopup();
    } else {
      _showInsufficientCoinsPopup();
    }
  }

  void _showPurchaseSuccessPopup() {
    showPurchasePopup.value = true;
    _animatePopupIn();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (showPurchasePopup.value) {
        closePurchasePopup();
      }
    });
  }

  void _showInsufficientCoinsPopup() {
    showInsufficientCoinsPopup.value = true;
    _animatePopupIn();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (showInsufficientCoinsPopup.value) {
        closeInsufficientCoinsPopup();
      }
    });
  }

  void _animatePopupIn() {
    popupScale.value = 0.0;
    popupOpacity.value = 0.0;

    final duration = 400;
    final steps = 30;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (showPurchasePopup.value || showInsufficientCoinsPopup.value) {
          final progress = i / steps;
          final bounce = progress < 0.5
              ? 4 * progress * progress * progress
              : 1 - 4 * (1 - progress) * (1 - progress) * (1 - progress);
          popupScale.value = bounce * 1.2;
          popupOpacity.value = progress;
        }
      });
    }
  }

  void closePurchasePopup() {
    final duration = 300;
    final steps = 20;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        final progress = i / steps;
        popupScale.value = 1.2 - (0.3 * progress);
        popupOpacity.value = 1.0 - progress;

        if (i == steps) {
          showPurchasePopup.value = false;
        }
      });
    }
  }

  void closeInsufficientCoinsPopup() {
    final duration = 300;
    final steps = 20;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        final progress = i / steps;
        popupScale.value = 1.2 - (0.3 * progress);
        popupOpacity.value = 1.0 - progress;

        if (i == steps) {
          showInsufficientCoinsPopup.value = false;
        }
      });
    }
  }

  CompanionData? getCurrentCompanion() {
    if (selectedCompanion.value.isEmpty) {
      return companions[0];
    }
    return companions.firstWhere(
          (comp) => comp.id == selectedCompanion.value,
      orElse: () => companions[0],
    );
  }

  void _saveSelectedCompanion() {
    try {
      _storage.write('selected_companion', selectedCompanion.value);
    } catch (e) {
      print('⚠️ Error saving selected companion: $e');
    }
  }

  void _loadSelectedCompanion() {
    try {
      final savedCompanion = _storage.read('selected_companion');
      if (savedCompanion != null && isCompanionUnlocked(savedCompanion)) {
        selectedCompanion.value = savedCompanion;
      }
    } catch (e) {
      print('⚠️ Error loading selected companion: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSelectedCompanion();
  }
}

class CompanionData {
  final String id;
  final String name;
  final String folderName;
  final int color;
  final int totalFrames; // Walk animation frames
  final int idleFrames;  // NEW: Idle animation frames
  final String displayImageName;
  final int price;

  CompanionData({
    required this.id,
    required this.name,
    required this.folderName,
    required this.color,
    required this.totalFrames,
    required this.idleFrames, // NEW: Required parameter
    required this.displayImageName,
    required this.price,
  });

  String get animationPath => 'assets/images/companions/$folderName/';
  String get selectionAssetPath => 'assets/images/companions/$folderName/walk_1.png';
  String get displayImagePath => 'assets/images/companions/$displayImageName';
}
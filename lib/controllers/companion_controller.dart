// lib/controllers/companion_controller.dart

import 'package:get/get.dart';

class CompanionController extends GetxController {
  // Current selected companion (default is robo)
  final selectedCompanion = 'robo'.obs;

  // List of available companions - Robo is first
  final List<CompanionData> companions = [
    CompanionData(
      id: 'robo',
      name: 'Robo',
      folderName: 'robo',
      color: 0xFF808080,
      totalFrames: 21,
      displayImageName: 'robo.png',
    ),
    CompanionData(
      id: 'teddy',
      name: 'Teddy',
      folderName: 'teddy',
      color: 0xFFD4A574,
      totalFrames: 12,
      displayImageName: 'teddy.png',
    ),
    CompanionData(
      id: 'ducky',
      name: 'Ducky',
      folderName: 'ducky',
      color: 0xFFFFF4E0,
      totalFrames: 12,
      displayImageName: 'ducky.png',
    ),
    CompanionData(
      id: 'penguin',
      name: 'Penguin',
      folderName: 'penguin',
      color: 0xFF4A90E2,
      totalFrames: 12,
      displayImageName: 'penguin.png',
    ),
    CompanionData(
      id: 'bear',
      name: 'Bear',
      folderName: 'bear',
      color: 0xFFFFB6C1,
      totalFrames: 12,
      displayImageName: 'bear.png',
    ),
  ];

  void selectCompanion(String companionId) {
    selectedCompanion.value = companionId;
    update();
  }

  CompanionData? getCurrentCompanion() {
    if (selectedCompanion.value.isEmpty) {
      return companions[0]; // Return robo as default
    }
    return companions.firstWhere(
          (comp) => comp.id == selectedCompanion.value,
      orElse: () => companions[0],
    );
  }

  @override
  void onInit() {
    super.onInit();
    // Load saved companion from local storage (optional)
    // final savedCompanion = GetStorage().read('selected_companion');
    // if (savedCompanion != null) {
    //   selectedCompanion.value = savedCompanion;
    // }
  }
}

class CompanionData {
  final String id;
  final String name;
  final String folderName;
  final int color;
  final int totalFrames;
  final String displayImageName; // Image with frame, companion, and name

  CompanionData({
    required this.id,
    required this.name,
    required this.folderName,
    required this.color,
    required this.totalFrames,
    required this.displayImageName,
  });

  String get animationPath => 'assets/images/companions/$folderName/';
  String get selectionAssetPath => 'assets/images/companions/$folderName/walk_1.png';
  String get displayImagePath => 'assets/images/companions/$displayImageName';
}
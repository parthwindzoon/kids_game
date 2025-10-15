// lib/controllers/character_controller.dart

import 'package:get/get.dart';

class CharacterController extends GetxController {
  // Current selected character (default is the existing one)
  final selectedCharacter = 'player'.obs;

  // Updated list of available characters to match new asset system
  final List<CharacterData> characters = [
    CharacterData(
      id: 'player',
      name: 'Alex',
      folderName: 'player',
      color: 0xFFFF6B6B, // Red
      assetName: 'boy1',
    ),
    CharacterData(
      id: 'player_1',
      name: 'Max',
      folderName: 'player_1',
      color: 0xFF4ECDC4, // Cyan
      assetName: 'boy2',
    ),
    CharacterData(
      id: 'player_2',
      name: 'Sam',
      folderName: 'player_2',
      color: 0xFFFFBE0B, // Yellow
      assetName: 'boy3',
    ),
    CharacterData(
      id: 'player_3',
      name: 'Emma',
      folderName: 'player_3',
      color: 0xFF9B59B6, // Purple
      assetName: 'girl1',
    ),
    CharacterData(
      id: 'player_4',
      name: 'Luna',
      folderName: 'player_4',
      color: 0xFF95E1D3, // Mint
      assetName: 'girl2',
    ),
    CharacterData(
      id: 'player_5',
      name: 'Mia',
      folderName: 'player_5',
      color: 0xFFF38181, // Pink
      assetName: 'girl3',
    ),
  ];

  void selectCharacter(String characterId) {
    selectedCharacter.value = characterId;
    update();

    // Save to local storage (optional - for persistence)
    // GetStorage().write('selected_character', characterId);
  }

  CharacterData getCurrentCharacter() {
    return characters.firstWhere(
          (char) => char.id == selectedCharacter.value,
      orElse: () => characters[0],
    );
  }

  @override
  void onInit() {
    super.onInit();
    // Load saved character from local storage (optional)
    // final savedCharacter = GetStorage().read('selected_character');
    // if (savedCharacter != null) {
    //   selectedCharacter.value = savedCharacter;
    // }
  }
}

class CharacterData {
  final String id;
  final String name;
  final String folderName;
  final int color;
  final String assetName; // New field for the character selection assets

  CharacterData({
    required this.id,
    required this.name,
    required this.folderName,
    required this.color,
    required this.assetName,
  });

  String get idlePath => 'assets/images/$folderName/idle_';
  String get walkPath => 'assets/images/$folderName/walk_';
  String get selectionAssetPath => 'assets/images/change_character/$assetName.png';
}
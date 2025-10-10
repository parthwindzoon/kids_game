// lib/controllers/character_controller.dart

import 'package:get/get.dart';

class CharacterController extends GetxController {
  // Current selected character (default is the existing one)
  final selectedCharacter = 'player'.obs;

  // List of available characters
  final List<CharacterData> characters = [
    CharacterData(
      id: 'player',
      name: 'Alex',
      folderName: 'player',
      color: 0xFFFF6B6B, // Red
    ),
    CharacterData(
      id: 'player_1',
      name: 'Max',
      folderName: 'player_1',
      color: 0xFF4ECDC4, // Cyan
    ),
    CharacterData(
      id: 'player_2',
      name: 'Emma',
      folderName: 'player_2',
      color: 0xFFFFBE0B, // Yellow
    ),
    CharacterData(
      id: 'player_3',
      name: 'Shadow',
      folderName: 'player_3',
      color: 0xFF9B59B6, // Purple
    ),
    CharacterData(
      id: 'player_4',
      name: 'Arthur',
      folderName: 'player_4',
      color: 0xFF95E1D3, // Mint
    ),
    CharacterData(
      id: 'player_5',
      name: 'Merlin',
      folderName: 'player_5',
      color: 0xFFF38181, // Pink
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

  CharacterData({
    required this.id,
    required this.name,
    required this.folderName,
    required this.color,
  });

  String get idlePath => 'assets/images/$folderName/idle_';
  String get walkPath => 'assets/images/$folderName/walk_';
}
// lib/game/overlay/character_selection_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/screens/home/home_controller.dart';
import '../../controllers/character_controller.dart';

class CharacterSelectionOverlay extends StatelessWidget {
  const CharacterSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CharacterController>();
    final homeController = Get.find<HomeController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: GetBuilder<CharacterSelectionOverlayController>(
        init: CharacterSelectionOverlayController(),
        builder: (overlayController) {
          return Stack(
            children: [
              // Main Content
              Center(
                child: Container(
                  width: isTablet ? 800 : 600,
                  height: isTablet ? 500 : 400,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/change_character/white_bg.png'),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Left Side - Walking Animation Preview
                      Expanded(
                        flex: 1,
                        child: _buildLeftSidePreview(
                          controller,
                          overlayController,
                          isTablet,
                        ),
                      ),

                      // Right Side - Character Selection
                      Expanded(
                        flex: 1,
                        child: _buildRightSideSelection(
                          controller,
                          overlayController,
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title at the top
              Positioned(
                top: isTablet ? 100 : 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Select Character',
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 48 : 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6B35),
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 5,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Back Button (top-left)
              Positioned(
                top: isTablet ? 20 : 10,
                left: isTablet ? 20 : 10,
                child: GestureDetector(
                  onTap: () {
                    homeController.closeCharacterSelection();
                    Get.delete<CharacterSelectionOverlayController>();
                    Get.back();
                  },
                  child: Image.asset(
                    'assets/images/back_btn.png',
                    width: isTablet ? 80 : 60,
                    height: isTablet ? 80 : 60,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftSidePreview(
      CharacterController controller,
      CharacterSelectionOverlayController overlayController,
      bool isTablet,
      ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 30 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Walking Animation Preview
          Obx(() {
            final selectedCharacter = controller.selectedCharacter.value;

            // Map old character IDs to new asset names
            String assetName = _mapCharacterToAsset(selectedCharacter);

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(selectedCharacter),
                width: isTablet ? 200 : 150,
                height: isTablet ? 200 : 150,
                child: Center(
                  child: _buildWalkingCharacter(
                    assetName,
                    overlayController,
                    isTablet,
                  ),
                ),
              ),
            );
          }),

          SizedBox(height: isTablet ? 20 : 15),

          // Character Name
          Obx(() {
            final character = controller.getCurrentCharacter();
            return Text(
              character.name,
              style: TextStyle(
                fontFamily: 'AkayaKanadaka',
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _mapCharacterToAsset(String characterId) {
    // Map the old character system to new asset names
    switch (characterId) {
      case 'player':
        return 'boy1';
      case 'player_1':
        return 'boy2';
      case 'player_2':
        return 'boy3';
      case 'player_3':
        return 'girl1';
      case 'player_4':
        return 'girl2';
      case 'player_5':
        return 'girl3';
      default:
        return 'boy1';
    }
  }

  Widget _buildWalkingCharacter(
      String assetName,
      CharacterSelectionOverlayController controller,
      bool isTablet,
      ) {
    return Obx(() {
      final frameIndex = controller.animationFrame.value;
      final size = isTablet ? 180.0 : 130.0;

      // Get the current character data to access walk animation
      final currentCharacter = Get.find<CharacterController>().getCurrentCharacter();

      return Image.asset(
        '${currentCharacter.walkPath}${frameIndex + 1}.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to static character selection asset if walk animation fails
          return Image.asset(
            'assets/images/change_character/$assetName.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                size: size * 0.6,
                color: Colors.grey.shade500,
              );
            },
          );
        },
      );
    });
  }

  Widget _buildRightSideSelection(
      CharacterController controller,
      CharacterSelectionOverlayController overlayController,
      bool isTablet,
      ) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 30 : 20),
      child: Column(
        children: [
          // Boys Section
          Expanded(
            child: Column(
              children: [
                // Boys Title
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Boys',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 15 : 10),

                // Boys Character Row
                Expanded(
                  child: Row(
                    children: [
                      _buildCharacterOption('player', 'boy1', 'Boy 1', controller, isTablet),
                      SizedBox(width: isTablet ? 15 : 10),
                      _buildCharacterOption('player_1', 'boy2', 'Boy 2', controller, isTablet),
                      SizedBox(width: isTablet ? 15 : 10),
                      _buildCharacterOption('player_2', 'boy3', 'Boy 3', controller, isTablet),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 20 : 15),

          // Girls Section
          Expanded(
            child: Column(
              children: [
                // Girls Title
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Girls',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 15 : 10),

                // Girls Character Row
                Expanded(
                  child: Row(
                    children: [
                      _buildCharacterOption('player_3', 'girl1', 'Girl 1', controller, isTablet),
                      SizedBox(width: isTablet ? 15 : 10),
                      _buildCharacterOption('player_4', 'girl2', 'Girl 2', controller, isTablet),
                      SizedBox(width: isTablet ? 15 : 10),
                      _buildCharacterOption('player_5', 'girl3', 'Girl 3', controller, isTablet),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterOption(
      String characterId,
      String assetName,
      String characterName,
      CharacterController controller,
      bool isTablet,
      ) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedCharacter.value == characterId;

        return GestureDetector(
          onTap: () {
            controller.selectCharacter(characterId);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF4CAF50).withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: isSelected ? 10 : 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Character Image
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/change_character/$assetName.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.person,
                                size: isTablet ? 40 : 30,
                                color: Colors.grey.shade500,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Character Name
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4CAF50).withOpacity(0.1)
                              : Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            characterName,
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 16 : 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Selection indicator
                if (isSelected)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: isTablet ? 16 : 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class CharacterSelectionOverlayController extends GetxController {
  final animationFrame = 0.obs;
  int _totalFrames = 10;

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _animate();
    });
  }

  void _animate() {
    if (isClosed) return;

    animationFrame.value = (animationFrame.value + 1) % _totalFrames;

    Future.delayed(const Duration(milliseconds: 120), () {
      _animate();
    });
  }
}
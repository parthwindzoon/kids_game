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
      color: Colors.white,
      child: GetBuilder<CharacterSelectionOverlayController>(
        init: CharacterSelectionOverlayController(),
        builder: (overlayController) {
          return Stack(
            children: [
              // Main Content Row
              Row(
                children: [
                  // Left Side - Current Selected Character Animation
                  Expanded(
                    flex: 1,
                    child: _buildLeftSidePreview(
                      controller,
                      overlayController,
                      isTablet,
                    ),
                  ),

                  // Right Side - Character Grid Selection
                  Expanded(
                    flex: 1,
                    child: _buildRightSideGrid(
                      controller,
                      overlayController,
                      isTablet,
                    ),
                  ),
                ],
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
    return Obx(() {
      final character = controller.getCurrentCharacter();

      return Container(
        padding: EdgeInsets.all(isTablet ? 40 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Character Name at Top
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 30 : 20,
                vertical: isTablet ? 15 : 10,
              ),
              decoration: BoxDecoration(
                color: Color(character.color),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                character.name,
                style: TextStyle(
                  fontFamily: 'AkayaKanadaka',
                  fontSize: isTablet ? 36 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: isTablet ? 40 : 30),

            // Animated Character Preview
            Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(controller.selectedCharacter.value),
                  width: isTablet ? 300 : 220,
                  height: isTablet ? 300 : 220,
                  decoration: BoxDecoration(
                    color: Color(character.color).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(character.color),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(character.color).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _buildAnimatedCharacter(
                      character,
                      overlayController,
                      isTablet,
                    ),
                  ),
                ),
              );
            }),

            // const Spacer(),
            //
            // // Select Button
            // GestureDetector(
            //   onTap: () {
            //     overlayController.dispose();
            //     Get.delete<CharacterSelectionOverlayController>();
            //     Get.back();
            //   },
            //   child: Container(
            //     padding: EdgeInsets.symmetric(
            //       horizontal: isTablet ? 60 : 45,
            //       vertical: isTablet ? 18 : 14,
            //     ),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF4CAF50),
            //       borderRadius: BorderRadius.circular(35),
            //       border: Border.all(
            //         color: Colors.white,
            //         width: 3,
            //       ),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.black.withOpacity(0.3),
            //           blurRadius: 10,
            //           offset: const Offset(0, 5),
            //         ),
            //       ],
            //     ),
            //     child: Text(
            //       'Select Character',
            //       style: TextStyle(
            //         fontFamily: 'AkayaKanadaka',
            //         fontSize: isTablet ? 28 : 22,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            //
            // SizedBox(height: isTablet ? 40 : 20),
          ],
        ),
      );
    });
  }

  Widget _buildAnimatedCharacter(
      CharacterData character,
      CharacterSelectionOverlayController controller,
      bool isTablet,
      ) {
    return Obx(() {
      final frameIndex = controller.animationFrame.value;
      final size = isTablet ? 250.0 : 180.0;

      return Image.asset(
        '${character.idlePath}${frameIndex + 1}.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: size * 0.6,
            color: Color(character.color),
          );
        },
      );
    });
  }

  Widget _buildRightSideGrid(
      CharacterController controller,
      CharacterSelectionOverlayController overlayController,
      bool isTablet,
      ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 40 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            'Choose Your Character',
            style: TextStyle(
              fontFamily: 'AkayaKanadaka',
              fontSize: isTablet ? 42 : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4CAF50),
            ),
          ),

          SizedBox(height: isTablet ? 40 : 30),

          // Character Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: isTablet ? 25 : 18,
                mainAxisSpacing: isTablet ? 25 : 18,
                childAspectRatio: 0.9,
              ),
              itemCount: controller.characters.length,
              itemBuilder: (context, index) {
                return _buildCharacterCard(
                  controller.characters[index],
                  controller,
                  isTablet,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(
      CharacterData character,
      CharacterController controller,
      bool isTablet,
      ) {
    return Obx(() {
      final isSelected = controller.selectedCharacter.value == character.id;

      return GestureDetector(
        onTap: () {
          controller.selectCharacter(character.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Color(character.color) : Colors.grey.shade300,
              width: isSelected ? 4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Color(character.color).withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 15 : 8,
                spreadRadius: isSelected ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Character Preview Image
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        '${character.idlePath}1.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('error--> $error');
                          return Container(
                            decoration: BoxDecoration(
                              color: Color(character.color).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: isTablet ? 60 : 40,
                                color: Color(character.color),
                              ),
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
                        color: Color(character.color).withOpacity(0.15),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          character.name,
                          style: TextStyle(
                            fontFamily: 'AkayaKanadaka',
                            fontSize: isTablet ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: Color(character.color),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Selected Indicator
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(character.color),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: isTablet ? 24 : 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
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

    Future.delayed(const Duration(milliseconds: 100), () {
      _animate();
    });
  }
}
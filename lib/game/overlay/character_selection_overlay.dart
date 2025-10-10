// lib/game/overlay/character_selection_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/character_controller.dart';

class CharacterSelectionOverlay extends StatelessWidget {
  const CharacterSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CharacterController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: GetBuilder<CharacterSelectionOverlayController>(
          init: CharacterSelectionOverlayController(),
          builder: (overlayController) {
            return Obx(() {
              final scale = overlayController.popupScale.value;
              final opacity = overlayController.popupOpacity.value;

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: isTablet ? 900 : 700,
                    height: isTablet ? 600 : 480,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/overlays/Group 67.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Close button
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              overlayController.closeOverlay();
                              Get.back();
                            },
                            child: Image.asset(
                              'assets/images/overlays/Group 86.png',
                              width: isTablet ? 60 : 50,
                              height: isTablet ? 60 : 50,
                            ),
                          ),
                        ),

                        // Title
                        Positioned(
                          top: isTablet ? 40 : 30,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'Choose Your Character',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF008000),
                              ),
                            ),
                          ),
                        ),

                        // Character Grid
                        Positioned(
                          top: isTablet ? 100 : 80,
                          left: isTablet ? 60 : 40,
                          right: isTablet ? 60 : 40,
                          bottom: isTablet ? 100 : 80,
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: isTablet ? 20 : 15,
                              mainAxisSpacing: isTablet ? 20 : 15,
                              childAspectRatio: 0.85,
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

                        // Select Button
                        Positioned(
                          bottom: isTablet ? 30 : 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                overlayController.closeOverlay();
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  Get.back();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 50 : 40,
                                  vertical: isTablet ? 15 : 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Select',
                                  style: TextStyle(
                                    fontFamily: 'AkayaKanadaka',
                                    fontSize: isTablet ? 28 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Character Preview Image
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    '${character.idlePath}1.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
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
                    color: Color(character.color).withOpacity(0.2),
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
                        fontSize: isTablet ? 18 : 14,
                        fontWeight: FontWeight.bold,
                        color: Color(character.color),
                      ),
                    ),
                  ),
                ),
              ),

              // Selected Indicator
              if (isSelected)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(character.color),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: isTablet ? 20 : 16,
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
  final popupScale = 0.0.obs;
  final popupOpacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _animateIn();
  }

  void _animateIn() {
    popupScale.value = 0.3;
    popupOpacity.value = 0.0;

    final duration = 400;
    final steps = 30;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (!isClosed) {
          final progress = i / steps;
          final easeProgress = 1 - (1 - progress) * (1 - progress);
          popupScale.value = 0.3 + (0.7 * easeProgress);
          popupOpacity.value = progress;
        }
      });
    }
  }

  void closeOverlay() {
    final duration = 300;
    final steps = 20;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (!isClosed) {
          final progress = i / steps;
          popupScale.value = 1.0 - (0.3 * progress);
          popupOpacity.value = 1.0 - progress;
        }
      });
    }
  }
}
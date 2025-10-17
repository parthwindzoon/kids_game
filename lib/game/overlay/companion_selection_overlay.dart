// lib/game/overlay/companion_selection_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/screens/home/home_controller.dart';
import '../../controllers/companion_controller.dart';

class CompanionSelectionOverlay extends StatelessWidget {
  const CompanionSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompanionController>();
    final homeController = Get.find<HomeController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    // Preload current companion's walk animations for smoother playback
    _preloadCurrentCompanionAnimations(controller, context);

    return GetBuilder<CompanionSelectionOverlayController>(
      init: CompanionSelectionOverlayController(),
      builder: (overlayController) {
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Main Content
                    Center(
                      child: Container(
                        width: size.width * 0.80,
                        height: size.height * 0.70,
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

                            // Right Side - Companion Selection
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
                      top: isTablet ? 100 : 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'Select Companion',
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
                          homeController.closeCompanionSelection();
                          Get.delete<CompanionSelectionOverlayController>();
                        },
                        child: Image.asset(
                          'assets/images/back_btn.png',
                          width: isTablet ? 80 : 60,
                          height: isTablet ? 80 : 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Preload companion walk animations for smooth playback
  void _preloadCurrentCompanionAnimations(CompanionController controller, BuildContext context) {
    final companion = controller.getCurrentCompanion();
    if (companion != null) {
      // Preload all walk animation frames
      for (int i = 1; i <= companion.totalFrames; i++) {
        precacheImage(
          AssetImage('${companion.animationPath}walk_$i.png'),
          context,
        ).catchError((error) {
          // Silently fail if frame doesn't exist - will use fallback
          return null;
        });
      }

      // Also preload display image as fallback
      precacheImage(
        AssetImage(companion.displayImagePath),
        context,
      ).catchError((error) {
        return null;
      });
    }
  }

  Widget _buildLeftSidePreview(
      CompanionController controller,
      CompanionSelectionOverlayController overlayController,
      bool isTablet,
      ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 30 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Walking Animation Preview - SQUARE container
          Obx(() {
            final companion = controller.getCurrentCompanion()!;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(companion.id),
                width: isTablet ? 200 : 150,
                height: isTablet ? 200 : 150, // Made square
                child: Center(
                  child: _buildWalkingCompanion(
                    companion,
                    overlayController,
                    isTablet,
                  ),
                ),
              ),
            );
          }),

          SizedBox(height: isTablet ? 20 : 15),

          // Companion Name
          Obx(() {
            final companion = controller.getCurrentCompanion()!;
            return Text(
              companion.name,
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

  Widget _buildWalkingCompanion(
      CompanionData companion,
      CompanionSelectionOverlayController controller,
      bool isTablet,
      ) {
    final size = isTablet ? 180.0 : 130.0;

    return Obx(() {
      // Use modulo to ensure frame index stays within valid range
      final frameIndex = controller.animationFrame.value % companion.totalFrames;

      return Image.asset(
        '${companion.animationPath}walk_${frameIndex + 1}.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        key: ValueKey('${companion.id}_$frameIndex'),
        // Improved error handling with fallback to display image
        errorBuilder: (context, error, stackTrace) {
          // If walk animation frame is missing, try the display image
          return Image.asset(
            companion.displayImagePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Final fallback to icon
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Color(companion.color).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pets,
                  size: size * 0.6,
                  color: Color(companion.color),
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildRightSideSelection(
      CompanionController controller,
      CompanionSelectionOverlayController overlayController,
      bool isTablet,
      ) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 30 : 20),
      child: Column(
        children: [
          // First Row - 3 companions (Robo, Teddy, Ducky)
          Expanded(
            child: Row(
              children: [
                _buildCompanionOption(controller.companions[0], controller, isTablet), // Robo
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[1], controller, isTablet), // Teddy
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[2], controller, isTablet), // Ducky
              ],
            ),
          ),

          SizedBox(height: isTablet ? 20 : 15),

          // Second Row - 2 companions (Penguin, Bear)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompanionOption(controller.companions[3], controller, isTablet), // Penguin
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[4], controller, isTablet), // Bear
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionOption(
      CompanionData companion,
      CompanionController controller,
      bool isTablet,
      ) {
    return Obx(() {
      final isSelected = controller.selectedCompanion.value == companion.id;

      return GestureDetector(
        onTap: () {
          controller.selectCompanion(companion.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Companion Image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    companion.selectionAssetPath,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Color(companion.color).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.pets,
                          size: isTablet ? 60 : 40,
                          color: Color(companion.color),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Companion Name
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  companion.name,
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 18 : 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade700,
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

class CompanionSelectionOverlayController extends GetxController {
  final animationFrame = 0.obs;
  final companionController = Get.find<CompanionController>();

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

    // Get current companion's total frames
    final currentCompanion = companionController.getCurrentCompanion();
    if (currentCompanion != null) {
      animationFrame.value = (animationFrame.value + 1) % currentCompanion.totalFrames;
    } else {
      animationFrame.value = (animationFrame.value + 1) % 12; // Default to 12 frames
    }

    // Same timing as character selection (120ms per frame)
    Future.delayed(const Duration(milliseconds: 120), () {
      _animate();
    });
  }
}
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

    return GetBuilder<CompanionSelectionOverlayController>(
      init: CompanionSelectionOverlayController(),
      builder: (overlayController) {
        return WillPopScope(
          onWillPop: () async {
            overlayController.dispose();
            homeController.closeCompanionSelection();
            Get.delete<CompanionSelectionOverlayController>();
            return false;
          },
          child: Stack(
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
                            overlayController.dispose();
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
          ),
        );
      },
    );
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
          // Walking Animation Preview - SAME AS CHARACTER SELECTION
          Obx(() {
            final companion = controller.getCurrentCompanion();

            if (companion == null) {
              return Container(
                width: isTablet ? 200 : 150,
                height: isTablet ? 200 : 150,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(companion.id),
                width: isTablet ? 200 : 150,
                height: isTablet ? 200 : 150,
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
            final companion = controller.getCurrentCompanion();

            if (companion == null) {
              return Text(
                'Loading...',
                style: TextStyle(
                  fontFamily: 'AkayaKanadaka',
                  fontSize: isTablet ? 28 : 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              );
            }

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

  // SAME ANIMATION LOGIC AS CHARACTER SELECTION
  Widget _buildWalkingCompanion(
      CompanionData companion,
      CompanionSelectionOverlayController controller,
      bool isTablet,
      ) {
    return Obx(() {
      final frameIndex = controller.animationFrame.value;
      final size = isTablet ? 180.0 : 130.0;

      return Image.asset(
        '${companion.animationPath}walk_${frameIndex + 1}.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to display image
          return Image.asset(
            companion.displayImagePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.pets,
                size: size * 0.6,
                color: Color(companion.color),
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
                _buildCompanionOption(controller.companions[0], controller, isTablet),
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[1], controller, isTablet),
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[2], controller, isTablet),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 20 : 15),

          // Second Row - 2 companions (Penguin, Bear)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompanionOption(controller.companions[3], controller, isTablet),
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[4], controller, isTablet),
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
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedCompanion.value == companion.id;

        return GestureDetector(
          onTap: () {
            print('🐾 Selected companion: ${companion.name}');
            controller.selectCompanion(companion.id);
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
                Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    companion.displayImagePath,
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
                          size: isTablet ? 40 : 30,
                          color: Color(companion.color),
                        ),
                      );
                    },
                  ),
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

// SAME CONTROLLER AS CHARACTER SELECTION
class CompanionSelectionOverlayController extends GetxController {
  final animationFrame = 0.obs;

  // Get max frames from current companion
  int get _totalFrames {
    final companionController = Get.find<CompanionController>();
    final companion = companionController.getCurrentCompanion();
    return companion?.totalFrames ?? 12; // Default 12 frames
  }

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 40), () {
      _animate();
    });
  }

  void _animate() {
    if (isClosed) return;

    animationFrame.value = (animationFrame.value + 1) % _totalFrames;

    Future.delayed(const Duration(milliseconds: 50), () {
      _animate();
    });
  }

  @override
  void onClose() {
    print('🧹 Companion overlay controller closed');
    super.onClose();
  }
}
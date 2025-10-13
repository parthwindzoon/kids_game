import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import '../../controllers/image_selection_controller.dart';
import '../../routes/app_pages.dart';

class ImageSelectionView extends GetView<ImageSelectionController> {
  final TiledGame game;
  const ImageSelectionView({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/coloring/image.png', fit: BoxFit.cover),
        SafeArea(
          child: Stack(
            children: [
              // Title (animated from top) - Similar to mini games
              Obx(() {
                final animValue = controller.titleAnimation.value.clamp(0.0, 1.0);
                return Positioned(
                  top: isTablet ? 80 : 60,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: animValue,
                    child: Transform.translate(
                      offset: Offset(0, -50 * (1 - animValue)),
                      child: Center(
                        child: Text(
                          "Color Filling",
                          style: TextStyle(
                            fontFamily: 'AkayaKanadaka',
                            fontSize: isTablet ? 56 : 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(3, 3),
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Horizontal Carousel - Similar to mini games
              Center(
                child: SizedBox(
                  height: isTablet ? 450 : 380,
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.svgImages.length,
                    itemBuilder: (context, index) {
                      final svgPath = controller.svgImages[index];

                      return AnimatedBuilder(
                        animation: controller.pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (controller.pageController.position.haveDimensions) {
                            value = controller.pageController.page! - index;
                            value = (1 - (value.abs() * 0.25)).clamp(0.75, 1.0);
                          }
                          return Center(
                            child: Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: _buildImageCard(svgPath, index, isTablet),
                      );
                    },
                  ),
                ),
              ),

              // Back Button (top-left)
              Positioned(
                top: isTablet ? 20 : 10,
                left: isTablet ? 20 : 10,
                child: GestureDetector(
                  onTap: () {
                    game.overlays.remove('image_selection_overlay');
                    Get.delete<ImageSelectionController>();
                  },
                  child: Image.asset('assets/images/back_btn.png', width: isTablet ? 80 : 60),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(String svgPath, int index, bool isTablet) {
    return Obx(() {
      final animValue = (controller.cardAnimations[index]?.value ?? 0.0).clamp(0.0, 1.0);

      return Opacity(
        opacity: animValue,
        child: GestureDetector(
          onTap: () {
            game.selectedColoringSvgPath = svgPath;
            game.overlays.add('coloring_page_overlay');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Circle with Floating Animation
              Obx(() {
                return Transform.translate(
                  offset: Offset(0, controller.floatingAnimation.value),
                  child: SizedBox(
                    width: isTablet ? 280 : 220,
                    height: isTablet ? 280 : 220,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Outer glow circle (orange border)
                        Container(
                          width: isTablet ? 280 : 220,
                          height: isTablet ? 280 : 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFA500),
                              width: isTablet ? 6 : 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),

                        // Inner circle with background
                        Container(
                          width: isTablet ? 250 : 190,
                          height: isTablet ? 250 : 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background image
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/images/coloring/Ellipse 6.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // SVG Image
                                Padding(
                                  padding: EdgeInsets.all(isTablet ? 35.0 : 30.0),
                                  child: SvgPicture.asset(
                                    svgPath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.blue.shade200,
                                        child: Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: isTablet ? 60 : 45,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}
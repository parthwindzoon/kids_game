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
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/coloring/image.png', fit: BoxFit.cover),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(onTap: () {
                      game.overlays.remove('image_selection_overlay');
                      Get.delete<ImageSelectionController>();
                    }, child: Image.asset('assets/images/coloring/back_btn.png', width: 60)),

                    // *** MODIFIED: Animated Title ***
                    Obx(() {
                      final animValue = controller.titleAnimation.value;
                      return Opacity(
                        opacity: animValue,
                        child: Transform.translate(
                          offset: Offset(0, -50 * (1 - animValue)),
                          child: const Text(
                            "Color Filling",
                            style: TextStyle(
                              color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 3.0, color: Colors.black54, offset: Offset(2.0, 2.0))],
                            ),
                          ),
                        ),
                      );
                    }),

                    SizedBox()
                  ],
                ),
              ),

              // *** MODIFIED: SVG Carousel with Animations ***
              Expanded(
                child: Obx(
                      () => PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.svgImages.length,
                    itemBuilder: (context, index) {
                      final svgPath = controller.svgImages[index];

                      // This builder handles the scaling of items based on their position in the PageView
                      return AnimatedBuilder(
                        animation: controller.pageController,
                        builder: (context, child) {
                          double scale = 1.0;
                          if (controller.pageController.position.haveDimensions) {
                            double page = controller.pageController.page ?? 0.0;
                            scale = (1 - ((page - index).abs() * 0.4)).clamp(0.6, 1.0);
                          }
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        // This child handles the individual fade-in and pop-up animation
                        child: Obx(() {
                          final animValue = controller.cardAnimations[index]?.value ?? 0.0;
                          return Opacity(
                            opacity: animValue,
                            child: Transform.scale(
                              scale: animValue,
                              child: GestureDetector(
                                onTap: () {
                                  game.selectedColoringSvgPath = svgPath;
                                  game.overlays.add('coloring_page_overlay');
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset('assets/images/coloring/Ellipse 6.png'),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: SvgPicture.asset(svgPath),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../game/my_game.dart';
import '../../controllers/coloring_controller.dart';
import '../widgets/drawing_painter.dart';
import '../widgets/stroke_slider.dart';
// Remove the horizontal color picker import, add the dialog import
import '../widgets/color_picker_dialog.dart';

class ColoringView extends GetView<ColoringController> {
  final TiledGame game;
  const ColoringView({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: The main drawing area (No changes here)
        Expanded(
          child: Container(
            color: Colors.white,
            child: Obx(
                  () => InteractiveViewer(
                transformationController: controller.transformationController,
                maxScale: 10.0,
                panEnabled: controller.isPanEnabled.value,
                child: Listener(
                  onPointerDown: controller.handlePointerDown,
                  onPointerMove: controller.handlePointerMove,
                  onPointerUp: controller.handlePointerUp,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Obx(() => CustomPaint(size: Size.infinite, painter: DrawingPainter(strokes: controller.history.value, currentStroke: controller.currentPath.value))),
                      IgnorePointer(child: SvgPicture.asset(controller.svgPath, fit: BoxFit.contain)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Layer 2: The right-side toolbar
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 120,
            height: Get.height,
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/coloring/tools_bg.png'), fit: BoxFit.fill)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // IconButton(onPressed: () {}, icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60)),

                // *** MODIFIED: Brush Button with Selection Outline ***
                _buildToolButton(imagePath: 'assets/images/coloring/brush.png', onTap: controller.toggleBrush, isBrush: true),

                // *** MODIFIED: Color Picker Button now opens dialog ***
                GestureDetector(
                  onTap: controller.openColorPicker, // Updated function call
                  child: Obx(() => Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: controller.selectedColor.value, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                  )),
                ),

                // *** MODIFIED: Eraser Button with Selection Outline ***
                _buildToolButton(imagePath: 'assets/images/coloring/eraser.png', onTap: controller.toggleEraser, isBrush: false),
              ],
            ),
          ),
        ),

        // Layer 3 & 4 (No changes here)
        Obx(() => controller.showStrokeSlider.value ? StrokeSlider() : const SizedBox.shrink()),

        // Layer 5: Back Button (No changes here)
        Positioned(
          top: 20,
          left: 20,
          child: GestureDetector(onTap: () {
            game.overlays.remove('coloring_page_overlay');
            Get.delete<ColoringController>();
          }, child: Image.asset('assets/images/back_btn.png', width: 60)),
        ),
      ],
    );
  }

  // *** MODIFIED: Helper widget now builds the selection outline ***
  Widget _buildToolButton({required String imagePath, required VoidCallback onTap, required bool isBrush}) {
    return Obx(() {
      // Determine if this tool is currently selected
      final bool isSelected = (isBrush && !controller.isErasing.value) || (!isBrush && controller.isErasing.value);

      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          // *** THIS IS THE UPDATED DECORATION LOGIC ***
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle, // Ensure the outline is circular
          //   border: isSelected
          //   // If selected, draw a visible orange border
          //       ? Border.all(color: const Color(0xFFF57C00), width: 4)
          //   // If not selected, use a transparent border to maintain layout size
          //       : Border.all(color: Colors.transparent, width: 4),
          // ),
          child: Image.asset(imagePath, width: 80),
        ),
      );
    });}
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/coloring_controller.dart';

class StrokeSlider extends StatelessWidget {
  final ColoringController controller = Get.find();

  StrokeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 130, // Position to the left of the main toolbar
      bottom: 50,
      top: 50,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual Preview
            Obx(
                  () => Container(
                width: controller.strokeWidth,
                height: controller.strokeWidth,
                decoration: BoxDecoration(
                  color: controller.isErasing.value ? Colors.grey : controller.selectedColor.value,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Vertical Slider
            Expanded(
              child: Obx(
                    () => RotatedBox(
                  quarterTurns: 3, // Rotate slider to be vertical
                  child: Slider(
                    value: controller.selectedStrokeIndex.value.toDouble(),
                    min: 0,
                    max: 9, // 10 steps (0 to 9)
                    divisions: 9,
                    onChanged: (value) {
                      controller.changeStrokeIndex(value);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
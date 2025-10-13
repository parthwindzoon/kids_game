import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/coloring_controller.dart';

class ColorPickerDialog extends StatelessWidget {
  final ColoringController controller = Get.find();

  ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a Color'),
      content: SizedBox(
        width: Get.width * 0.4, // Responsive width
        child: GridView.builder(
          shrinkWrap: true, // Important for content in a dialog
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // 5 colors per row
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: controller.availableColors.length,
          itemBuilder: (context, index) {
            final color = controller.availableColors[index];
            return GestureDetector(
              onTap: () {
                controller.changeColor(color);
                Get.back(); // Close dialog after selecting
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
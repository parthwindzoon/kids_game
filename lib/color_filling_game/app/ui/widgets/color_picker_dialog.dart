import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/coloring_controller.dart';

class ColorPickerDialog extends StatelessWidget {
  final ColoringController controller = Get.find();

  ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Make default dialog transparent
      insetPadding: const EdgeInsets.all(10),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Main Card Background
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), // Light yellowish "paper" color
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFFFAB00), // Fun orange border
                width: 8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Creative Title
                const Text(
                  "Pick a Color!",
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka', // Use your game's fun font
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6D00),
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        color: Colors.black12,
                        blurRadius: 2,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Color Grid
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 15, // Horizontal space between blobs
                      runSpacing: 15, // Vertical space between lines
                      children: List.generate(controller.availableColors.length, (index) {
                        final color = controller.availableColors[index];
                        return _buildColorBlob(color);
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fun "Close" Button hanging off the top right
          Positioned(
            top: -15,
            right: -10,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBlob(Color color) {
    bool isWhite = color == Colors.white;
    return GestureDetector(
      onTap: () {
        controller.changeColor(color);
        Get.back();
      },
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          // Add a white border to make colors pop, especially dark ones
          border: Border.all(
              color: isWhite ? Colors.grey.shade300 : Colors.white,
              width: 4
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}
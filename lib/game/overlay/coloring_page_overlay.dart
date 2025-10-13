// kids_game/lib/game/overlay/coloring_page_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:kids_game/color_filling_game/app/controllers/coloring_controller.dart';
import 'package:kids_game/color_filling_game/app/ui/views/coloring_view.dart';

import '../../color_filling_game/app/ui/bindings/coloring_bindings.dart';

class ColoringPageOverlay extends StatelessWidget {
  final TiledGame game;

  const ColoringPageOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // 1. Create the controller instance
    ColoringBinding().dependencies();
    final controller = Get.find<ColoringController>();

    // 2. Manually set the SVG path from the game instance
    controller.svgPath = game.selectedColoringSvgPath!;

    // 3. Pass the game instance to the view for the back button
    return ColoringView(game: game);
  }
}
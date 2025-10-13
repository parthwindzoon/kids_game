import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';

import '../../color_filling_game/app/ui/bindings/coloring_bindings.dart';
import '../../color_filling_game/app/ui/bindings/image_selection_binding.dart';
import '../../color_filling_game/app/ui/views/image_selection_view.dart';

class ImageSelectionOverlay extends StatelessWidget {
  final TiledGame game;

  const ImageSelectionOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Initialize the bindings for your game
    ImageSelectionBinding().dependencies();

    // The overlay is a simple container that shows your game's first screen
    return ImageSelectionView(game: game);
  }
}
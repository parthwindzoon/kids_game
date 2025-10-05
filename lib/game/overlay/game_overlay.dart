// lib/game/components/game_overlay.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:kids_game/game/my_game.dart';

class GameOverlay extends PositionComponent with HasGameReference<TiledGame> {
  final String buildingName;

  GameOverlay({required this.buildingName});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Ensure the overlay is on top of other components
    priority = 1001;
    anchor = Anchor.center;
    position = game.camera.viewport.size / 2;

    // Background
    final background = SpriteComponent(
      sprite: await Sprite.load('overlays/Group 67.png'),
      size: Vector2(500, 300),
      anchor: Anchor.center,
    );
    add(background);

    // Close button
    final closeButton = SpriteButtonComponent(
      button: await Sprite.load('overlays/Group 86.png'),
      onPressed: game.hideGameOverlay,
      anchor: Anchor.topRight,
      position: Vector2(245, -145),
      size: Vector2(50, 50),
    );
    add(closeButton);

    // "Play Game" button
    final playGameButton = SpriteButtonComponent(
      button: await Sprite.load('overlays/Group 93.png'),
      onPressed: () {
        // You can add logic here to enter a minigame for the building
        print('Entering $buildingName');
        game.hideGameOverlay();
      },
      anchor: Anchor.center,
      position: Vector2(0, 60),
      size: Vector2(250, 70),
    );
    add(playGameButton);

    // Building name text
    final textRenderer = TextPaint(
      style: const TextStyle(
        fontSize: 28,
        fontFamily: 'AkayaKanadaka',
        color: Color(0xFF008000), // Green color
      ),
    );

    add(
      TextComponent(
        text: 'Would you like to enter $buildingName?',
        textRenderer: textRenderer,
        anchor: Anchor.center,
        position: Vector2(0, -40),
      ),
    );
  }
}
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ControlsDisplay extends PositionComponent with HasGameRef {
  late TextComponent keyboardText;
  late TextComponent joystickText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Position in top-right corner for landscape
    position = Vector2(gameRef.size.x - 200, 20);

    // Keyboard controls text
    keyboardText = TextComponent(
      text: 'Keyboard: WASD or Arrow Keys',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 3,
              color: Colors.black54,
            ),
          ],
        ),
      ),
      position: Vector2(0, 0),
      anchor: Anchor.topRight,
    );

    // Joystick controls text
    joystickText = TextComponent(
      text: 'Touch: Use joystick (bottom-left)',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 3,
              color: Colors.black54,
            ),
          ],
        ),
      ),
      position: Vector2(0, 20),
      anchor: Anchor.topRight,
    );

    add(keyboardText);
    add(joystickText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update position if screen size changes
    position = Vector2(gameRef.size.x - 20, 20);
  }
}
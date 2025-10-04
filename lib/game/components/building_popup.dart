import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BuildingPopup extends PositionComponent with HasGameRef {
  final String buildingName;
  late TextComponent textComponent;
  late RectangleComponent background;

  BuildingPopup({required this.buildingName});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    priority = 2000; // Very high priority to appear above everything

    // Create text component
    textComponent = TextComponent(
      text: buildingName,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black87,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    // Estimate background size based on text length
    final padding = 20.0;
    final estimatedWidth = buildingName.length * 15.0; // Rough estimate
    final backgroundWidth = estimatedWidth + padding * 2;
    final backgroundHeight = 50.0;

    // Create background
    background = RectangleComponent(
      size: Vector2(backgroundWidth, backgroundHeight),
      paint: Paint()
        ..color = Colors.black.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill,
      anchor: Anchor.center,
    );

    // Add border
    final border = RectangleComponent(
      size: Vector2(backgroundWidth, backgroundHeight),
      paint: Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
      anchor: Anchor.center,
    );

    add(background);
    add(border);
    add(textComponent);

    // Position at top center of screen
    _updatePosition();
  }

  void _updatePosition() {
    // Position at top center, accounting for viewport size
    position = Vector2(
      gameRef.size.x / 2,
      60, // 60 pixels from top
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update position if screen size changes
    _updatePosition();
  }
}
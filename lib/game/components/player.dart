import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Player extends CircleComponent with HasGameRef, CollisionCallbacks, KeyboardHandler {
  static const double _speed = 200.0;
  static const double _radius = 16.0; // Adjusted for better visibility

  Vector2 direction = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};

  Player({required Vector2 position})
      : super(
    radius: _radius,
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    priority = 900;
    paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateDirectionFromKeyboard();
    velocity = direction * _speed;
    final previousPosition = position.clone();
    position += velocity * dt;

    _clampToMapBounds();

    if (_checkBuildingCollision()) {
      position.setFrom(previousPosition);
    }
  }

  void _updateDirectionFromKeyboard() {
    Vector2 keyboardDirection = Vector2.zero();

    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        _keysPressed.contains(LogicalKeyboardKey.keyA)) {
      keyboardDirection.x -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        _keysPressed.contains(LogicalKeyboardKey.keyD)) {
      keyboardDirection.x += 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        _keysPressed.contains(LogicalKeyboardKey.keyW)) {
      keyboardDirection.y -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        _keysPressed.contains(LogicalKeyboardKey.keyS)) {
      keyboardDirection.y += 1;
    }

    if (keyboardDirection.length > 0) {
      direction = keyboardDirection..normalize();
    }
  }

  void _clampToMapBounds() {
    const mapWidth = 40 * 32.0;
    const mapHeight = 40 * 32.0;
    position.x = position.x.clamp(_radius, mapWidth - _radius);
    position.y = position.y.clamp(_radius, mapHeight - _radius);
  }

  bool _checkBuildingCollision() {
    final tileX = (position.x / 32).floor();
    final tileY = (position.y / 32).floor();
    return _isBuildingTile(tileX, tileY);
  }

  bool _isBuildingTile(int tileX, int tileY) {
    if (tileX >= 2 && tileX <= 7 && tileY >= 2 && tileY <= 7) return true;
    if (tileX >= 30 && tileX <= 37 && tileY >= 2 && tileY <= 9) return true;
    if (tileX >= 2 && tileX <= 10 && tileY >= 16 && tileY <= 25) return true;
    if (tileX >= 32 && tileX <= 37 && tileY >= 16 && tileY <= 22) return true;
    if (tileX >= 17 && tileX <= 22 && tileY >= 32 && tileY <= 36) return true;
    if (tileX >= 33 && tileX <= 38 && tileY >= 33 && tileY <= 37) return true;
    return false;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, _radius,
        Paint()
          ..color = Colors.blue.shade700
          ..style = PaintingStyle.fill);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keysPressed.clear();
    _keysPressed.addAll(keysPressed);
    return true;
  }
}
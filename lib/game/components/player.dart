// lib/game/components/player.dart

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:kids_game/game/my_game.dart';

class Player extends SpriteAnimationComponent with HasGameReference<TiledGame>, CollisionCallbacks, KeyboardHandler {
  static const double _speed = 200.0;
  static const double _playerWidth = 42.0;
  static const double _playerHeight = 42.0;

  Vector2 direction = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};
  final JoystickComponent? joystick;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;

  bool _isMoving = false;

  Player({required Vector2 position, this.joystick})
      : super(
    size: Vector2(_playerWidth, _playerHeight),
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = 100;

    final idleSprites = <Sprite>[];
    for (int i = 1; i <= 10; i++) {
      final sprite = await Sprite.load('player/idle_$i.png');
      idleSprites.add(sprite);
    }
    idleAnimation = SpriteAnimation.spriteList(
      idleSprites,
      stepTime: 0.1,
      loop: true,
    );

    final walkSprites = <Sprite>[];
    for (int i = 1; i <= 10; i++) {
      final sprite = await Sprite.load('player/walk_$i.png');
      walkSprites.add(sprite);
    }
    walkAnimation = SpriteAnimation.spriteList(
      walkSprites,
      stepTime: 0.08,
      loop: true,
    );

    animation = idleAnimation;

    add(RectangleHitbox(
      size: Vector2(_playerWidth * 0.6, _playerHeight * 0.8),
      position: Vector2(_playerWidth * 0.2, _playerHeight * 0.1),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateDirectionFromJoystick();

    final wasMoving = _isMoving;
    _isMoving = direction.length > 0;

    if (_isMoving && !wasMoving) {
      animation = walkAnimation;
    } else if (!_isMoving && wasMoving) {
      animation = idleAnimation;
    }

    if (direction.x > 0) {
      scale.x = -1;
    } else if (direction.x < 0) {
      scale.x = 1;
    }

    velocity = direction * _speed;
    final previousPosition = position.clone();
    position += velocity * dt;

    _clampToMapBounds();

    if (!_isOnRoad()) {
      position.setFrom(previousPosition);
    }

    _checkNearbyBuildings();
  }

  void _updateDirectionFromJoystick() {
    if (joystick != null && joystick!.direction != JoystickDirection.idle) {
      direction = joystick!.relativeDelta;
    } else if (joystick != null && joystick!.direction == JoystickDirection.idle && _keysPressed.isEmpty) {
      direction = Vector2.zero();
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keysPressed.clear();
    _keysPressed.addAll(keysPressed);

    direction.setZero();

    if (_keysPressed.contains(LogicalKeyboardKey.keyW) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      direction.y -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyS) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      direction.y += 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyA) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      direction.x -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyD) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      direction.x += 1;
    }

    if (direction.length > 0) {
      direction.normalize();
    }

    return true;
  }

  void _clampToMapBounds() {
    const mapWidth = 20 * 64.0;
    const mapHeight = 20 * 64.0;
    position.x = position.x.clamp(_playerWidth / 2, mapWidth - _playerWidth / 2);
    position.y = position.y.clamp(_playerHeight / 2, mapHeight - _playerHeight / 2);
  }

  bool _isOnRoad() {
    final tileX = (position.x / 64).floor();
    final tileY = (position.y / 64).floor();
    final roadLayer = game.mapComponent.tileMap.getLayer<TileLayer>('Road');
    if (roadLayer == null) return false;

    if (tileX < 0 || tileY < 0 ||
        tileX >= game.mapComponent.tileMap.map.width ||
        tileY >= game.mapComponent.tileMap.map.height) {
      return false;
    }

    if (roadLayer.tileData != null &&
        tileY < roadLayer.tileData!.length &&
        tileX < roadLayer.tileData![tileY].length) {
      final gid = roadLayer.tileData![tileY][tileX].tile;
      return gid > 0;
    }
    return false;
  }

  void _checkNearbyBuildings() {
    final objectGroup = game.mapComponent.tileMap.getLayer<ObjectGroup>('collision');
    if (objectGroup == null) {
      print('Warning: collision layer not found!');
      return;
    }

    String? buildingInside;

    for (final obj in objectGroup.objects) {
      // Check if this is a building_popup object
      // In Tiled, the type is stored as a property
      final objType = obj.properties.getValue<String>('type');
      if (objType != 'building_popup') continue;

      // Check if player is INSIDE the rectangular bounds of the object
      final playerInsideBounds =
          position.x >= obj.x &&
              position.x <= obj.x + obj.width &&
              position.y >= obj.y &&
              position.y <= obj.y + obj.height;

      if (playerInsideBounds) {
        buildingInside = obj.name;
        break; // Found a building, no need to check others
      }
    }

    // Show overlay only if player is inside a building area
    if (buildingInside != null) {
      game.showBuildingOverlay(buildingInside);
    } else {
      // Hide overlay if player is not inside any building area
      game.hideAllOverlays();
      // Reset the manually closed flag when player leaves the area
      game.overlayManuallyClosed = false;
    }
  }
}
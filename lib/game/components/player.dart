import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:kids_game/game/my_game.dart';

class Player extends SpriteAnimationComponent with HasGameReference<TiledGame>, CollisionCallbacks, KeyboardHandler {
  static const double _speed = 200.0;
  static const double _playerWidth = 42.0; // Adjust based on your sprite size
  static const double _playerHeight = 42.0; // Adjust based on your sprite size

  Vector2 direction = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};
  final JoystickComponent? joystick;

  // Animation states
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

    priority = 100; // High priority to render above map

    // Load idle animation (10 frames)
    final idleSprites = <Sprite>[];
    for (int i = 1; i <= 10; i++) {
      final sprite = await Sprite.load('player/idle_$i.png');
      idleSprites.add(sprite);
    }
    idleAnimation = SpriteAnimation.spriteList(
      idleSprites,
      stepTime: 0.1, // 100ms per frame for smooth animation
      loop: true,
    );

    // Load walk animation (10 frames)
    final walkSprites = <Sprite>[];
    for (int i = 1; i <= 10; i++) {
      final sprite = await Sprite.load('player/walk_$i.png');
      walkSprites.add(sprite);
    }
    walkAnimation = SpriteAnimation.spriteList(
      walkSprites,
      stepTime: 0.08, // Slightly faster for walk animation
      loop: true,
    );

    // Start with idle animation
    animation = idleAnimation;

    // Add collision hitbox (adjust size as needed)
    add(RectangleHitbox(
      size: Vector2(_playerWidth * 0.6, _playerHeight * 0.8), // Slightly smaller than sprite
      position: Vector2(_playerWidth * 0.2, _playerHeight * 0.1), // Center the hitbox
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle both keyboard and joystick input
    // _updateDirectionFromKeyboard();
    _updateDirectionFromJoystick();

    // Check if player is moving
    final wasMoving = _isMoving;
    _isMoving = direction.length > 0;

    // Switch animations based on movement
    if (_isMoving && !wasMoving) {
      animation = walkAnimation;
    } else if (!_isMoving && wasMoving) {
      animation = idleAnimation;
    }

    // Handle sprite flipping based on movement direction
    if (direction.x > 0) {
      scale.x = -1; // Face right
    } else if (direction.x < 0) {
      scale.x = 1; // Face left (flip sprite)
    }

    velocity = direction * _speed;
    final previousPosition = position.clone();
    position += velocity * dt;

    _clampToMapBounds();

    // if (_checkBuildingCollision()) {
    //   position.setFrom(previousPosition);
    // }
  }

  // void _updateDirectionFromKeyboard() {
  //   Vector2 keyboardDirection = Vector2.zero();
  //
  //   if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
  //       _keysPressed.contains(LogicalKeyboardKey.keyA)) {
  //     keyboardDirection.x -= 1;
  //   }
  //   if (_keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
  //       _keysPressed.contains(LogicalKeyboardKey.keyD)) {
  //     keyboardDirection.x += 1;
  //   }
  //   if (_keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
  //       _keysPressed.contains(LogicalKeyboardKey.keyW)) {
  //     keyboardDirection.y -= 1;
  //   }
  //   if (_keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
  //       _keysPressed.contains(LogicalKeyboardKey.keyS)) {
  //     keyboardDirection.y += 1;
  //   }
  //
  //   if (keyboardDirection.length > 0) {
  //     direction = keyboardDirection..normalize();
  //   }
  // }

  void _updateDirectionFromJoystick() {
    if (joystick != null && joystick!.direction != JoystickDirection.idle) {
      // Use joystick's relativeDelta for smooth movement
      direction = joystick!.relativeDelta;
    } else if (joystick != null && joystick!.direction == JoystickDirection.idle && _keysPressed.isEmpty) {
      // Stop moving when joystick is idle and no keys are pressed
      direction = Vector2.zero();
    }
  }

  void _clampToMapBounds() {
    const mapWidth = 40 * 32.0;
    const mapHeight = 40 * 32.0;
    position.x = position.x.clamp(_playerWidth / 2, mapWidth - _playerWidth / 2);
    position.y = position.y.clamp(_playerHeight / 2, mapHeight - _playerHeight / 2);
  }

  // bool _checkBuildingCollision() {
  //   final tileX = (position.x / 64).floor();
  //   final tileY = (position.y / 64).floor();
  //   return _isBuildingTile(tileX, tileY);
  // }

  // bool _isBuildingTile(int tileX, int tileY) {
  //   if (tileX >= 2 && tileX <= 7 && tileY >= 2 && tileY <= 7) return true;
  //   if (tileX >= 30 && tileX <= 37 && tileY >= 2 && tileY <= 9) return true;
  //   if (tileX >= 2 && tileX <= 10 && tileY >= 16 && tileY <= 25) return true;
  //   if (tileX >= 32 && tileX <= 37 && tileY >= 16 && tileY <= 22) return true;
  //   if (tileX >= 17 && tileX <= 22 && tileY >= 32 && tileY <= 36) return true;
  //   if (tileX >= 33 && tileX <= 38 && tileY >= 33 && tileY <= 37) return true;
  //   return false;
  // }

  // @override
  // bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  //   _keysPressed.clear();
  //   _keysPressed.addAll(keysPressed);
  //   return true;
  // }
}
// lib/game/components/player.dart

import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import '../../controllers/character_controller.dart';

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
  String _currentCharacter = 'player';

  // ✅ FIX 1: Add flags to prevent race conditions
  bool _isReloadingAnimations = false;
  bool _animationsLoaded = false;

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

    // ✅ FIX 2: Safe controller access with fallback
    if (!Get.isRegistered<CharacterController>()) {
      print('⚠️ CharacterController not registered, using default player');
      _currentCharacter = 'player';
    } else {
      final characterController = Get.find<CharacterController>();
      _currentCharacter = characterController.selectedCharacter.value;
    }

    await _loadCharacterAnimations();

    add(RectangleHitbox(
      size: Vector2(_playerWidth * 0.6, _playerHeight * 0.8),
      position: Vector2(_playerWidth * 0.2, _playerHeight * 0.1),
    ));

    // Listen for character changes
    if (Get.isRegistered<CharacterController>()) {
      final characterController = Get.find<CharacterController>();
      ever(characterController.selectedCharacter, (_) {
        _onCharacterChanged();
      });
    }
  }

  // ✅ FIX 3: Robust animation loading with fallbacks and placeholders
  Future<void> _loadCharacterAnimations() async {
    _animationsLoaded = false;

    if (!Get.isRegistered<CharacterController>()) {
      await _loadDefaultAnimations();
      return;
    }

    final characterController = Get.find<CharacterController>();
    final character = characterController.getCurrentCharacter();

    // Load idle animation
    final idleSprites = await _loadAnimationFrames(
      folder: character.folderName,
      prefix: 'idle',
      totalFrames: 10,
      fallbackFolder: 'player',
    );

    // ✅ FIX 4: If no sprites loaded, create emergency placeholder
    if (idleSprites.isEmpty) {
      print('❌ CRITICAL: No idle sprites loaded for ${character.folderName}, using placeholder');
      idleSprites.add(await _createPlaceholderSprite());
    }

    idleAnimation = SpriteAnimation.spriteList(
      idleSprites,
      stepTime: 0.1,
      loop: true,
    );

    // Load walk animation
    final walkSprites = await _loadAnimationFrames(
      folder: character.folderName,
      prefix: 'walk',
      totalFrames: 10,
      fallbackFolder: 'player',
    );

    if (walkSprites.isEmpty) {
      print('❌ CRITICAL: No walk sprites loaded for ${character.folderName}, using placeholder');
      walkSprites.add(await _createPlaceholderSprite());
    }

    walkAnimation = SpriteAnimation.spriteList(
      walkSprites,
      stepTime: 0.08,
      loop: true,
    );

    animation = idleAnimation;
    _animationsLoaded = true;
    print('✅ Player animations loaded: ${idleSprites.length} idle, ${walkSprites.length} walk frames');
  }

  // ✅ FIX 5: Helper method to load animation frames safely
  Future<List<Sprite>> _loadAnimationFrames({
    required String folder,
    required String prefix,
    required int totalFrames,
    String? fallbackFolder,
  }) async {
    final sprites = <Sprite>[];

    for (int i = 1; i <= totalFrames; i++) {
      try {
        final sprite = await Sprite.load('$folder/${prefix}_$i.png');
        sprites.add(sprite);
      } catch (e) {
        print('⚠️ Error loading $prefix frame $i for $folder: $e');

        // Try fallback folder
        if (fallbackFolder != null && folder != fallbackFolder) {
          try {
            final fallbackSprite = await Sprite.load('$fallbackFolder/${prefix}_$i.png');
            sprites.add(fallbackSprite);
            print('✅ Loaded fallback sprite: $fallbackFolder/${prefix}_$i.png');
          } catch (e2) {
            print('❌ Fallback also failed for $prefix frame $i: $e2');
            // Continue to next frame
          }
        }
      }
    }

    return sprites;
  }

  // ✅ FIX 6: Load default player animations as absolute fallback
  Future<void> _loadDefaultAnimations() async {
    print('⚠️ Loading default player animations');

    final idleSprites = await _loadAnimationFrames(
      folder: 'player',
      prefix: 'idle',
      totalFrames: 10,
      fallbackFolder: null,
    );

    if (idleSprites.isEmpty) {
      idleSprites.add(await _createPlaceholderSprite());
    }

    final walkSprites = await _loadAnimationFrames(
      folder: 'player',
      prefix: 'walk',
      totalFrames: 10,
      fallbackFolder: null,
    );

    if (walkSprites.isEmpty) {
      walkSprites.add(await _createPlaceholderSprite());
    }

    idleAnimation = SpriteAnimation.spriteList(idleSprites, stepTime: 0.1, loop: true);
    walkAnimation = SpriteAnimation.spriteList(walkSprites, stepTime: 0.08, loop: true);
    animation = idleAnimation;
    _animationsLoaded = true;
  }

  // ✅ FIX 7: Emergency placeholder sprite generation
  Future<Sprite> _createPlaceholderSprite() async {
    try {
      // Try to load the first idle frame of default player
      return await Sprite.load('player/idle_1.png');
    } catch (e) {
      print('⚠️ Even default sprite failed, creating colored rectangle');
      // Last resort: create a colored rectangle sprite
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = Paint()..color = const Color(0xFFFF6B6B);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 42, 42), paint);
      final picture = recorder.endRecording();
      final image = await picture.toImage(42, 42);
      return Sprite(image);
    }
  }

  // ✅ FIX 8: Safe character change with animation reload protection
  Future<void> _onCharacterChanged() async {
    if (!Get.isRegistered<CharacterController>()) return;

    final characterController = Get.find<CharacterController>();
    final newCharacter = characterController.selectedCharacter.value;

    if (_currentCharacter != newCharacter) {
      _isReloadingAnimations = true;  // Block animation switches during reload
      _currentCharacter = newCharacter;

      await _loadCharacterAnimations();

      _isReloadingAnimations = false;  // Re-enable animation switches
    }
  }

  @override
  void update(double dt) {
    // ✅ FIX 9: Don't update animations during reload or before loaded
    if (_isReloadingAnimations || !_animationsLoaded) {
      super.update(dt);
      return;
    }

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

  // ✅ FIX 10: Safer null checking for road layer
  bool _isOnRoad() {
    final tileX = (position.x / 64).floor();
    final tileY = (position.y / 64).floor();
    final roadLayer = game.mapComponent.tileMap.getLayer<TileLayer>('Road');

    if (roadLayer?.tileData == null) return false;

    if (tileX < 0 || tileY < 0 ||
        tileX >= game.mapComponent.tileMap.map.width ||
        tileY >= game.mapComponent.tileMap.map.height) {
      return false;
    }

    final tileData = roadLayer!.tileData!;

    // Check bounds before accessing nested array
    if (tileY >= tileData.length || tileX >= tileData[tileY].length) {
      return false;
    }

    final gid = tileData[tileY][tileX].tile;
    return gid > 0;
  }

  void _checkNearbyBuildings() {
    final objectGroup = game.mapComponent.tileMap.getLayer<ObjectGroup>('collision');
    if (objectGroup == null) {
      print('Warning: collision layer not found!');
      return;
    }

    String? buildingInside;

    for (final obj in objectGroup.objects) {
      // ✅ FIX 11: Safe property access
      final objType = obj.properties.getValue<String>('type');
      if (objType == null || objType != 'building_popup') continue;

      final playerInsideBounds =
          position.x >= obj.x &&
              position.x <= obj.x + obj.width &&
              position.y >= obj.y &&
              position.y <= obj.y + obj.height;

      if (playerInsideBounds) {
        buildingInside = obj.name;
        break;
      }
    }

    if (buildingInside != null) {
      game.showBuildingOverlay(buildingInside);
    } else {
      game.hideAllOverlays();
      game.overlayManuallyClosed = false;
    }
  }
}
// lib/game/components/companion_component.dart

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import '../../controllers/companion_controller.dart';
import 'player.dart';

class CompanionComponent extends SpriteAnimationComponent
    with HasGameReference<TiledGame>, CollisionCallbacks {
  final Player player;

  static const double _companionWidth = 42.0;
  static const double _companionHeight = 42.0;
  static const double _minDistance = 60.0;
  static const double _maxDistance = 100.0;
  static const double _followSpeed = 180.0;

  Vector2 velocity = Vector2.zero();

  // NEW: Separate animations for idle and walk
  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;

  String _currentCompanion = 'robo';
  bool _isLoadingAnimation = false;
  bool _isDisposed = false;
  bool _isMoving = false; // NEW: Track movement state

  final List<Vector2> _positionHistory = [];
  static const int _historySize = 30;

  CompanionComponent({
    required this.player,
    required Vector2 position,
  }) : super(
    size: Vector2(_companionWidth, _companionHeight),
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = 99;

    try {
      final companionController = Get.find<CompanionController>();
      final companion = companionController.getCurrentCompanion();

      if (companion != null) {
        _currentCompanion = companion.id;
        await _loadAnimations(); // CHANGED: Load both animations
      }

      add(RectangleHitbox(
        size: Vector2(_companionWidth * 0.6, _companionHeight * 0.8),
        position: Vector2(_companionWidth * 0.2, _companionHeight * 0.1),
      ));

      // Initialize position history with player's starting position
      for (int i = 0; i < _historySize; i++) {
        _positionHistory.add(player.position.clone());
      }
    } catch (e) {
      print('❌ Error in CompanionComponent onLoad: $e');
      _currentCompanion = 'robo';
    }
  }

  // NEW: Method to manually update companion when returning from home
  Future<void> refreshCompanion() async {
    if (_isDisposed) return;

    try {
      final companionController = Get.find<CompanionController>();
      final companion = companionController.getCurrentCompanion();

      if (companion != null && companion.id != _currentCompanion) {
        print('🔄 Refreshing companion from ${_currentCompanion} to ${companion.id}');
        _currentCompanion = companion.id;
        await _loadAnimations(); // CHANGED: Load both animations
      }
    } catch (e) {
      print('❌ Error refreshing companion: $e');
    }
  }

  // UPDATED: Load both idle and walk animations
  Future<void> _loadAnimations() async {
    if (_isLoadingAnimation || _isDisposed) {
      return;
    }

    _isLoadingAnimation = true;

    try {
      if (!Get.isRegistered<CompanionController>()) {
        _isLoadingAnimation = false;
        return;
      }

      final companionController = Get.find<CompanionController>();
      final companion = companionController.getCurrentCompanion();

      if (companion == null) {
        _isLoadingAnimation = false;
        return;
      }

      print('🔄 Loading animations for: ${companion.name}');

      // Load idle animation
      await _loadIdleAnimation(companion);

      // Load walk animation
      await _loadWalkAnimation(companion);

      // Set initial animation to idle
      if (!_isDisposed && mounted == true) {
        animation = idleAnimation;
        print('✅ Both animations loaded successfully for ${companion.name}');
      }

    } catch (e) {
      print('❌ Error in _loadAnimations: $e');
    } finally {
      _isLoadingAnimation = false;
    }
  }

  // NEW: Load idle animation frames
  Future<void> _loadIdleAnimation(CompanionData companion) async {
    final idleSprites = <Sprite>[];

    // Use the specific idle frame count for each companion
    for (int i = 1; i <= companion.idleFrames; i++) {
      if (_isDisposed) return;

      try {
        final imagePath = 'companions/${companion.folderName}/idle_$i.png';
        final sprite = await Sprite.load(imagePath);
        idleSprites.add(sprite);
      } catch (e) {
        print('⚠️ Error loading idle frame $i for ${companion.folderName}: $e');

        // Try fallback to robo
        if (companion.folderName != 'robo') {
          try {
            final fallbackSprite = await Sprite.load('companions/robo/idle_$i.png');
            idleSprites.add(fallbackSprite);
          } catch (e2) {
            print('❌ Idle fallback failed: $e2');
            continue;
          }
        } else {
          continue;
        }
      }
    }

    if (idleSprites.isNotEmpty && !_isDisposed) {
      idleAnimation = SpriteAnimation.spriteList(
        idleSprites,
        stepTime: 0.1, // Slower for idle animation
        loop: true,
      );
      print('✅ Idle animation loaded: ${idleSprites.length} frames for ${companion.name}');
    }
  }

  // UPDATED: Load walk animation frames
  Future<void> _loadWalkAnimation(CompanionData companion) async {
    final walkSprites = <Sprite>[];

    for (int i = 1; i <= companion.totalFrames; i++) {
      if (_isDisposed) return;

      try {
        final imagePath = 'companions/${companion.folderName}/walk_$i.png';
        final sprite = await Sprite.load(imagePath);
        walkSprites.add(sprite);
      } catch (e) {
        print('⚠️ Error loading walk frame $i for ${companion.folderName}: $e');

        // Try fallback to robo
        if (companion.folderName != 'robo') {
          try {
            final fallbackSprite = await Sprite.load('companions/robo/walk_$i.png');
            walkSprites.add(fallbackSprite);
          } catch (e2) {
            print('❌ Walk fallback failed: $e2');
            continue;
          }
        } else {
          continue;
        }
      }
    }

    if (walkSprites.isNotEmpty && !_isDisposed) {
      walkAnimation = SpriteAnimation.spriteList(
        walkSprites,
        stepTime: 0.08, // Faster for walk animation
        loop: true,
      );
      print('✅ Walk animation loaded: ${walkSprites.length} frames');
    }
  }

  @override
  void update(double dt) {
    if (_isDisposed) return;

    try {
      super.update(dt);

      if (_positionHistory.isNotEmpty) {
        _positionHistory.removeAt(0);
        _positionHistory.add(player.position.clone());

        final targetPosition = _positionHistory.first;
        final distanceToPlayer = position.distanceTo(player.position);

        final wasMoving = _isMoving;

        if (distanceToPlayer > _minDistance) {
          final direction = (targetPosition - position);
          final distanceToTarget = direction.length;

          if (distanceToTarget > 5.0) {
            _isMoving = true;
            direction.normalize();
            velocity = direction * _followSpeed;
            position += velocity * dt;

            if (velocity.x > 0.5) {
              scale.x = -1;
            } else if (velocity.x < -0.5) {
              scale.x = 1;
            }
          } else {
            _isMoving = false;
            velocity.setZero();
          }
        } else {
          _isMoving = false;
          velocity.setZero();
        }

        // NEW: Switch between idle and walk animations
        if (_isMoving && !wasMoving) {
          // Started moving - switch to walk
          if (mounted == true) {
            animation = walkAnimation;
          }
        } else if (!_isMoving && wasMoving) {
          // Stopped moving - switch to idle
          if (mounted == true) {
            animation = idleAnimation;
          }
        }

        _clampToMapBounds();
      }
    } catch (e) {
      print('❌ Error in companion update: $e');
    }
  }

  void _clampToMapBounds() {
    const mapWidth = 20 * 64.0;
    const mapHeight = 20 * 64.0;

    position.x = position.x.clamp(
      _companionWidth / 2,
      mapWidth - _companionWidth / 2,
    );
    position.y = position.y.clamp(
      _companionHeight / 2,
      mapHeight - _companionHeight / 2,
    );
  }

  @override
  void onRemove() {
    _isDisposed = true;
    _isLoadingAnimation = false;
    _positionHistory.clear();
    super.onRemove();
  }

  @override
  void removeFromParent() {
    _isDisposed = true;
    super.removeFromParent();
  }
}
//```
//
//**Key changes made:**
//
//## **🆕 New Features Added:**
//
//1. **Separate Animations**: `idleAnimation` and `walkAnimation`
//2. **Movement Tracking**: `_isMoving` flag to detect when companion moves
//3. **Dynamic Switching**: Automatically switches between idle/walk based on movement
//4. **Idle Frame Loading**: Loads `idle_1.png`, `idle_2.png`, etc.
//
//## **⚙️ How It Works:**
//
//- **When Still**: Shows idle animation (slower, 0.1s per frame)
//- **When Moving**: Shows walk animation (faster, 0.08s per frame)
//- **Auto-Switch**: Seamlessly transitions between animations based on movement
//
//## **📁 Expected Asset Structure:**
//```
//assets/images/companions/
//├── robo/
//│   ├── idle_1.png, idle_2.png, ..., idle_10.png
//│   └── walk_1.png, walk_2.png, ..., walk_21.png
//├── teddy/
//│   ├── idle_1.png, idle_2.png, ..., idle_10.png
//│   └── walk_1.png, walk_2.png, ..., walk_12.png
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
  static const double _minDistance = 60.0; // Minimum distance from player
  static const double _maxDistance = 100.0; // Start following at this distance
  static const double _followSpeed = 180.0; // Following speed

  Vector2 velocity = Vector2.zero();

  late SpriteAnimation walkAnimation;

  String _currentCompanion = 'robo';

  // Position history for delayed following
  final List<Vector2> _positionHistory = [];
  static const int _historySize = 30; // Frames to delay

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

    final companionController = Get.find<CompanionController>();
    final companion = companionController.getCurrentCompanion();

    if (companion != null) {
      _currentCompanion = companion.id;
      await _loadAnimation();
    }

    add(RectangleHitbox(
      size: Vector2(_companionWidth * 0.6, _companionHeight * 0.8),
      position: Vector2(_companionWidth * 0.2, _companionHeight * 0.1),
    ));

    // Listen for companion changes
    ever(companionController.selectedCompanion, (_) async {
      final newCompanion = companionController.selectedCompanion.value;
      if (_currentCompanion != newCompanion) {
        _currentCompanion = newCompanion;
        await _loadAnimation();
      }
    });

    // Initialize position history with player's starting position
    for (int i = 0; i < _historySize; i++) {
      _positionHistory.add(player.position.clone());
    }
  }

  Future<void> _loadAnimation() async {
    final companionController = Get.find<CompanionController>();
    final companion = companionController.getCurrentCompanion();

    if (companion == null) return;

    final sprites = <Sprite>[];

    // Load all walk frames
    for (int i = 1; i <= companion.totalFrames; i++) {
      try {
        final sprite = await Sprite.load(
            'companions/${companion.folderName}/walk_$i.png'
        );
        sprites.add(sprite);
      } catch (e) {
        print('⚠️ Error loading sprite $i for ${companion.folderName}: $e');
        // Try fallback to robo
        if (companion.folderName != 'robo') {
          try {
            final fallbackSprite = await Sprite.load('companions/robo/walk_$i.png');
            sprites.add(fallbackSprite);
          } catch (e2) {
            print('⚠️ Fallback failed: $e2');
          }
        }
      }
    }

    if (sprites.isNotEmpty) {
      walkAnimation = SpriteAnimation.spriteList(
        sprites,
        stepTime: 0.08, // Animation speed
        loop: true,
      );
      animation = walkAnimation;
      print('✅ Loaded ${sprites.length} frames for ${companion.name}');
    } else {
      print('❌ No sprites loaded for companion');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update position history (circular buffer)
    _positionHistory.removeAt(0);
    _positionHistory.add(player.position.clone());

    // Get target position from history (creates delay)
    final targetPosition = _positionHistory.first;

    // Calculate distance to player (not target)
    final distanceToPlayer = position.distanceTo(player.position);

    // Only move if player is far enough away
    if (distanceToPlayer > _minDistance) {
      // Calculate direction to target position
      final direction = (targetPosition - position);
      final distanceToTarget = direction.length;

      if (distanceToTarget > 5.0) { // Small threshold to avoid jittering
        // Normalize direction
        direction.normalize();

        // Move toward target
        velocity = direction * _followSpeed;
        position += velocity * dt;

        // Face the direction of movement - SAME AS PLAYER
        if (velocity.x > 0.5) {
          scale.x = -1; // Moving right, face right (flip sprite)
        } else if (velocity.x < -0.5) {
          scale.x = 1; // Moving left, face left (normal)
        }
        // If mostly vertical movement, keep current facing direction
      } else {
        velocity.setZero();
      }
    } else {
      // Too close to player, stop moving
      velocity.setZero();
    }

    // Keep companion within map bounds
    _clampToMapBounds();
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
}
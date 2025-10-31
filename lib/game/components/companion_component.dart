// lib/game/components/companion_component.dart

import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
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

  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;

  String _currentCompanion = 'robo';
  bool _isLoadingAnimation = false;
  bool _isDisposed = false;
  bool _isMoving = false;
  bool _animationsLoaded = false;

  late CompanionController _companionController;

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
      if (!Get.isRegistered<CompanionController>()) {
        print('⚠️ CompanionController not registered');
        _currentCompanion = 'robo';
        await _loadDefaultAnimations();
        return;
      }

      _companionController = Get.find<CompanionController>();
      final companion = _companionController.getCurrentCompanion();

      if (companion != null) {
        _currentCompanion = companion.id;
        await _loadAnimations();
      } else {
        await _loadDefaultAnimations();
      }

      add(RectangleHitbox(
        size: Vector2(_companionWidth * 0.6, _companionHeight * 0.8),
        position: Vector2(_companionWidth * 0.2, _companionHeight * 0.1),
      ));

      for (int i = 0; i < _historySize; i++) {
        _positionHistory.add(player.position.clone());
      }
      opacity = 1.0;

      print('✅ CompanionComponent loaded successfully for $_currentCompanion');

    } catch (e) {
      print('❌ Error in CompanionComponent onLoad: $e');
      _currentCompanion = 'robo';
      await _loadDefaultAnimations();
    }
  }

  Future<void> _loadAnimations() async {
    if (_isLoadingAnimation || _isDisposed) return;

    _isLoadingAnimation = true;
    _animationsLoaded = false;

    try {
      if (!Get.isRegistered<CompanionController>()) {
        await _loadDefaultAnimations();
        return;
      }

      final companion = _companionController.companions.firstWhere(
              (c) => c.id == _currentCompanion,
          orElse: () => _companionController.companions[0]
      );

      print('🔄 Loading animations for: ${companion.name}');

      await _loadIdleAnimation(companion);
      await _loadWalkAnimation(companion);

      if (!_isDisposed && idleAnimation != null && walkAnimation != null) {
        animation = idleAnimation;
        opacity = 1.0;
        _animationsLoaded = true;
        print('✅ Both animations loaded and ready for ${companion.name}');
      }
    } catch (e) {
      print('❌ Error loading animations: $e');
      await _loadDefaultAnimations();
    } finally {
      _isLoadingAnimation = false;
    }
  }

  Future<void> _loadDefaultAnimations() async {
    if (_isDisposed) return;
    print('⚠️ Loading default robo animations');
    _animationsLoaded = false;
    try {
      final idleSprites = await _loadSpriteFrames(folder: 'robo', prefix: 'idle', maxFrames: 10);
      if (idleSprites.isEmpty) idleSprites.add(await _createPlaceholderSprite());
      final walkSprites = await _loadSpriteFrames(folder: 'robo', prefix: 'walk', maxFrames: 10);
      if (walkSprites.isEmpty) walkSprites.add(await _createPlaceholderSprite());
      if (!_isDisposed) {
        idleAnimation = SpriteAnimation.spriteList(idleSprites, stepTime: 0.1, loop: true);
        walkAnimation = SpriteAnimation.spriteList(walkSprites, stepTime: 0.08, loop: true);
        animation = idleAnimation;
        opacity = 1.0;
        _animationsLoaded = true;
      }
    } catch (e) {
      print('❌ Error loading defaults: $e');
      await _createEmergencyAnimation();
    }
  }

  Future<void> _loadIdleAnimation(CompanionData companion) async {
    final idleSprites = await _loadSpriteFrames(
      folder: companion.folderName,
      prefix: 'idle',
      maxFrames: companion.idleFrames,
      fallbackFolder: 'robo',
    );
    if (idleSprites.isEmpty && !_isDisposed) idleSprites.add(await _createPlaceholderSprite());
    if (!_isDisposed && idleSprites.isNotEmpty) {
      idleAnimation = SpriteAnimation.spriteList(idleSprites, stepTime: 0.1, loop: true);
    }
  }

  Future<void> _loadWalkAnimation(CompanionData companion) async {
    final walkSprites = await _loadSpriteFrames(
      folder: companion.folderName,
      prefix: 'walk',
      maxFrames: companion.totalFrames,
      fallbackFolder: 'robo',
    );
    if (walkSprites.isEmpty && !_isDisposed) walkSprites.add(await _createPlaceholderSprite());
    if (!_isDisposed && walkSprites.isNotEmpty) {
      walkAnimation = SpriteAnimation.spriteList(walkSprites, stepTime: 0.08, loop: true);
    }
  }

  Future<List<Sprite>> _loadSpriteFrames({
    required String folder,
    required String prefix,
    required int maxFrames,
    String? fallbackFolder,
  }) async {
    final sprites = <Sprite>[];
    for (int i = 1; i <= maxFrames; i++) {
      if (_isDisposed) break;
      try {
        final sprite = await Sprite.load('companions/$folder/${prefix}_$i.png', images: game.images);
        sprites.add(sprite);
      } catch (e) {
        if (fallbackFolder != null && folder != fallbackFolder) {
          try {
            final sprite = await Sprite.load('companions/$fallbackFolder/${prefix}_$i.png', images: game.images);
            sprites.add(sprite);
          } catch (_) {}
        }
      }
    }
    return sprites;
  }

  Future<Sprite> _createPlaceholderSprite() async {
    try {
      return await Sprite.load('companions/robo/idle_1.png', images: game.images);
    } catch (e) {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = Paint()..color = const Color(0xFF808080);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 42, 42), paint);
      final picture = recorder.endRecording();
      final image = await picture.toImage(42, 42);
      return Sprite(image);
    }
  }

  Future<void> _createEmergencyAnimation() async {
    if (_isDisposed) return;
    final placeholder = await _createPlaceholderSprite();
    idleAnimation = SpriteAnimation.spriteList([placeholder], stepTime: 0.1, loop: true);
    walkAnimation = SpriteAnimation.spriteList([placeholder], stepTime: 0.08, loop: true);
    animation = idleAnimation;
    opacity = 1.0;
    _animationsLoaded = true;
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
            if (velocity.x > 0.5) scale.x = -1;
            else if (velocity.x < -0.5) scale.x = 1;
          } else {
            _isMoving = false;
            velocity.setZero();
          }
        } else {
          _isMoving = false;
          velocity.setZero();
        }
        if (_animationsLoaded && idleAnimation != null && walkAnimation != null) {
          if (_isMoving && !wasMoving) animation = walkAnimation;
          else if (!_isMoving && wasMoving) animation = idleAnimation;
        }
        _clampToMapBounds();
      }
    } catch (e) {
      print('❌ Error in update: $e');
    }
  }

  void _clampToMapBounds() {
    const mapWidth = 20 * 64.0;
    const mapHeight = 20 * 64.0;
    position.x = position.x.clamp(_companionWidth / 2, mapWidth - _companionWidth / 2);
    position.y = position.y.clamp(_companionHeight / 2, mapHeight - _companionHeight / 2);
  }

  @override
  void onRemove() {
    print('🔥 CompanionComponent onRemove() called for $_currentCompanion');
    _isDisposed = true;
    _positionHistory.clear();

    // Don't clear cache - let Flutter manage it automatically
    // Cache staying in memory is good - makes subsequent loads instant

    super.onRemove();
  }

  @override
  void removeFromParent() {
    print('🔥 CompanionComponent removeFromParent() called for $_currentCompanion');
    _isDisposed = true;
    super.removeFromParent();
  }
}
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class JoystickComponent extends PositionComponent with HasGameRef, TapCallbacks, DragCallbacks {
  static const double _knobRadius = 15.0;
  static const double _backgroundRadius = 40.0;
  static const double _deadZone = 0.1;

  final Player player;
  late CircleComponent background;
  late CircleComponent knob;

  Vector2 _knobPosition = Vector2.zero();
  bool _isDragging = false;

  JoystickComponent({required this.player});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    priority = 1000;

    background = CircleComponent(
      radius: _backgroundRadius,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill,
      position: Vector2.zero(),
      anchor: Anchor.center,
    );

    knob = CircleComponent(
      radius: _knobRadius,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.fill,
      position: Vector2.zero(),
      anchor: Anchor.center,
    );

    add(background);
    add(knob);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isDragging) {
      _knobPosition.lerp(Vector2.zero(), dt * 10);
      if (_knobPosition.length < 1.0) {
        _knobPosition.setZero();
      }
    }

    knob.position = _knobPosition;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    _isDragging = true;
    _updateKnobPosition(event.localPosition);
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    _isDragging = false;
    player.direction.setZero();
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (_isDragging) {
      _updateKnobPosition(event.localEndPosition);
      return true;
    }
    return false;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    _isDragging = false;
    player.direction.setZero();
    return true;
  }

  void _updateKnobPosition(Vector2 localPosition) {
    final distance = localPosition.distanceTo(Vector2.zero());
    if (distance <= _backgroundRadius) {
      _knobPosition = localPosition;
    } else {
      _knobPosition = localPosition.normalized() * _backgroundRadius;
    }

    final normalizedPosition = _knobPosition / _backgroundRadius;
    if (normalizedPosition.length > _deadZone) {
      player.direction = normalizedPosition;
    } else {
      if (_isDragging) {
        player.direction.setZero();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(
      Offset.zero,
      _backgroundRadius,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
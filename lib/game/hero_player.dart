import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 支援職の主人公。左スティックの入力方向・強さに応じて移動する。
class HeroPlayer extends PositionComponent {
  static const double speed = 200; // px/sec

  final JoystickComponent joystick;

  HeroPlayer({required this.joystick, super.position})
    : super(size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(
      CircleComponent(
        radius: size.x / 2,
        paint: Paint()..color = const Color(0xFF4FC3F7),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (joystick.direction == JoystickDirection.idle) {
      return;
    }
    position += joystick.relativeDelta * speed * dt;
  }
}

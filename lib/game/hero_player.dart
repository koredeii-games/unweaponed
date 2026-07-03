import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'party_member.dart';

/// 支援職の主人公。左スティックの入力方向・強さに応じて移動する。
/// 単体ヒール: 対象指定 → 詠唱 → 発動。詠唱中は低速移動になるが足は止まらない。
class HeroPlayer extends PositionComponent {
  static const double speed = 200; // px/sec
  static const double castingSpeedMultiplier = 0.4; // 詠唱中の移動速度倍率(要バランス調整)
  static const double singleHealCastTime = 1.5; // 詠唱時間・秒(要バランス調整)
  static const double singleHealAmount = 40; // 回復量(要バランス調整)

  final JoystickComponent joystick;

  PartyMember? _castTarget;
  double _castTimeRemaining = 0;

  bool get isCasting => _castTarget != null;
  double get castProgress =>
      isCasting ? 1 - (_castTimeRemaining / singleHealCastTime) : 0;

  late final RectangleComponent _castBarFill;

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

    add(
      RectangleComponent(
        size: Vector2(size.x, 4),
        position: Vector2(0, -12),
        paint: Paint()..color = Colors.black54,
      ),
    );
    _castBarFill = RectangleComponent(
      size: Vector2.zero(),
      position: Vector2(0, -12),
      paint: Paint()..color = const Color(0xFFFFD54F),
    );
    add(_castBarFill);
  }

  /// 対象への単体ヒール詠唱を開始する。詠唱中は新規詠唱を受け付けない。
  void beginHealCast(PartyMember target) {
    if (isCasting) {
      return;
    }
    _castTarget = target;
    _castTimeRemaining = singleHealCastTime;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (joystick.direction != JoystickDirection.idle) {
      final currentSpeed = speed * (isCasting ? castingSpeedMultiplier : 1.0);
      position += joystick.relativeDelta * currentSpeed * dt;
    }

    if (isCasting) {
      _castTimeRemaining -= dt;
      if (_castTimeRemaining <= 0) {
        _castTarget!.heal(singleHealAmount);
        _castTarget = null;
      }
    }

    _castBarFill.size = Vector2(size.x * castProgress, 4);
  }
}

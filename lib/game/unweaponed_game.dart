import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'hero_player.dart';

/// 支援職パーティーRPG「Unweaponed」のメインゲーム。
/// MVPステップ1: 左スティックによる主人公の移動のみを扱う。
class UnweaponedGame extends FlameGame {
  late final JoystickComponent joystick;
  late final HeroPlayer hero;

  @override
  Color backgroundColor() => const Color(0xFF7CB342); // 草原ステージの仮背景

  @override
  Future<void> onLoad() async {
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 20,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.8),
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.3),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    hero = HeroPlayer(joystick: joystick, position: Vector2.zero());

    world.add(hero);
    camera.viewport.add(joystick);
    camera.follow(hero);
  }
}

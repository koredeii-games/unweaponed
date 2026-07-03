import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'enemy_dummy.dart';
import 'ground_grid.dart';
import 'hero_player.dart';
import 'party_list_icon.dart';
import 'warrior.dart';

/// 支援職パーティーRPG「Unweaponed」のメインゲーム。
/// MVPステップ1: 左スティックによる主人公の移動。
/// MVPステップ2: 単体ヒール(対象指定→詠唱→発動)。
/// MVPステップ3: 戦士配置(前衛の自動戦闘)。
class UnweaponedGame extends FlameGame {
  late final JoystickComponent joystick;
  late final HeroPlayer hero;
  late final Warrior warrior;

  /// 敵スポーンステップ実装前の仮の敵一覧。戦士の自動戦闘AIが検知対象として参照する。
  final List<EnemyDummy> enemies = [];

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

    warrior = Warrior(
      name: '戦士',
      position: Vector2(60, 0),
      hero: hero,
      formationOffset: Vector2(60, 0),
      hp: 60, // ヒール効果を目視確認できるよう仮に減らしてある
      onTapped: (target) => hero.beginHealCast(target),
    );

    // 敵スポーンステップ実装前の仮の的。戦士の自動戦闘AIを検証するために配置。
    final dummy = EnemyDummy(position: Vector2(240, 0));
    enemies.add(dummy);

    world.addAll([GroundGrid(), warrior, hero, dummy]);
    camera.viewport.add(
      PartyListIcon(
        member: warrior,
        position: Vector2(16, 16),
        onSelect: (target) => hero.beginHealCast(target),
      ),
    );
    camera.viewport.add(joystick);
    camera.follow(hero);
  }
}

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'enemy.dart';
import 'enemy_spawner.dart';
import 'ground_grid.dart';
import 'hero_player.dart';
import 'party_list_icon.dart';
import 'warrior.dart';

/// 支援職パーティーRPG「Unweaponed」のメインゲーム。
/// MVPステップ1: 左スティックによる主人公の移動。
/// MVPステップ2: 単体ヒール(対象指定→詠唱→発動)。
/// MVPステップ3: 戦士配置(前衛の自動戦闘)。
/// MVPステップ4: 敵スポーン(固定配置+ランダムポップ)。
class UnweaponedGame extends FlameGame {
  late final JoystickComponent joystick;
  late final HeroPlayer hero;
  late final Warrior warrior;

  /// 敵配置スポナーが生成した敵一覧。戦士の自動戦闘AIが検知対象として参照する。
  final List<Enemy> enemies = [];

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

    // 配置座標はマップ生成(BSP)実装前の仮のもの。生成後は部屋の位置から決定する。
    final spawner = EnemySpawner(
      hero: hero,
      fixedSpawns: [
        FixedEnemySpawn(kind: EnemyKind.midBoss, position: Vector2(320, 0)),
        FixedEnemySpawn(kind: EnemyKind.boss, position: Vector2(640, 0)),
      ],
      zakoSpawnPositions: [
        Vector2(150, 150),
        Vector2(-150, 150),
        Vector2(150, -150),
        Vector2(450, 150),
      ],
    );

    world.addAll([GroundGrid(), warrior, hero, spawner]);
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

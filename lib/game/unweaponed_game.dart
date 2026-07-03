import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'dungeon/dungeon_generator.dart';
import 'dungeon/dungeon_map.dart';
import 'enemy.dart';
import 'enemy_spawner.dart';
import 'hero_player.dart';
import 'party_list_icon.dart';
import 'warrior.dart';

/// 支援職パーティーRPG「Unweaponed」のメインゲーム。
/// MVPステップ1: 左スティックによる主人公の移動。
/// MVPステップ2: 単体ヒール(対象指定→詠唱→発動)。
/// MVPステップ3: 戦士配置(前衛の自動戦闘)。
/// MVPステップ4: 敵スポーン(固定配置+ランダムポップ)。
/// MVPステップ5: マップ生成(BSP)。
class UnweaponedGame extends FlameGame {
  late final JoystickComponent joystick;
  late final HeroPlayer hero;
  late final Warrior warrior;

  /// 敵配置スポナーが生成した敵一覧。戦士の自動戦闘AIが検知対象として参照する。
  final List<Enemy> enemies = [];

  @override
  Color backgroundColor() => const Color(0xFF2E2A26); // 未探索領域(仮の地の色)

  @override
  Future<void> onLoad() async {
    final dungeon = generateDungeon();

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

    hero = HeroPlayer(
      joystick: joystick,
      position: dungeon.startRoom.center,
    );

    warrior = Warrior(
      name: '戦士',
      position: hero.position + Vector2(60, 0),
      hero: hero,
      formationOffset: Vector2(60, 0),
      hp: 60, // ヒール効果を目視確認できるよう仮に減らしてある
      onTapped: (target) => hero.beginHealCast(target),
    );

    final spawner = EnemySpawner(
      hero: hero,
      fixedSpawns: [
        FixedEnemySpawn(
          kind: EnemyKind.midBoss,
          position: dungeon.midBossRoom.center,
        ),
        FixedEnemySpawn(kind: EnemyKind.boss, position: dungeon.bossRoom.center),
      ],
      zakoSpawnPositions: dungeon.rooms
          .where((room) => room.type == RoomType.zako && room != dungeon.startRoom)
          .map((room) => room.center)
          .toList(),
    );

    world.addAll([DungeonMap(dungeon), warrior, hero, spawner]);
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

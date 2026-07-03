import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../economy/hireable_class.dart';
import 'archer.dart';
import 'dungeon/dungeon_generator.dart';
import 'dungeon/dungeon_map.dart';
import 'enemy.dart';
import 'enemy_spawner.dart';
import 'hero_player.dart';
import 'party_list_icon.dart';
import 'party_member.dart';
import 'warrior.dart';

/// 支援職パーティーRPG「Unweaponed」のメインゲーム。
/// MVPステップ1: 左スティックによる主人公の移動。
/// MVPステップ2: 単体ヒール(対象指定→詠唱→発動)。
/// MVPステップ3: 戦士配置(前衛の自動戦闘)。
/// MVPステップ4: 敵スポーン(固定配置+ランダムポップ)。
/// MVPステップ5: マップ生成(BSP)。
/// MVPステップ6: 酒場UI(雇用)。雇用済みの職業を[hiredParty]で受け取る。
class UnweaponedGame extends FlameGame {
  UnweaponedGame({required this.hiredParty});

  final Set<HireableClass> hiredParty;

  late final JoystickComponent joystick;
  late final HeroPlayer hero;

  /// 酒場で雇用したパーティーメンバー。
  final List<PartyMember> partyMembers = [];

  /// 敵配置スポナーが生成した敵一覧。戦士・弓使いの自動戦闘AIが検知対象として参照する。
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

    hero = HeroPlayer(joystick: joystick, position: dungeon.startRoom.center);

    if (hiredParty.contains(HireableClass.warrior)) {
      final formationOffset = Vector2(60, 0);
      partyMembers.add(
        Warrior(
          position: hero.position + formationOffset,
          hero: hero,
          formationOffset: formationOffset,
          hp: 60, // ヒール効果を目視確認できるよう仮に減らしてある
          onTapped: (target) => hero.beginHealCast(target),
        ),
      );
    }
    if (hiredParty.contains(HireableClass.archer)) {
      final formationOffset = Vector2(-60, 40);
      partyMembers.add(
        Archer(
          position: hero.position + formationOffset,
          hero: hero,
          formationOffset: formationOffset,
          hp: 40, // ヒール効果を目視確認できるよう仮に減らしてある
          onTapped: (target) => hero.beginHealCast(target),
        ),
      );
    }

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

    world.addAll([DungeonMap(dungeon), ...partyMembers, hero, spawner]);

    for (var i = 0; i < partyMembers.length; i++) {
      camera.viewport.add(
        PartyListIcon(
          member: partyMembers[i],
          position: Vector2(16, 16 + i * 44),
          onSelect: (target) => hero.beginHealCast(target),
        ),
      );
    }
    camera.viewport.add(joystick);
    camera.follow(hero);
  }
}

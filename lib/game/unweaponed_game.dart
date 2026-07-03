import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'hero_player.dart';
import 'party_list_icon.dart';
import 'party_member.dart';

/// 支援職パーティーRPG「Unweaponed」のメインゲーム。
/// MVPステップ1: 左スティックによる主人公の移動。
/// MVPステップ2: 単体ヒール(対象指定→詠唱→発動)。
class UnweaponedGame extends FlameGame {
  late final JoystickComponent joystick;
  late final HeroPlayer hero;
  late final PartyMember ally;

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

    // 前衛/後衛の区別や自動戦闘AIは「仲間配置」ステップで追加する仮の仲間。
    // hpは敵スポーン(戦闘)実装前のため、ヒール効果を目視確認できるよう仮に減らしてある。
    ally = PartyMember(
      name: 'ally-1',
      position: Vector2(100, 0),
      hp: 60,
      onTapped: (target) => hero.beginHealCast(target),
    );

    world.addAll([ally, hero]);
    camera.viewport.add(
      PartyListIcon(
        member: ally,
        position: Vector2(16, 16),
        onSelect: (target) => hero.beginHealCast(target),
      ),
    );
    camera.viewport.add(joystick);
    camera.follow(hero);
  }
}

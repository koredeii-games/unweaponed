import 'package:flame/components.dart';

import 'enemy.dart';
import 'hero_player.dart';
import 'party_member.dart';
import 'unweaponed_game.dart';

/// 前衛職(戦士)。敵が検知範囲内にいれば自動で接近して攻撃し、
/// いなければ主人公の近くの定位置(フォーメーション位置)へ戻る。
class Warrior extends PartyMember with HasGameReference<UnweaponedGame> {
  static const double moveSpeed = 140; // 要バランス調整
  static const double attackRange = 36; // 要バランス調整
  static const double detectionRange = 160; // 要バランス調整
  static const double attackDamage = 15; // 要バランス調整
  static const double attackCooldown = 1.0; // 秒、要バランス調整

  final HeroPlayer hero;
  final Vector2 formationOffset;

  Enemy? _combatTarget;
  double _attackTimer = 0;

  Warrior({
    required super.name,
    required super.position,
    required this.hero,
    required this.formationOffset,
    super.hp,
    super.onTapped,
  });

  @override
  void update(double dt) {
    super.update(dt);

    _combatTarget = _pickTarget();

    final target = _combatTarget;
    if (target != null) {
      final toTarget = target.position - position;
      if (toTarget.length > attackRange) {
        position += toTarget.normalized() * moveSpeed * dt;
      } else {
        _attackTimer -= dt;
        if (_attackTimer <= 0) {
          target.takeDamage(attackDamage);
          _attackTimer = attackCooldown;
        }
      }
      return;
    }

    _attackTimer = 0;
    final toFormation = (hero.position + formationOffset) - position;
    if (toFormation.length > 4) {
      position += toFormation.normalized() * moveSpeed * dt;
    }
  }

  /// 現在の対象が生存中かつ検知範囲内ならそれを継続し、
  /// そうでなければ検知範囲内の最も近い敵を探す。
  Enemy? _pickTarget() {
    final current = _combatTarget;
    if (current != null &&
        current.isAlive &&
        (current.position - position).length <= detectionRange) {
      return current;
    }

    Enemy? nearest;
    var nearestDistance = double.infinity;
    for (final enemy in game.enemies) {
      if (!enemy.isAlive) {
        continue;
      }
      final distance = (enemy.position - position).length;
      if (distance <= detectionRange && distance < nearestDistance) {
        nearest = enemy;
        nearestDistance = distance;
      }
    }
    return nearest;
  }
}

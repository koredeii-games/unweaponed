import 'package:flutter/material.dart';

import 'combat_party_member.dart';

/// 前衛職(戦士)。近距離まで接近して攻撃する。
class Warrior extends CombatPartyMember {
  Warrior({
    required super.position,
    required super.hero,
    required super.formationOffset,
    super.hp,
    super.onTapped,
  }) : super(
         name: '戦士',
         color: const Color(0xFF64B5F6),
         moveSpeed: 140, // 要バランス調整
         attackRange: 36, // 要バランス調整
         detectionRange: 160, // 要バランス調整
         attackDamage: 15, // 要バランス調整
         attackCooldown: 1.0, // 秒、要バランス調整
       );
}

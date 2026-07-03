import 'package:flutter/material.dart';

import 'combat_party_member.dart';

/// 後衛職(弓使い)。距離を取ったまま遠距離攻撃を行う。
class Archer extends CombatPartyMember {
  Archer({
    required super.position,
    required super.hero,
    required super.formationOffset,
    super.hp,
    super.onTapped,
  }) : super(
         name: '弓使い',
         color: const Color(0xFFAED581),
         moveSpeed: 120, // 要バランス調整
         attackRange: 220, // 要バランス調整(後衛らしく長射程)
         detectionRange: 260, // 要バランス調整
         attackDamage: 8, // 要バランス調整
         attackCooldown: 1.4, // 秒、要バランス調整
       );
}

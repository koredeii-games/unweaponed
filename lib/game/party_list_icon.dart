import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'party_member.dart';

/// 画面左上のパーティー一覧アイコン。タップすると対応するパーティーメンバーを
/// ヒール対象として選択する(画面上キャラ直接タップと同じ選択手段の一つ)。
class PartyListIcon extends PositionComponent with TapCallbacks {
  final PartyMember member;
  final void Function(PartyMember target) onSelect;

  PartyListIcon({
    required this.member,
    required this.onSelect,
    required super.position,
  }) : super(size: Vector2.all(36), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    add(CircleComponent(radius: size.x / 2, paint: Paint()..color = member.color));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onSelect(member);
  }
}

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// パーティーメンバー(仲間)。ヒール対象になれることと見た目(HPバー含む)を
/// 担う共通基底で、自動戦闘AIは[CombatPartyMember]が実装する。
class PartyMember extends PositionComponent with TapCallbacks {
  static const double maxHp = 100;

  final String name;
  final Color color;
  final void Function(PartyMember target)? onTapped;

  double hp;

  late final RectangleComponent _hpBarFill;

  PartyMember({
    required this.name,
    required super.position,
    this.color = const Color(0xFFE57373),
    this.hp = maxHp,
    this.onTapped,
  }) : super(size: Vector2.all(28), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleComponent(radius: size.x / 2, paint: Paint()..color = color));

    add(
      RectangleComponent(
        size: Vector2(size.x, 4),
        position: Vector2(0, -10),
        paint: Paint()..color = Colors.black54,
      ),
    );
    _hpBarFill = RectangleComponent(
      size: Vector2(size.x * (hp / maxHp), 4),
      position: Vector2(0, -10),
      paint: Paint()..color = const Color(0xFF66BB6A),
    );
    add(_hpBarFill);
  }

  void heal(double amount) {
    hp = (hp + amount).clamp(0, maxHp);
    _hpBarFill.size = Vector2(size.x * (hp / maxHp), 4);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapped?.call(this);
  }
}

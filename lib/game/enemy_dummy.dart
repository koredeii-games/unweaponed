import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 「敵スポーン」ステップ実装前に、戦士の自動戦闘を検証するための仮の的。
/// 固定配置・ランダムポップ等の本実装は敵スポーンステップで行う。
class EnemyDummy extends PositionComponent {
  static const double maxHp = 80;

  double hp;

  late final RectangleComponent _hpBarFill;

  EnemyDummy({required super.position, this.hp = maxHp})
    : super(size: Vector2.all(28), anchor: Anchor.center);

  bool get isAlive => hp > 0;

  @override
  Future<void> onLoad() async {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF616161),
      ),
    );

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
      paint: Paint()..color = const Color(0xFFEF5350),
    );
    add(_hpBarFill);
  }

  void takeDamage(double amount) {
    hp = (hp - amount).clamp(0, maxHp);
    _hpBarFill.size = Vector2(size.x * (hp / maxHp), 4);
    if (hp <= 0) {
      removeFromParent();
    }
  }
}

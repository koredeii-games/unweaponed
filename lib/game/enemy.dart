import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 敵の種別。中ボス・ボスは固定配置、雑魚はランダムポップで生成される。
enum EnemyKind { zako, midBoss, boss }

/// 敵の実体。固定配置・ランダムポップいずれのスポーン方式で生成された場合も
/// このクラスを使う。数値(HP・サイズ)は種別ごとの仮のバランス値で、要調整。
class Enemy extends PositionComponent {
  final EnemyKind kind;

  double hp;

  late final RectangleComponent _hpBarFill;

  Enemy({required this.kind, required super.position})
    : hp = _maxHpFor(kind),
      super(size: Vector2.all(_sizeFor(kind)), anchor: Anchor.center);

  double get maxHp => _maxHpFor(kind);

  bool get isAlive => hp > 0;

  static double _maxHpFor(EnemyKind kind) => switch (kind) {
    EnemyKind.zako => 30,
    EnemyKind.midBoss => 150,
    EnemyKind.boss => 400,
  };

  static double _sizeFor(EnemyKind kind) => switch (kind) {
    EnemyKind.zako => 24,
    EnemyKind.midBoss => 40,
    EnemyKind.boss => 56,
  };

  static Color _colorFor(EnemyKind kind) => switch (kind) {
    EnemyKind.zako => const Color(0xFF757575),
    EnemyKind.midBoss => const Color(0xFFFF8A65),
    EnemyKind.boss => const Color(0xFF6A1B9A),
  };

  @override
  Future<void> onLoad() async {
    add(
      RectangleComponent(size: size, paint: Paint()..color = _colorFor(kind)),
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

import 'package:flame/components.dart';

import 'enemy.dart';
import 'hero_player.dart';
import 'unweaponed_game.dart';

/// 固定配置の敵1体分の定義(中ボス・ボスなど、生成時に位置が決まっている敵)。
class FixedEnemySpawn {
  final EnemyKind kind;
  final Vector2 position;

  const FixedEnemySpawn({required this.kind, required this.position});
}

class _ZakoSpawnPoint {
  final Vector2 position;
  bool spawned = false;

  _ZakoSpawnPoint(this.position);
}

/// 敵配置を管理するスポナー。
/// - 固定配置: 中ボス・ボスをロード時に即座に生成する。
/// - ランダムポップ: 雑魚はプレイヤーが近づいたときに初めて生成する。
class EnemySpawner extends Component with HasGameReference<UnweaponedGame> {
  static const double popTriggerRadius = 180; // 要バランス調整

  final HeroPlayer hero;
  final List<FixedEnemySpawn> fixedSpawns;

  late final List<_ZakoSpawnPoint> _zakoPoints;

  EnemySpawner({
    required this.hero,
    required this.fixedSpawns,
    required List<Vector2> zakoSpawnPositions,
  }) : _zakoPoints = zakoSpawnPositions.map(_ZakoSpawnPoint.new).toList();

  @override
  Future<void> onLoad() async {
    for (final spawn in fixedSpawns) {
      _spawn(spawn.kind, spawn.position);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final point in _zakoPoints) {
      if (point.spawned) {
        continue;
      }
      if ((hero.position - point.position).length <= popTriggerRadius) {
        point.spawned = true;
        _spawn(EnemyKind.zako, point.position);
      }
    }
  }

  void _spawn(EnemyKind kind, Vector2 position) {
    final enemy = Enemy(kind: kind, position: position.clone());
    game.enemies.add(enemy);
    game.world.add(enemy);
  }
}

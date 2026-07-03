import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart' show Vector2;

/// 部屋タイプ。雑魚部屋/中ボス部屋/ボス部屋を隣接グラフの距離で割り当て、
/// スタート→(雑魚)→中ボス→(雑魚)→ボスという攻略の型を保証する。
enum RoomType { zako, midBoss, boss }

class Room {
  final Rect bounds;

  /// 狭い通路(避け場がなく緊張感重視)か、広い部屋(立ち回り重視)かの区別。
  final bool isNarrow;

  RoomType type;

  Room({required this.bounds, required this.isNarrow, this.type = RoomType.zako});

  Vector2 get center => Vector2(bounds.center.dx, bounds.center.dy);
}

class Corridor {
  final Room a;
  final Room b;

  const Corridor({required this.a, required this.b});
}

class DungeonLayout {
  final List<Room> rooms;
  final List<Corridor> corridors;
  final Room startRoom;
  final Room midBossRoom;
  final Room bossRoom;

  const DungeonLayout({
    required this.rooms,
    required this.corridors,
    required this.startRoom,
    required this.midBossRoom,
    required this.bossRoom,
  });
}

class _BspNode {
  final Rect bounds;
  _BspNode? left;
  _BspNode? right;
  Room? room;

  _BspNode(this.bounds);

  bool get isLeaf => left == null && right == null;
}

/// BSP法(二分空間分割)でダンジョンを自動生成する。
/// 部屋タイプはグラフ(隣接関係)の距離を使って決定し、攻略の型を保証する。
DungeonLayout generateDungeon({
  Rect bounds = const Rect.fromLTWH(0, 0, 1400, 1000),
  double minLeafSize = 180,
  int maxDepth = 4,
  double roomPadding = 16,
  double narrowRoomChance = 0.35,
  Random? random,
}) {
  final rng = random ?? Random();

  final root = _BspNode(bounds);
  _split(root, rng, minLeafSize: minLeafSize, depth: 0, maxDepth: maxDepth);

  final leaves = <_BspNode>[];
  _collectLeaves(root, leaves);
  for (final leaf in leaves) {
    _carveRoom(leaf, rng, padding: roomPadding, narrowChance: narrowRoomChance);
  }

  final corridors = <Corridor>[];
  _connect(root, corridors);

  final rooms = leaves.map((leaf) => leaf.room!).toList();
  final adjacency = <Room, List<Room>>{for (final r in rooms) r: []};
  for (final c in corridors) {
    adjacency[c.a]!.add(c.b);
    adjacency[c.b]!.add(c.a);
  }

  // スタート地点からのグラフ距離(BFS)で、最も遠い部屋をボス部屋、
  // その経路上の中間地点を中ボス部屋にする。木構造なので経路は一意。
  final start = rooms.first;
  final distances = <Room, int>{start: 0};
  final parent = <Room, Room?>{start: null};
  final queue = Queue<Room>()..add(start);
  while (queue.isNotEmpty) {
    final current = queue.removeFirst();
    for (final neighbor in adjacency[current]!) {
      if (!distances.containsKey(neighbor)) {
        distances[neighbor] = distances[current]! + 1;
        parent[neighbor] = current;
        queue.add(neighbor);
      }
    }
  }

  var boss = start;
  for (final r in rooms) {
    if (distances[r]! > distances[boss]!) {
      boss = r;
    }
  }

  final pathToBoss = <Room>[];
  Room? cursor = boss;
  while (cursor != null) {
    pathToBoss.add(cursor);
    cursor = parent[cursor];
  }

  var midBoss = boss;
  if (pathToBoss.length > 2) {
    midBoss = pathToBoss[pathToBoss.length ~/ 2];
  } else {
    final alternative = rooms.where((r) => r != start && r != boss).toList();
    if (alternative.isNotEmpty) {
      midBoss = alternative[rng.nextInt(alternative.length)];
    }
  }

  for (final r in rooms) {
    r.type = RoomType.zako;
  }
  midBoss.type = RoomType.midBoss;
  boss.type = RoomType.boss;

  return DungeonLayout(
    rooms: rooms,
    corridors: corridors,
    startRoom: start,
    midBossRoom: midBoss,
    bossRoom: boss,
  );
}

void _split(
  _BspNode node,
  Random rng, {
  required double minLeafSize,
  required int depth,
  required int maxDepth,
}) {
  if (depth >= maxDepth) {
    return;
  }

  final canSplitX = node.bounds.width > minLeafSize * 2;
  final canSplitY = node.bounds.height > minLeafSize * 2;
  if (!canSplitX && !canSplitY) {
    return;
  }

  final splitAlongX = canSplitX && canSplitY ? rng.nextBool() : canSplitX;

  if (splitAlongX) {
    final splitX =
        node.bounds.left +
        minLeafSize +
        rng.nextDouble() * (node.bounds.width - minLeafSize * 2);
    node.left = _BspNode(
      Rect.fromLTRB(node.bounds.left, node.bounds.top, splitX, node.bounds.bottom),
    );
    node.right = _BspNode(
      Rect.fromLTRB(splitX, node.bounds.top, node.bounds.right, node.bounds.bottom),
    );
  } else {
    final splitY =
        node.bounds.top +
        minLeafSize +
        rng.nextDouble() * (node.bounds.height - minLeafSize * 2);
    node.left = _BspNode(
      Rect.fromLTRB(node.bounds.left, node.bounds.top, node.bounds.right, splitY),
    );
    node.right = _BspNode(
      Rect.fromLTRB(node.bounds.left, splitY, node.bounds.right, node.bounds.bottom),
    );
  }

  _split(node.left!, rng, minLeafSize: minLeafSize, depth: depth + 1, maxDepth: maxDepth);
  _split(node.right!, rng, minLeafSize: minLeafSize, depth: depth + 1, maxDepth: maxDepth);
}

void _collectLeaves(_BspNode node, List<_BspNode> leaves) {
  if (node.isLeaf) {
    leaves.add(node);
  } else {
    _collectLeaves(node.left!, leaves);
    _collectLeaves(node.right!, leaves);
  }
}

/// 葉の領域の中に部屋を切り出す。一定確率で狭い通路(細長い形状)にし、
/// それ以外は広い部屋にすることで空間タイプのバリエーションを持たせる。
void _carveRoom(
  _BspNode leaf,
  Random rng, {
  required double padding,
  required double narrowChance,
}) {
  final maxW = leaf.bounds.width - padding * 2;
  final maxH = leaf.bounds.height - padding * 2;
  final isNarrow = rng.nextDouble() < narrowChance;

  double w;
  double h;
  if (isNarrow) {
    if (rng.nextBool()) {
      w = maxW;
      h = max(24, maxH * 0.28);
    } else {
      h = maxH;
      w = max(24, maxW * 0.28);
    }
  } else {
    w = maxW * (0.6 + rng.nextDouble() * 0.4);
    h = maxH * (0.6 + rng.nextDouble() * 0.4);
  }

  final x = leaf.bounds.left + padding + rng.nextDouble() * (maxW - w);
  final y = leaf.bounds.top + padding + rng.nextDouble() * (maxH - h);

  leaf.room = Room(bounds: Rect.fromLTWH(x, y, w, h), isNarrow: isNarrow);
}

/// BSP木を下から上へたどりながら、各内部ノードで左右の代表部屋を1本の通路で
/// つなぐ。内部ノード数だけ辺ができるため、部屋全体がちょうど木構造になり、
/// スタートからボスへの経路が一意に定まる(攻略の型の保証に使う)。
Room _connect(_BspNode node, List<Corridor> corridors) {
  if (node.isLeaf) {
    return node.room!;
  }
  final leftRoom = _connect(node.left!, corridors);
  final rightRoom = _connect(node.right!, corridors);
  corridors.add(Corridor(a: leftRoom, b: rightRoom));
  return leftRoom;
}

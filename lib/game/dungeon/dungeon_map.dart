import 'dart:ui';

import 'package:flame/components.dart';

import 'dungeon_generator.dart';

/// 生成されたダンジョン(部屋+通路)を描画するコンポーネント。
/// 部屋タイプごとに床色を変え、通路は別の色にすることで
/// 狭い通路/広い部屋や攻略ルートが見た目でも分かるようにする。
class DungeonMap extends PositionComponent {
  static const double corridorWidth = 40;

  final DungeonLayout layout;

  final Paint _corridorPaint = Paint()..color = const Color(0xFF689F38);

  DungeonMap(this.layout) : super(priority: -1);

  @override
  void render(Canvas canvas) {
    for (final corridor in layout.corridors) {
      for (final rect in _corridorRects(corridor)) {
        canvas.drawRect(rect, _corridorPaint);
      }
    }

    for (final room in layout.rooms) {
      canvas.drawRect(room.bounds, Paint()..color = _colorForRoom(room));
    }
  }

  List<Rect> _corridorRects(Corridor corridor) {
    final a = corridor.a.center;
    final b = corridor.b.center;
    const half = corridorWidth / 2;

    return [
      Rect.fromLTRB(
        (a.x < b.x ? a.x : b.x) - half,
        a.y - half,
        (a.x < b.x ? b.x : a.x) + half,
        a.y + half,
      ),
      Rect.fromLTRB(
        b.x - half,
        (a.y < b.y ? a.y : b.y) - half,
        b.x + half,
        (a.y < b.y ? b.y : a.y) + half,
      ),
    ];
  }

  Color _colorForRoom(Room room) => switch (room.type) {
    RoomType.zako => const Color(0xFF7CB342),
    RoomType.midBoss => const Color(0xFFFFB74D),
    RoomType.boss => const Color(0xFF9575CD),
  };
}

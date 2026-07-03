import 'dart:ui';

import 'package:flame/components.dart';

/// 移動を視覚的に把握しやすくするための仮の地面グリッド。
/// 本来のマップ生成(BSP)は「マップ生成」ステップで実装する。
class GroundGrid extends PositionComponent {
  static const double cellSize = 50;
  static const double gridExtent = 2000;

  final Paint _linePaint = Paint()
    ..color = const Color(0x33000000)
    ..strokeWidth = 1;

  GroundGrid()
    : super(
        position: Vector2.all(-gridExtent / 2),
        size: Vector2.all(gridExtent),
        priority: -1,
      );

  @override
  void render(Canvas canvas) {
    for (double x = 0; x <= size.x; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _linePaint);
    }
    for (double y = 0; y <= size.y; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _linePaint);
    }
  }
}

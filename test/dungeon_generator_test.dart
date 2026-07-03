import 'dart:collection';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:unweaponed/game/dungeon/dungeon_generator.dart';

void main() {
  group('generateDungeon', () {
    test('produces a fully connected tree of rooms with one entry, one '
        'mid-boss room, and one boss room', () {
      final layout = generateDungeon(random: Random(42));

      expect(layout.rooms, isNotEmpty);
      expect(layout.corridors.length, layout.rooms.length - 1);
      expect(layout.rooms, contains(layout.startRoom));
      expect(layout.rooms, contains(layout.midBossRoom));
      expect(layout.rooms, contains(layout.bossRoom));
      expect(layout.bossRoom.type, RoomType.boss);
      expect(layout.midBossRoom.type, RoomType.midBoss);

      final zakoCount = layout.rooms
          .where((room) => room.type == RoomType.zako)
          .length;
      final specialCount = layout.rooms.length - zakoCount;
      expect(specialCount, anyOf(1, 2)); // 中ボスとボスが同一部屋に縮退する稀なケースも許容

      // 全ての部屋がスタート部屋から通路づたいに到達可能であること
      // (BSP木から生成しているため、単一の連結グラフになっているはず)。
      final adjacency = <Room, List<Room>>{
        for (final room in layout.rooms) room: [],
      };
      for (final corridor in layout.corridors) {
        adjacency[corridor.a]!.add(corridor.b);
        adjacency[corridor.b]!.add(corridor.a);
      }

      final visited = <Room>{layout.startRoom};
      final queue = Queue<Room>()..add(layout.startRoom);
      while (queue.isNotEmpty) {
        final current = queue.removeFirst();
        for (final neighbor in adjacency[current]!) {
          if (visited.add(neighbor)) {
            queue.add(neighbor);
          }
        }
      }
      expect(visited.length, layout.rooms.length);
    });
  });
}

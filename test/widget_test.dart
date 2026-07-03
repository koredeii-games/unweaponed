import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unweaponed/game/unweaponed_game.dart';
import 'package:unweaponed/main.dart';

void main() {
  testWidgets('UnweaponedApp starts and mounts the game', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UnweaponedApp());
    await tester.pump();

    expect(find.byType(GameWidget<UnweaponedGame>), findsOneWidget);
  });
}

import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unweaponed/game/unweaponed_game.dart';
import 'package:unweaponed/main.dart';
import 'package:unweaponed/screens/tavern_screen.dart';

void main() {
  testWidgets('UnweaponedApp starts at the tavern and can enter the dungeon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UnweaponedApp());
    await tester.pump();

    expect(find.byType(TavernScreen), findsOneWidget);

    await tester.tap(find.text('ダンジョンへ'));
    await tester.pump();
    // Flameのゲームループは無限に描画し続けるため pumpAndSettle は使わず、
    // 画面遷移アニメーションの完了分だけ時間を進める。
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(GameWidget<UnweaponedGame>), findsOneWidget);
  });
}

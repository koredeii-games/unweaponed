import 'package:flutter_test/flutter_test.dart';
import 'package:unweaponed/economy/hireable_class.dart';
import 'package:unweaponed/economy/upkeep.dart';

void main() {
  group('collectUpkeep', () {
    test('deducts upkeep for every member the player can afford', () {
      final result = collectUpkeep(
        gold: 100,
        hiredParty: {HireableClass.warrior, HireableClass.archer},
      );

      expect(result.remainingParty, {HireableClass.warrior, HireableClass.archer});
      expect(result.departedParty, isEmpty);
      expect(
        result.remainingGold,
        100 - HireableClass.warrior.upkeepCost - HireableClass.archer.upkeepCost,
      );
    });

    test('a member leaves the party when upkeep cannot be paid', () {
      final result = collectUpkeep(
        gold: HireableClass.warrior.upkeepCost, // 戦士の分しか払えない所持金
        hiredParty: {HireableClass.warrior, HireableClass.archer},
      );

      expect(result.remainingParty, {HireableClass.warrior});
      expect(result.departedParty, {HireableClass.archer});
      expect(result.remainingGold, 0);
    });
  });
}

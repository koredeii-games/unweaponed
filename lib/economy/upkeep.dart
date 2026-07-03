import 'hireable_class.dart';

/// ステージ開始時の維持費徴収結果。
class UpkeepResult {
  final int remainingGold;
  final Set<HireableClass> remainingParty;

  /// 維持費が払えず脱退した職業。
  final Set<HireableClass> departedParty;

  const UpkeepResult({
    required this.remainingGold,
    required this.remainingParty,
    required this.departedParty,
  });
}

/// 維持費はステージ開始時に徴収し、不足しているメンバーは脱退する。
/// 徴収順は雇用済みメンバーの列挙順で、脱退したメンバーからは徴収しない。
UpkeepResult collectUpkeep({
  required int gold,
  required Set<HireableClass> hiredParty,
}) {
  var remainingGold = gold;
  final remainingParty = <HireableClass>{};
  final departedParty = <HireableClass>{};

  for (final member in hiredParty) {
    if (remainingGold >= member.upkeepCost) {
      remainingGold -= member.upkeepCost;
      remainingParty.add(member);
    } else {
      departedParty.add(member);
    }
  }

  return UpkeepResult(
    remainingGold: remainingGold,
    remainingParty: remainingParty,
    departedParty: departedParty,
  );
}

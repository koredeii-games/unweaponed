/// MVPで酒場から雇用できる職業。雇用費(雇用時に一度だけ)と維持費
/// (ステージ開始時に徴収。徴収処理自体は維持費システムステップで実装する)を持つ。
enum HireableClass {
  warrior(displayName: '戦士(前衛)', hireCost: 50, upkeepCost: 10),
  archer(displayName: '弓使い(後衛)', hireCost: 60, upkeepCost: 12);

  final String displayName;
  final int hireCost;
  final int upkeepCost;

  const HireableClass({
    required this.displayName,
    required this.hireCost,
    required this.upkeepCost,
  });
}

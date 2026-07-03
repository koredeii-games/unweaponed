import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../economy/hireable_class.dart';
import '../economy/upkeep.dart';
import '../game/unweaponed_game.dart';

/// 酒場UI。仲間を雇用してからダンジョンへ向かう。
class TavernScreen extends StatefulWidget {
  const TavernScreen({super.key});

  @override
  State<TavernScreen> createState() => _TavernScreenState();
}

class _TavernScreenState extends State<TavernScreen> {
  static const int startingGold = 200; // 要バランス調整

  int _gold = startingGold;
  final Set<HireableClass> _hired = {};

  void _hire(HireableClass hireable) {
    if (_hired.contains(hireable) || _gold < hireable.hireCost) {
      return;
    }
    setState(() {
      _gold -= hireable.hireCost;
      _hired.add(hireable);
    });
  }

  Future<void> _enterDungeon() async {
    // 維持費はステージ開始時に徴収し、不足しているメンバーは脱退する。
    final result = collectUpkeep(gold: _gold, hiredParty: _hired);
    setState(() {
      _gold = result.remainingGold;
      _hired
        ..clear()
        ..addAll(result.remainingParty);
    });

    if (result.departedParty.isNotEmpty) {
      final departedNames = result.departedParty
          .map((hireable) => hireable.displayName)
          .join('、');
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('維持費不足'),
          content: Text('維持費が払えず、以下のメンバーが脱退しました:\n$departedNames'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) {
        return;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: GameWidget.controlled(
            gameFactory: () => UnweaponedGame(hiredParty: Set.of(_hired)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('酒場')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('所持金: $_gold G', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: HireableClass.values
                    .map(
                      (hireable) => _HireableTile(
                        hireable: hireable,
                        hired: _hired.contains(hireable),
                        canAfford: _gold >= hireable.hireCost,
                        onHire: () => _hire(hireable),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _enterDungeon,
              child: const Text('ダンジョンへ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HireableTile extends StatelessWidget {
  final HireableClass hireable;
  final bool hired;
  final bool canAfford;
  final VoidCallback onHire;

  const _HireableTile({
    required this.hireable,
    required this.hired,
    required this.canAfford,
    required this.onHire,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(hireable.displayName),
        subtitle: Text(
          '雇用費: ${hireable.hireCost}G / 維持費: ${hireable.upkeepCost}G(ステージ開始時)',
        ),
        trailing: hired
            ? const Text('雇用済み')
            : ElevatedButton(
                onPressed: canAfford ? onHire : null,
                child: const Text('雇用'),
              ),
      ),
    );
  }
}

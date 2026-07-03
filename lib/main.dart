import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/unweaponed_game.dart';

void main() {
  runApp(const UnweaponedApp());
}

class UnweaponedApp extends StatelessWidget {
  const UnweaponedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unweaponed',
      home: Scaffold(
        body: GameWidget.controlled(gameFactory: UnweaponedGame.new),
      ),
    );
  }
}

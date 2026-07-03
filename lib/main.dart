import 'package:flutter/material.dart';

import 'screens/tavern_screen.dart';

void main() {
  runApp(const UnweaponedApp());
}

class UnweaponedApp extends StatelessWidget {
  const UnweaponedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Unweaponed', home: TavernScreen());
  }
}

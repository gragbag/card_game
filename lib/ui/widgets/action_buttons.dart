import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';

class ActionButtons extends StatelessWidget {
  final GameEngine engine;

  const ActionButtons({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => engine.confirmSelection('player1'),
            child: const Text("Confirm"),
          ),
          ElevatedButton(
            onPressed: () => engine.reset(),
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}

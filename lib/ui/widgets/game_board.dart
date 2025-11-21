import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';
import 'field_slots.dart';

class GameBoard extends StatelessWidget {
  final GameEngine engine;

  const GameBoard({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final player = engine.getPlayer('player1');
    final opponent = engine.getPlayer('player2');

    return Column(
      children: [
        // Opponent slots (view only)
        FieldSlots(player: opponent, engine: engine, isOpponent: true),

        const SizedBox(height: 20),

        // Your slots (interactive)
        FieldSlots(player: player, engine: engine),
      ],
    );
  }
}

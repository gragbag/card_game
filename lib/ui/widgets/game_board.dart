import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';
import 'field_slots.dart';

class GameBoard extends StatelessWidget {
  final GameEngine engine;
  final double scale;

  const GameBoard({super.key, required this.engine, required this.scale});

  @override
  Widget build(BuildContext context) {
    final player = engine.getPlayer('player1');
    final opponent = engine.getPlayer('player2');

    return Column(
      children: [
        // Opponent slots (view only)
        FieldSlots(
          player: opponent,
          engine: engine,
          isOpponent: true,
          scale: scale,
        ),

        SizedBox(height: 20 * scale),

        // Your slots (interactive)
        FieldSlots(player: player, engine: engine, scale: scale),
      ],
    );
  }
}

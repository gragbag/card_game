import 'package:flutter/material.dart';
import '../../game_logic/models/player_state.dart';
import '../../game_logic/game_engine.dart';
import 'field_slots.dart';

class PlayerArea extends StatelessWidget {
  final PlayerState player;
  final bool isOpponent;
  final GameEngine engine;

  const PlayerArea({
    super.key,
    required this.player,
    this.isOpponent = false,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          player.name,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _infoBox("Deck", player.deck.length),
            _infoBox("Hand", player.hand.length),
          ],
        ),
      ],
    );
  }

  Widget _infoBox(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          "$value",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}

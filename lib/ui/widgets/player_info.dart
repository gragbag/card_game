import 'package:flutter/material.dart';
import '../../game_logic/models/player_state.dart';

class PlayerInfo extends StatelessWidget {
  final PlayerState player;
  final bool isOpponent;

  const PlayerInfo({super.key, required this.player, this.isOpponent = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isOpponent
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            player.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('HP: ${player.health}/${player.maxHealth}'),
          Text(
            'Hand: ${player.hand.length} cards, Deck: ${player.deck.length}',
          ),
        ],
      ),
    );
  }
}

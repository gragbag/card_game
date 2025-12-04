import 'package:flutter/material.dart';
import '../../game_logic/models/player_state.dart';
import '../../game_logic/game_engine.dart';

class PlayerArea extends StatelessWidget {
  final PlayerState player;
  final bool isOpponent;
  final GameEngine engine;
  final double scale;

  const PlayerArea({
    super.key,
    required this.player,
    this.isOpponent = false,
    required this.engine,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    // Compute health percentage
    final healthPercent = (player.health / player.maxHealth).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Player name
        Text(
          player.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4 * scale),

        // Health bar container
        Stack(
          children: [
            // Background (empty bar)
            Container(
              width: 150 * scale,
              height: 16 * scale,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8 * scale),
                border: Border.all(color: Colors.white24),
              ),
            ),

            // Animated foreground bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 150 * scale * healthPercent,
              height: 16 * scale,
              decoration: BoxDecoration(
                color: healthPercent > 0.5
                    ? Colors.green
                    : (healthPercent > 0.25 ? Colors.orange : Colors.red),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
            ),

            // Optional health text
            Positioned.fill(
              child: Center(
                child: Text(
                  '${player.health} / ${player.maxHealth}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8 * scale),

        // Deck and hand info
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _infoBox("Deck", player.deck.length),
            SizedBox(width: 16 * scale),
            _infoBox("Hand", player.hand.length),
          ],
        ),
      ],
    );
  }

  Widget _infoBox(String label, int value, {String extra = ""}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          "$value$extra",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}

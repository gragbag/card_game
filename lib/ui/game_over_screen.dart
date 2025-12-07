import 'package:flutter/material.dart';
import '../game_logic/game_engine.dart';
import '../audio/audio_controller.dart';

class GameOverScreen extends StatelessWidget {
  final GameEngine engine;
  final AudioController audio;

  const GameOverScreen({
    super.key,
    required this.engine,
    required this.audio,
  });

  String _winnerText() {
    final state = engine.state;
    final p1 = state.player1;
    final p2 = state.player2;
    final result = state.lastRoundResult;

    final winner = result?.winner;

    if (winner == 'draw') {
      return "It's a draw!";
    } else if (winner == 'player1') {
      return '${p1.name} wins!';
    } else if (winner == 'player2') {
      return '${p2.name} wins!';
    }

    // Fallback – compute from health / isAlive
    final p1Alive = p1.isAlive;
    final p2Alive = p2.isAlive;

    if (!p1Alive && !p2Alive) return "It's a draw!";
    if (!p1Alive) return '${p2.name} wins!';
    if (!p2Alive) return '${p1.name} wins!';

    // If somehow both are alive, compare health
    if (p1.health > p2.health) return '${p1.name} wins!';
    if (p2.health > p1.health) return '${p2.name} wins!';

    return "It's a draw!";
  }

  @override
  Widget build(BuildContext context) {
    final state = engine.state;
    final p1 = state.player1;
    final p2 = state.player2;

    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final scale = (shortestSide / 500).clamp(0.7, 1.2);

    return Scaffold(
      backgroundColor: const Color(0xFF101018),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0 * scale),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Game Over',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42 * scale,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Text(
                  _winnerText(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.amberAccent,
                  ),
                ),
                SizedBox(height: 24 * scale),

                // Show final health of both players
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _playerHealthColumn(p1.name, p1.health, p1.maxHealth, scale),
                    _playerHealthColumn(p2.name, p2.health, p2.maxHealth, scale),
                  ],
                ),

                SizedBox(height: 32 * scale),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Start a fresh game. This calls GameEngine.initialize()
                      // inside reset(), which sets health back to max, etc.
                      engine.reset();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 14 * scale,
                      ),
                    ),
                    child: Text(
                      'Play Again',
                      style: TextStyle(fontSize: 18 * scale),
                    ),
                  ),
                ),
                SizedBox(height: 12 * scale),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Back to main menu
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 12 * scale,
                      ),
                    ),
                    child: Text(
                      'Main Menu',
                      style: TextStyle(fontSize: 16 * scale),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _playerHealthColumn(
      String name,
      int health,
      int maxHealth,
      double scale,
      ) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          '$health / $maxHealth HP',
          style: TextStyle(
            fontSize: 14 * scale,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}

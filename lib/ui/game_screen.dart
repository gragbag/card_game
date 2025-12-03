import 'package:card_game/audio/audio_controller.dart';
import 'package:flutter/material.dart';
import '../game_logic/game_engine.dart';
import 'widgets/player_area.dart';
import 'widgets/hand_view.dart';
import 'widgets/game_board.dart';
import 'widgets/action_buttons.dart';

class GameScreen extends StatefulWidget {
  final GameEngine engine;
  final AudioController audio;

  const GameScreen({super.key, required this.engine, required this.audio});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;

    final player = engine.getPlayer('player1');
    final opponent = engine.getPlayer('player2');

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            /// Opponent area (top)
            PlayerArea(player: opponent, isOpponent: true, engine: engine),

            const SizedBox(height: 10),

            /// Central board (SLOTS)
            GameBoard(engine: engine),

            const SizedBox(height: 10),

            /// Player area (below slots)
            PlayerArea(player: player, engine: engine),

            /// Player hand (BOTTOM)
            HandView(player: player, engine: engine),

            /// CONFIRM + RESET
            ActionButtons(engine: engine, audio: widget.audio),
          ],
        ),
      ),
    );
  }
}

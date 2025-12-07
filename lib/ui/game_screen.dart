import 'package:card_game/audio/audio_controller.dart';
import 'package:flutter/material.dart';
import '../game_logic/game_engine.dart';
import 'widgets/player_area.dart';
import 'widgets/hand_view.dart';
import 'widgets/game_board.dart';
import 'widgets/action_buttons.dart';
import '../game_logic/enums/game_phase.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final GameEngine engine;
  final AudioController audio;

  const GameScreen({super.key, required this.engine, required this.audio});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    widget.engine.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.engine.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    // Scale relative to phone vs desktop
    final scale = (shortestSide / 500).clamp(
      0.6,
      1.1,
    ); // Tune denominator until it looks good

    final engine = widget.engine;

    // if the game is over, show the GameOverScreen instead of the board
    if (engine.state.currentPhase == GamePhase.gameOver) {
      return GameOverScreen(
        engine: engine,
        audio: widget.audio,
      );
    }

    final player = engine.getPlayer('player1');
    final opponent = engine.getPlayer('player2');

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 36 * scale),
          child: Column(
            children: [
              PlayerArea(
                player: opponent,
                isOpponent: true,
                engine: engine,
                scale: scale,
              ),
              SizedBox(height: 10 * scale),

              GameBoard(engine: engine, scale: scale),
              SizedBox(height: 10 * scale),

              PlayerArea(player: player, engine: engine, scale: scale),
              HandView(player: player, engine: engine, scale: scale),
              ActionButtons(engine: engine, audio: widget.audio, scale: scale),
            ],
          ),
        ),
      ),
    );
  }
}

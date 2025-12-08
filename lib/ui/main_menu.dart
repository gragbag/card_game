import 'package:flutter/material.dart';
import '../game_logic/game_engine.dart';
import '../audio/audio_controller.dart';
import 'game_screen.dart';
import 'multiplayer_lobby_screen.dart';

enum GameMode { singlePlayer, multiplayer }

class MainMenu extends StatefulWidget {
  final GameEngine engine;
  final AudioController audio;

  const MainMenu({super.key, required this.engine, required this.audio});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _playerNameController = TextEditingController(
    text: 'Player',
  );

  GameMode _mode = GameMode.singlePlayer;

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  void _startGame() {
    final playerName = _playerNameController.text.trim().isEmpty
        ? 'Player'
        : _playerNameController.text.trim();

    // opponent name will auto to CPU if singleplayer is selected
    final opponentName = _mode == GameMode.singlePlayer ? 'CPU' : 'Player 2';

    // Initialize the engine with chosen names
    widget.engine.initialize(
      player1Name: playerName,
      player2Name: opponentName,
      vsCpuOverride: false,
    );

    if (_mode == GameMode.singlePlayer) {
      // Local game
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              GameScreen(engine: widget.engine, audio: widget.audio),
        ),
      );
    } else {
      // Multiplayer → go to lobby / room UI instead of straight to game
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MultiplayerLobbyScreen(
            engine: widget.engine,
            audio: widget.audio,
            playerName: playerName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Card Battle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40 * scale,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 24 * scale),

                // Mode selector
                Text(
                  'Select mode',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 8 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Single Player Button
                    ChoiceChip(
                      label: const Text('Single Player'),
                      selected: _mode == GameMode.singlePlayer,
                      onSelected: (_) {
                        setState(() {
                          _mode = GameMode.singlePlayer;
                        });
                      },
                    ),

                    SizedBox(width: 12 * scale),

                    // Multiplayer button
                    ChoiceChip(
                      label: const Text('Multiplayer'),
                      selected: _mode == GameMode.multiplayer,
                      onSelected: (_) {
                        setState(() {
                          _mode = GameMode.multiplayer;
                        });
                      },
                    ),
                  ],
                ),

                SizedBox(height: 24 * scale),

                // Player name input
                Text(
                  // _mode == GameMode.singlePlayer
                  'Enter your name',
                  // : 'Enter Player 1 name',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 12 * scale),
                TextField(
                  controller: _playerNameController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 24 * scale),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14 * scale),
                    ),
                    child: Text(
                      'Start Game',
                      style: TextStyle(fontSize: 18 * scale),
                    ),
                  ),
                ),
                SizedBox(height: 12 * scale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

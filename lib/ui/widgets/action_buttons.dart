import 'package:card_game/game_logic/services/combat_resolver.dart';
import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';
import 'package:card_game/audio/audio_controller.dart';
import 'package:card_game/game_logic/enums/game_phase.dart';

class ActionButtons extends StatelessWidget {
  final GameEngine engine;
  final AudioController audio;
  final double scale;

  final String localPlayerId;

  const ActionButtons({
    super.key,
    required this.engine,
    required this.audio,
    required this.scale,
    this.localPlayerId = 'player1', // default for offline/singleplayer
  });

  @override
  Widget build(BuildContext context) {
    final isMyTurn =
        engine.state.currentPhase == GamePhase.select &&
        engine.state.currentPlacerId == localPlayerId;

    return Padding(
      padding: EdgeInsets.all(8 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 120 * scale,
            height: 45 * scale,
            child: ElevatedButton(
              onPressed: isMyTurn
                  ? () {
                      engine.confirmSelection(localPlayerId);
                      audio.playSound('assets/sounds/confirm_button.mp3');
                    }
                  : null, // disabled when it's not this player's placement turn
              child: Text("Confirm", style: TextStyle(fontSize: 16 * scale)),
            ),
          ),

          SizedBox(
            width: 120 * scale,
            height: 45 * scale,
            child: ElevatedButton(
              onPressed: () {
                engine.reset();
                audio.playSound('assets/sounds/reset_card.mp3');
              },
              child: Text("Reset", style: TextStyle(fontSize: 16 * scale)),
            ),
          ),
        ],
      ),
    );
  }
}

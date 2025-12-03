import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';
import 'package:card_game/audio/audio_controller.dart';

class ActionButtons extends StatelessWidget {
  final GameEngine engine;
  final AudioController audio;

  const ActionButtons({super.key, required this.engine, required this.audio});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () { engine.confirmSelection('player1');
            audio.playSound('assets/sounds/confirm_button.mp3');},
            child: const Text("Confirm"),
          ),
          ElevatedButton(
            onPressed: () { engine.reset();
            audio.playSound('assets/sounds/reset_card.mp3');},
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';

import 'game_logic/game_engine.dart';
import 'game_logic/models/game_state.dart';
import 'game_logic/models/player_state.dart';
import 'game_logic/models/card.dart';
import 'game_logic/enums/game_phase.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'ui/game_screen.dart';
import 'audio/audio_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Create & initialize audio controller
  final audioController = AudioController();
  try { // Web version does not support soloud, so try catch to prevent crashing
    await audioController.initialize();
  } catch (e) {
    debugPrint("Audio initialize failed, continuing without sound. $e");
  }


  //Create game engine
  final engine = GameEngine();
  engine.initialize(player1Name: 'Alice', player2Name: 'Bob');

  runApp(CardBattleApp(
    engine: engine,
    audio: audioController,
  ));
}

class CardBattleApp extends StatelessWidget {
  final GameEngine engine;
  final AudioController audio;

  const CardBattleApp({super.key, required this.engine, required this.audio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Card Battle Game',
      theme: ThemeData.dark(),
      home: GameScreen(engine: engine, audio: audio),
    );
  }
}

// void main() {
//   print('=== CARD BATTLE GAME - LOGIC TEST ===\n');

//   // Initialize game
//   final game = GameEngine();
//   game.initialize(player1Name: 'Alice', player2Name: 'Bob');

//   print('Game initialized!');
//   print(game.getState());
//   print('');

//   // Display initial hands
//   _displayPlayerInfo(game.state.player1);
//   _displayPlayerInfo(game.state.player2);
//   print('');

//   // Simulate multiple rounds
//   int roundCount = 0;
//   while (!game.state.isGameOver && roundCount < 10) {
//     roundCount++;
//     print('=== ROUND $roundCount ===');
//     print('Phase: ${game.state.currentPhase.name}\n');

//     // Player 1 turn
//     print('--- Player 1 (Alice) selecting cards ---');
//     PlayerState p1 = game.state.player1;

//     // Check if player has cards
//     if (p1.hand.isEmpty) {
//       print('Player 1 has no cards in hand!');
//       break;
//     }

//     // Auto-select up to 3 cards
//     int cardsToSelect = p1.hand.length >= 3 ? 3 : p1.hand.length;
//     for (int i = 0; i < cardsToSelect; i++) {
//       if (i < p1.hand.length) {
//         Card card = p1.hand[i];
//         bool success = game.selectCard('player1', card.id);
//         print('Selected: $card - ${success ? "✓" : "✗"}');
//       }
//     }

//     print(
//       'Player 1 selected cards: ${p1.selectedCards.map((c) => c.name).join(", ")}',
//     );
//     bool confirmed = game.confirmSelection('player1');
//     print('Confirmation: ${confirmed ? "✓" : "✗"}\n');

//     // Player 2 turn
//     print('--- Player 2 (Bob) selecting cards ---');
//     PlayerState p2 = game.state.player2;

//     // Check if player has cards
//     if (p2.hand.isEmpty) {
//       print('Player 2 has no cards in hand!');
//       break;
//     }

//     // Auto-select up to 2 cards (different strategy)
//     cardsToSelect = p2.hand.length >= 2 ? 2 : p2.hand.length;
//     for (int i = 0; i < cardsToSelect; i++) {
//       if (i < p2.hand.length) {
//         Card card = p2.hand[i];
//         bool success = game.selectCard('player2', card.id);
//         print('Selected: $card - ${success ? "✓" : "✗"}');
//       }
//     }

//     print(
//       'Player 2 selected cards: ${p2.selectedCards.map((c) => c.name).join(", ")}',
//     );
//     confirmed = game.confirmSelection('player2');
//     print('Confirmation: ${confirmed ? "✓" : "✗"}\n');

//     // Display round results
//     if (game.state.lastRoundResult != null) {
//       print('--- ROUND RESULT ---');
//       print(game.state.lastRoundResult);
//       print('');

//       _displayPlayerInfo(game.state.player1);
//       _displayPlayerInfo(game.state.player2);
//       print('');
//     }

//     // Check if game over
//     if (game.state.isGameOver) {
//       print('=== GAME OVER ===');
//       print('Winner: ${game.state.winner?.toUpperCase() ?? "NONE"}');
//       print('Final Scores:');
//       print('  Alice: ${game.state.player1.health} HP');
//       print('  Bob: ${game.state.player2.health} HP');
//       break;
//     }

//     print('---\n');
//   }

//   if (!game.state.isGameOver) {
//     print('Game stopped after $roundCount rounds (demo limit)');
//   }
// }

// void _displayPlayerInfo(PlayerState player) {
//   print('${player.name}:');
//   print('  HP: ${player.health}/${player.maxHealth}');
//   print('  Hand: ${player.hand.length} cards');
//   print('  Deck: ${player.deck.length} cards');
//   print('  Discard: ${player.discardPile.length} cards');
//   if (player.hand.isNotEmpty) {
//     print(
//       '  Cards in hand: ${player.hand.map((c) => '${c.name}(${c.value})').join(", ")}',
//     );
//   }
// }

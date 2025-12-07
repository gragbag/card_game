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
import 'ui/main_menu.dart';

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
  //main menu will initialize game engine instead
  // engine.initialize(player1Name: 'Alice', player2Name: 'Bob');

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
      home: MainMenu(engine: engine, audio: audio),
    );
  }
}
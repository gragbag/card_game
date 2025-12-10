//import 'package:video_player/video_player.dart';

import 'game_logic/game_engine.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'audio/audio_controller.dart';
import 'ui/main_menu.dart';
//import 'ui/intro_video.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2) (Optional but nice) do a global anonymous sign-in
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    debugPrint('Anonymous sign-in failed: $e');
  }

  //Create & initialize audio controller
  final audioController = AudioController();
  try {
    // Web version does not support soloud, so try catch to prevent crashing
    await audioController.initialize();
  } catch (e) {
    debugPrint("Audio initialize failed, continuing without sound. $e");
  }

  //Create game engine
  final engine = GameEngine();

  runApp(CardBattleApp(engine: engine, audio: audioController));
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
      home: MainMenu(engine: engine, audio: audio)
    );
  }

}


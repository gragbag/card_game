import 'dart:async';

import 'package:card_game/audio/audio_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../game_logic/game_engine.dart';
import '../game_logic/multiplayer/online_game_room.dart';
import 'widgets/player_area.dart';
import 'widgets/hand_view.dart';
import 'widgets/game_board.dart';
import 'widgets/action_buttons.dart';
import '../game_logic/enums/game_phase.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final GameEngine engine;
  final AudioController audio;

  /// If not null, this game is an online game synced to this room.
  final String? roomId;

  /// Optional logical player id for this device: 'player1' or 'player2'
  final String? localPlayerId;

  const GameScreen({
    super.key,
    required this.engine,
    required this.audio,
    this.roomId,
    this.localPlayerId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameEngine engine;

  StreamSubscription<DocumentSnapshot>? _roomSub;
  bool _applyingRemoteUpdate = false;

  bool get _isOnline => widget.roomId != null;

  @override
  void initState() {
    super.initState();
    widget.engine.addListener(_refresh);

    engine = widget.engine;

    if (_isOnline) {
      _setupOnlineSync();
    }

    // Start music after first frame so SoLoud is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Only play if not muted
      if (!widget.audio.isMuted) {
        await widget.audio.startMusic();
      }
    });

  }

  void _setupOnlineSync() {
    final roomId = widget.roomId!;
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);

    // 1) Listen for remote updates and apply them to the engine
    _roomSub = roomRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) return;

      final room = OnlineGameRoom.fromSnapshot(snapshot);

      // Avoid triggering write → read → write loops
      _applyingRemoteUpdate = true;
      engine.loadFromState(room.gameState);
      _applyingRemoteUpdate = false;
    });

    // 2) Whenever the engine changes locally, push the new state to Firestore
    engine.addListener(_onEngineChanged);
  }

  void _onEngineChanged() {
    if (!_isOnline || _applyingRemoteUpdate) return;

    final roomId = widget.roomId!;
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);

    roomRef.update({
      'gameState': engine.state.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      // you could also update 'status' or 'currentPlayerId' here later
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _roomSub?.cancel();
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
      return GameOverScreen(engine: engine, audio: widget.audio);
    }

    final localPlayerId = widget.localPlayerId ?? 'player1';
    final player = engine.getPlayer(localPlayerId);
    final opponent = engine.getPlayer(
      localPlayerId == 'player1' ? 'player2' : 'player1',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [

            /// MAIN GAME UI
            Padding(
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

                  GameBoard(
                    engine: engine,
                    scale: scale,
                    localPlayerId: localPlayerId,
                  ),
                  SizedBox(height: 10 * scale),

                  PlayerArea(
                    player: player,
                    engine: engine,
                    scale: scale,
                  ),
                  HandView(
                    player: player,
                    engine: engine,
                    scale: scale,
                  ),
                  ActionButtons(
                    engine: engine,
                    audio: widget.audio,
                    scale: scale,
                    localPlayerId: localPlayerId,
                  ),
                ],
              ),
            ),

            //Mute Button
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: Icon(
                  widget.audio.isMuted ? Icons.volume_off : Icons.volume_up,
                  size: 28,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await widget.audio.toggleMute();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
}

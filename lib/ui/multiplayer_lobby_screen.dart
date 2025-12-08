import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../game_logic/game_engine.dart';
import '../audio/audio_controller.dart';
import '../game_logic/models/game_state.dart';
import '../game_logic/multiplayer/online_game_room.dart';
import 'game_screen.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  final GameEngine engine;
  final AudioController audio;
  final String playerName;

  const MultiplayerLobbyScreen({
    super.key,
    required this.engine,
    required this.audio,
    required this.playerName,
  });

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final TextEditingController _roomIdController = TextEditingController();
  String? _currentRoomId;
  bool _isHost = false;
  bool _hasEnteredGame = false;

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  Future<void> _ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  String _generateRoomCode({int length = 6}) {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0,1,I,O to avoid confusion
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  Future<void> _createRoom() async {
    await _ensureSignedIn();
    final user = FirebaseAuth.instance.currentUser!;
    final rooms = FirebaseFirestore.instance.collection('rooms');

    widget.engine.initialize(
      player1Name: widget.playerName,
      player2Name: 'Waiting...',
      vsCpuOverride: false,
    );

    final gameState = widget.engine.state;

    final roomCode = _generateRoomCode();

    final docRef = rooms.doc(roomCode);

    await docRef.set({
      'hostId': user.uid,
      'guestId': null,
      'status': 'waiting',
      'currentPlayerId': user.uid,
      'gameState': gameState.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _currentRoomId = roomCode;
      _isHost = true;
    });
  }

  Future<void> _joinRoom() async {
    await _ensureSignedIn();
    final user = FirebaseAuth.instance.currentUser!;
    final roomId = _roomIdController.text.trim().toUpperCase();
    if (roomId.isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // show error
      return;
    }

    final data = doc.data()!;
    final gameStateJson = data['gameState'] as Map<String, dynamic>;
    final gameState = GameState.fromJson(gameStateJson);

    gameState.player2.name = widget.playerName;
    if (data['guestId'] != null) {
      // room already full
      return;
    }

    await docRef.update({
      'guestId': user.uid,
      'status': 'in_progress',
      'gameState': gameState.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      // you might also want to update gameState here
    });

    setState(() {
      _currentRoomId = roomId;
      _isHost = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRoomId == null) {
      // Lobby entry UI
      return Scaffold(
        appBar: AppBar(title: const Text('Multiplayer Lobby')),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Multiplayer Lobby',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${widget.playerName}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 32),

                  // CREATE ROOM BUTTON
                  SizedBox(
                    width: 240,
                    child: ElevatedButton(
                      onPressed: _createRoom,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Create Room'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Or join a friend\'s room:',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _roomIdController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        labelText: 'Room ID',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // JOIN BUTTON
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: _joinRoom,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Join Room'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Once you have a room id, listen to it and go to the game when ready
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rooms')
          .doc(_currentRoomId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roomDoc = snapshot.data!;
        final onlineRoom = OnlineGameRoom.fromSnapshot(roomDoc);

        // Example condition: when both players are connected, push into GameScreen
        final bothPlayersConnected =
            onlineRoom.hostId.isNotEmpty && onlineRoom.guestId != null;

        if (bothPlayersConnected &&
            onlineRoom.status == 'in_progress' &&
            !_hasEnteredGame) {
          _hasEnteredGame = true;
          widget.engine.loadFromState(onlineRoom.gameState);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameScreen(
                  engine: widget.engine,
                  audio: widget.audio,
                  roomId: onlineRoom.id,
                  localPlayerId: _isHost ? 'player1' : 'player2',
                ),
              ),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Waiting Room')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share this Room ID with your friend:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),

                // 🔹 Room ID display with copy button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SelectableText(
                        _currentRoomId ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy Room ID',
                        onPressed: () {
                          final id = _currentRoomId ?? '';
                          if (id.isEmpty) return;
                          Clipboard.setData(ClipboardData(text: id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Room ID copied to clipboard'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  _isHost
                      ? 'Waiting for another player to join...'
                      : 'Joining room...',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  'Status: ${onlineRoom.status}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

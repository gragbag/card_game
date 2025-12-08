import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_state.dart';

class OnlineGameRoom {
  final String id;
  final String hostId;
  final String? guestId;
  final GameState gameState;
  final String status; // waiting, in_progress, finished
  final String currentPlayerId;

  OnlineGameRoom({
    required this.id,
    required this.hostId,
    this.guestId,
    required this.gameState,
    required this.status,
    required this.currentPlayerId,
  });

  Map<String, dynamic> toJson() => {
    'hostId': hostId,
    'guestId': guestId,
    'gameState': gameState.toJson(),
    'status': status,
    'currentPlayerId': currentPlayerId,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory OnlineGameRoom.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OnlineGameRoom(
      id: doc.id,
      hostId: data['hostId'],
      guestId: data['guestId'],
      gameState: GameState.fromJson(data['gameState']),
      status: data['status'],
      currentPlayerId: data['currentPlayerId'],
    );
  }
}

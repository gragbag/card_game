import '../enums/game_phase.dart';
import 'player_state.dart';
import 'round_result.dart';

class GameState {
  final PlayerState player1;
  final PlayerState player2;
  GamePhase currentPhase;
  int currentTurn;
  RoundResult? lastRoundResult;
  bool player1Ready;
  bool player2Ready;

  String firstPlacerId;
  String currentPlacerId;

  GameState({
    required this.player1,
    required this.player2,
    this.currentPhase = GamePhase.draw,
    this.currentTurn = 1,
    this.lastRoundResult,
    this.player1Ready = false,
    this.player2Ready = false,
    this.firstPlacerId = 'player1',
    this.currentPlacerId = 'player1',
  });

  bool get isGameOver => !player1.isAlive || !player2.isAlive;
  bool get bothPlayersReady => player1Ready && player2Ready;

  String? get winner {
    if (!isGameOver) return null;
    if (!player1.isAlive && !player2.isAlive) return 'draw';
    if (!player1.isAlive) return 'player2';
    return 'player1';
  }

  Map<String, dynamic> toJson() {
    return {
      'player1': player1.toJson(),
      'player2': player2.toJson(),
      'currentPhase': currentPhase.name,
      'currentTurn': currentTurn,
      'player1Ready': player1Ready,
      'player2Ready': player2Ready,
      'lastRoundResult': lastRoundResult?.toJson(),
      'firstPlacerId': firstPlacerId,
      'currentPlacerId': currentPlacerId,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      player1: PlayerState.fromJson(json['player1']),
      player2: PlayerState.fromJson(json['player2']),
      currentPhase: GamePhase.values.firstWhere(
        (e) => e.name == json['currentPhase'],
      ),
      currentTurn: json['currentTurn'],
      player1Ready: json['player1Ready'] ?? false,
      player2Ready: json['player2Ready'] ?? false,
      lastRoundResult: json['lastRoundResult'] != null
          ? RoundResult.fromJson(json['lastRoundResult'])
          : null,
      firstPlacerId: json['firstPlacerId'] ?? 'player1',
      currentPlacerId: json['currentPlacerId'] ?? 'player1',
    );
  }
}

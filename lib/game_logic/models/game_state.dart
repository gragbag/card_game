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

  GameState({
    required this.player1,
    required this.player2,
    this.currentPhase = GamePhase.draw,
    this.currentTurn = 1,
    this.lastRoundResult,
    this.player1Ready = false,
    this.player2Ready = false,
  });

  bool get isGameOver => !player1.isAlive || !player2.isAlive;
  bool get bothPlayersReady => player1Ready && player2Ready;

  String? get winner {
    if (!isGameOver) return null;
    if (!player1.isAlive && !player2.isAlive) return 'draw';
    if (!player1.isAlive) return 'player2';
    return 'player1';
  }

  Map<String, dynamic> toJson() => {
    'player1': player1.toJson(),
    'player2': player2.toJson(),
    'currentPhase': currentPhase.name,
    'currentTurn': currentTurn,
    'lastRoundResult': lastRoundResult?.toJson(),
    'player1Ready': player1Ready,
    'player2Ready': player2Ready,
  };

  @override
  String toString() {
    return 'GameState(Turn: $currentTurn, Phase: $currentPhase, P1: ${player1.health}HP, P2: ${player2.health}HP)';
  }
}

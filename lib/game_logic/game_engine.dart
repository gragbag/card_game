import 'package:card_game/game_logic/enums/lane_column.dart' show Lane;
import 'package:flutter/foundation.dart';
import 'dart:math';

import 'models/game_state.dart';
import 'models/player_state.dart';
import 'models/card.dart';
import 'models/round_result.dart';
import 'enums/game_phase.dart';
import 'enums/lane_column.dart';
import 'services/deck_builder.dart';
import 'services/card_manager.dart';
import 'services/combat_resolver.dart';

/// Main game engine - manages all game logic
class GameEngine extends ChangeNotifier {
  late GameState state;

  /// Initialize a new game
  void initialize({
    String player1Name = 'Player 1',
    String player2Name = 'Player 2',
  }) {
    // Create and shuffle deck
    List<Card> fullDeck = DeckBuilder.createStandardDeck();
    fullDeck.shuffle();

    // Split deck between players
    var decks = DeckBuilder.splitDeck(fullDeck);

    // Create player states
    final player1 = PlayerState(
      id: 'player1',
      name: player1Name,
      deck: decks[0],
    );

    final player2 = PlayerState(
      id: 'player2',
      name: player2Name,
      deck: decks[1],
    );

    // Initialize game state
    state = GameState(player1: player1, player2: player2);

    // Start first turn
    startGame();
    notifyListeners();
  }

  void startGame() {
    state.currentPhase = GamePhase.draw;
    CardManager.drawHand(state.player1);
    CardManager.drawHand(state.player2);
    state.currentPhase = GamePhase.select;
    state.player1Ready = false;
    state.player2Ready = false;

    notifyListeners();
  }

  /// Start a new turn (Draw Phase)
  void startTurn() {
    state.currentPhase = GamePhase.draw;
    CardManager.drawCards(state.player1);
    CardManager.drawCards(state.player2);
    state.currentPhase = GamePhase.select;
    state.player1Ready = false;
    state.player2Ready = false;

    notifyListeners();
  }

  void moveCardToLane(String playerId, Card card, Lane lane) {
    final player = getPlayer(playerId);
    CardManager.playCardToLane(player, card.id, lane);
    notifyListeners();
  }

  bool removeCardFromLane(String playerId, Lane lane) {
    if (state.currentPhase != GamePhase.select) return false;

    final player = playerId == 'player1' ? state.player1 : state.player2;
    final ok = CardManager.removeCardFromLane(player, lane);
    if (ok) notifyListeners();
    return ok;
  }

  void moveCardToHand(String playerId, Card card) {
    if (state.currentPhase != GamePhase.select) return;

    final player = getPlayer(playerId);

    // Find which lane this card is in
    Lane? sourceLane;
    for (final lane in Lane.values) {
      final laneCard = player.field.cardInLane(lane);
      if (laneCard?.id == card.id) {
        sourceLane = lane;
        break;
      }
    }

    if (sourceLane != null) {
      CardManager.removeCardFromLane(player, sourceLane);
      notifyListeners();
    }
  }

  /// Player confirms their selection
  bool confirmSelection(String playerId) {
    if (state.currentPhase != GamePhase.select) return false;

    PlayerState player = playerId == 'player1' ? state.player1 : state.player2;

    // if (player.selectedCards.isEmpty) return false;

    if (playerId == 'player1') {
      state.player1Ready = true;
    } else {
      state.player2Ready = true;
    }

    // Trigger NPC turn automatically
    if (!state.player2Ready) {
      _playNpcTurn();
    }

    notifyListeners();

    // If both players ready, proceed to reveal/resolve
    if (state.bothPlayersReady) {
      Future.delayed(const Duration(seconds: 2), () {
        revealAndResolve();
      });
    }

    return true;
  }

  /// Reveal and resolve the round
  void revealAndResolve() {
    state.currentPhase = GamePhase.reveal;

    // Resolve combat
    state.currentPhase = GamePhase.resolve;
    RoundResult result = CombatResolver.resolveRound(
      state.player1,
      state.player2,
    );
    state.lastRoundResult = result;

    // Cleanup
    state.currentPhase = GamePhase.cleanup;
    CardManager.discardField(state.player1);
    CardManager.discardField(state.player2);

    // Check for game over
    if (state.isGameOver) {
      state.currentPhase = GamePhase.gameOver;
      notifyListeners();
    } else {
      state.currentTurn++;
      startTurn();
    }
  }

  void _playNpcTurn() {
    final npc = state.player2;
    final random = Random();

    // Make sure field is clear at the start of NPC selection
    CardManager.clearFieldToHand(npc);

    // Decide which cards to play
    final handCopy = List<Card>.from(npc.hand)..shuffle(random);

    // We have exactly 3 lanes
    final lanes = List<Lane>.from(Lane.values)..shuffle(random);

    final numToPlay = min(handCopy.length, lanes.length);
    for (int i = 0; i < numToPlay; i++) {
      final card = handCopy[i];
      final lane = lanes[i];
      CardManager.playCardToLane(npc, card.id, lane);
    }

    state.player2Ready = true;
  }

  /// Get current game state (for UI)
  GameState getState() => state;

  /// Get player state by ID
  PlayerState getPlayer(String playerId) {
    return playerId == 'player1' ? state.player1 : state.player2;
  }

  /// Reset game
  void reset() {
    initialize();
  }
}

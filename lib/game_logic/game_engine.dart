import 'package:flutter/foundation.dart';
import 'dart:math';

import 'models/game_state.dart';
import 'models/player_state.dart';
import 'models/card.dart';
import 'models/round_result.dart';
import 'enums/game_phase.dart';
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

  /// Player selects a card
  bool selectCard(String playerId, String cardId) {
    if (state.currentPhase != GamePhase.select) return false;

    PlayerState player = playerId == 'player1' ? state.player1 : state.player2;
    bool ok = CardManager.selectCard(player, cardId);
    if (ok) notifyListeners();
    return ok;
  }

  /// Player deselects a card
  bool deselectCard(String playerId, String cardId) {
    if (state.currentPhase != GamePhase.select) return false;

    PlayerState player = playerId == 'player1' ? state.player1 : state.player2;
    bool ok = CardManager.deselectCard(player, cardId);
    if (ok) notifyListeners();
    return ok;
  }

  /// Player manually moves a card from hand → field
  void moveCardToField(String playerId, Card card) {
    final player = getPlayer(playerId);

    player.hand.removeWhere((c) => c.id == card.id);
    player.selectedCards.removeWhere((c) => c.id == card.id);
    if (player.selectedCards.length < 3) {
      player.selectedCards.add(card);
    }

    notifyListeners();
  }

  void moveCardToHand(String playerId, Card card) {
    final player = getPlayer(playerId);
    // Remove from selected cards if it exists there
    player.selectedCards.removeWhere((c) => c.id == card.id);
    // Remove from hand to prevent duplicates
    player.hand.removeWhere((c) => c.id == card.id);
    // Add to hand
    player.hand.add(card);

    notifyListeners();
  }

  /// Player confirms their selection
  bool confirmSelection(String playerId) {
    if (state.currentPhase != GamePhase.select) return false;

    PlayerState player = playerId == 'player1' ? state.player1 : state.player2;

    if (player.selectedCards.isEmpty) return false;

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
    CardManager.discardSelected(state.player1);
    CardManager.discardSelected(state.player2);

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

    // Clear previous selections
    npc.selectedCards.clear();

    // Shuffle hand to randomize selection
    final handCopy = List.of(npc.hand);
    handCopy.shuffle(random);

    // Pick up to 3 cards to play
    final numToPlay = min(3, handCopy.length);
    for (int i = 0; i < numToPlay; i++) {
      final card = handCopy[i];
      npc.selectedCards.add(card);
      npc.hand.removeWhere((c) => c.id == card.id);
    }

    // Mark NPC ready
    state.player2Ready = true;

    notifyListeners();
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

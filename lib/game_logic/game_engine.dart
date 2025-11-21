import 'models/game_state.dart';
import 'models/player_state.dart';
import 'models/card.dart';
import 'models/round_result.dart';
import 'enums/game_phase.dart';
import 'services/deck_builder.dart';
import 'services/card_manager.dart';
import 'services/combat_resolver.dart';

/// Main game engine - manages all game logic
class GameEngine {
  late GameState state;

  /// Initialize a new game
  void initialize({String player1Name = 'Player 1', String player2Name = 'Player 2'}) {
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
    state = GameState(
      player1: player1,
      player2: player2,
    );

    // Start first turn
    startTurn();
  }

  /// Start a new turn (Draw Phase)
  void startTurn() {
    state.currentPhase = GamePhase.draw;
    CardManager.drawCards(state.player1);
    CardManager.drawCards(state.player2);
    state.currentPhase = GamePhase.select;
    state.player1Ready = false;
    state.player2Ready = false;
  }

  /// Player selects a card
  bool selectCard(String playerId, String cardId) {
    if (state.currentPhase != GamePhase.select) return false;

    PlayerState player = playerId == 'player1' ? state.player1 : state.player2;
    return CardManager.selectCard(player, cardId);
  }

  /// Player deselects a card
  bool deselectCard(String playerId, String cardId) {
    if (state.currentPhase != GamePhase.select) return false;

    PlayerState player = playerId == 'player1' ? state.player1 : state.player2;
    return CardManager.deselectCard(player, cardId);
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

    // If both players ready, proceed to reveal/resolve
    if (state.bothPlayersReady) {
      revealAndResolve();
    }

    return true;
  }

  /// Reveal and resolve the round
  void revealAndResolve() {
    state.currentPhase = GamePhase.reveal;

    // Resolve combat
    state.currentPhase = GamePhase.resolve;
    RoundResult result = CombatResolver.resolveRound(state.player1, state.player2);
    state.lastRoundResult = result;

    // Cleanup
    state.currentPhase = GamePhase.cleanup;
    CardManager.discardSelected(state.player1);
    CardManager.discardSelected(state.player2);

    // Check for game over
    if (state.isGameOver) {
      state.currentPhase = GamePhase.gameOver;
    } else {
      state.currentTurn++;
      startTurn();
    }
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

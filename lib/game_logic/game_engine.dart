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
  bool vsCpu;
  late GameState state;

  GameEngine({this.vsCpu = true});

  /// Initialize a new game
  void initialize({
    String player1Name = 'Player 1',
    String player2Name = 'Player 2',
    bool? vsCpuOverride,
  }) {
    if (vsCpuOverride != null) {
      vsCpu = vsCpuOverride;
    }

    // Create player states
    final player1 = PlayerState(
      id: 'player1',
      name: player1Name,
      deck: DeckBuilder.buildPlayerDeck('player1'),
    );

    final player2 = PlayerState(
      id: 'player2',
      name: player2Name,
      deck: DeckBuilder.buildPlayerDeck('player2'),
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

    if (vsCpu) {
      state.firstPlacerId = 'player1';
      state.currentPlacerId = 'player1';
    }

    state.currentPhase = GamePhase.select;
    state.player1Ready = false;
    state.player2Ready = false;

    notifyListeners();
  }

  /// Start a new turn (Draw Phase)
  void startTurn() {
    if (vsCpu) {
      state.firstPlacerId = 'player1';
      state.currentPlacerId = 'player1';
    } else {
      state.firstPlacerId = state.firstPlacerId == 'player1'
          ? 'player2'
          : 'player1';
      state.currentPlacerId = state.firstPlacerId;
    }

    state.currentPhase = GamePhase.draw;
    CardManager.drawCards(state.player1);
    CardManager.drawCards(state.player2);
    state.currentPhase = GamePhase.select;
    state.player1Ready = false;
    state.player2Ready = false;

    // If NPC is supposed to place first this turn,
    // let them pick and place their cards *now*.
    if (vsCpu && state.firstPlacerId == 'player2') {
      _playNpcTurn(); // NPC fills their lanes
      state.player2Ready = true;
    }

    notifyListeners();
  }

  void moveCardToLane(String playerId, Card card, Lane targetLane) {
    final player = getPlayer(playerId);

    // 1) Is this card currently on the field already?
    Lane? currentLane;
    for (final lane in Lane.values) {
      final laneCard = player.field.cardInLane(lane);
      if (laneCard != null && laneCard.id == card.id) {
        currentLane = lane;
        break;
      }
    }

    // 2) If it’s on the field: swap lanes instead of treating it as a hand card
    if (currentLane != null) {
      if (currentLane == targetLane) return; // no-op

      // Swap the two lane positions
      CardManager.swapLanes(player, currentLane, targetLane);
    } else {
      // 3) Otherwise it's a hand card → use existing behavior:
      //    play card from hand into lane, possibly replacing existing lane card.
      CardManager.playCardToLane(player, card.id, targetLane);
    }

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

    // In multiplayer: ignore confirms from the wrong player.
    if (!vsCpu && playerId != state.currentPlacerId) {
      return false;
    }

    if (vsCpu) {
      // SINGLEPLAYER: human vs CPU
      if (playerId == 'player1' && state.currentPlacerId == 'player1') {
        state.player1Ready = true;

        // Immediately play CPU turn
        _playNpcTurn();

        // Both players ready now
        state.player2Ready = true;

        // Proceed to reveal and resolve immediately
        state.currentPhase = GamePhase.reveal;
        notifyListeners();
        Future.delayed(const Duration(seconds: 2), () {
          revealAndResolve();
        });

        return true;
      }
    } else {
      // MULTIPLAYER: human vs human

      // First placer confirming: lock in their field and give the turn
      // to the other player, but don't reveal yet.
      if (playerId == state.firstPlacerId) {
        if (playerId == 'player1') {
          state.player1Ready = true;
        } else {
          state.player2Ready = true;
        }

        // Now the *other* player gets to place in response
        state.currentPlacerId = (playerId == 'player1') ? 'player2' : 'player1';
      } else {
        // Second placer confirming: they’re done too
        if (playerId == 'player1') {
          state.player1Ready = true;
        } else {
          state.player2Ready = true;
        }
      }
    }

    // If both players ready, proceed to reveal/resolve
    if (state.bothPlayersReady) {
      state.currentPhase = GamePhase.reveal;
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), () {
        revealAndResolve();
      });
    } else {
      notifyListeners();
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
      state,
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
    if (!vsCpu) return;

    final npc = state.player2;
    final random = Random();

    // Make sure field is clear at the start of NPC selection
    CardManager.clearFieldToHand(npc);

    // Copy + shuffle hand so we don't mutate while iterating
    final handCopy = List<Card>.from(npc.hand)..shuffle(random);

    // All lanes, shuffled, so lane choice is random too
    final lanes = List<Lane>.from(Lane.values)..shuffle(random);

    // Max cards NPC *could* play this turn
    final maxPlayable = min(3, min(handCopy.length, lanes.length));

    final numToPlay = maxPlayable == 0
        ? 0
        : random.nextInt(maxPlayable) + 1; // 0..maxPlayable

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

  void loadFromState(GameState newState) {
    state = newState;
    notifyListeners();
  }
}

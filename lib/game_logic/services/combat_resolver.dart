import 'dart:math';
import 'package:card_game/game_logic/enums/lane_column.dart' show Lane;

import '../models/player_state.dart';
import '../models/game_state.dart';
import '../models/round_result.dart';
import '../enums/lane_column.dart';
import '../card_library/card_effects.dart';

class CombatResolver {
  static RoundResult resolveRound(
    PlayerState player1,
    PlayerState player2,
    GameState game,
  ) {
    int p1DamageTaken = 0, p2DamageTaken = 0;
    int p1Healed = 0, p2Healed = 0;

    for (final lane in Lane.values) {
      var p1Card = player1.field.cardInLane(lane);
      var p2Card = player2.field.cardInLane(lane);

      // 1) Run resolve effects first
      if (p1Card != null) {
        final eff1 = CardEffects.forCard(p1Card);
        eff1?.call(
          CardEffectContext(
            game: game,
            owner: player1,
            opponent: player2,
            lane: lane,
            card: p1Card,
          ),
        );

        // effect might have destroyed/moved the card
        p1Card = player1.field.cardInLane(lane);
      }

      if (p2Card != null) {
        final eff2 = CardEffects.forCard(p2Card);
        eff2?.call(
          CardEffectContext(
            game: game,
            owner: player2,
            opponent: player1,
            lane: lane,
            card: p2Card,
          ),
        );

        p2Card = player2.field.cardInLane(lane);
      }

      if (p1Card != null && p2Card != null) {
        // Card-vs-card combat in this lane
        // (You can add shields, effects, etc here later)
        p1DamageTaken += max(0, p2Card.attack - p1Card.defense);
        p2DamageTaken += max(0, p1Card.attack - p2Card.defense);
      } else if (p1Card != null && p2Card == null) {
        // Player 1 hits player 2 directly in this lane
        p2DamageTaken += p1Card.attack;
      } else if (p2Card != null && p1Card == null) {
        // Player 2 hits player 1 directly in this lane
        p1DamageTaken += p2Card.attack;
      }

      if (p1Card != null) {
        p1Healed += p1Card.heal;
      }

      if (p2Card != null) {
        p2Healed += p2Card.heal;
      }
    }

    player1.health -= p1DamageTaken;
    player2.health -= p2DamageTaken;

    player1.health += p1Healed;
    player1.health = min(player1.health, player1.maxHealth);

    player2.health += p2Healed;
    player2.health = min(player2.health, player2.maxHealth);

    // Check for game over
    bool isGameOver = !player1.isAlive || !player2.isAlive;
    String? winner;
    if (isGameOver) {
      if (!player1.isAlive && !player2.isAlive) {
        winner = 'draw';
      } else if (!player1.isAlive) {
        winner = 'player2';
      } else {
        winner = 'player1';
      }
    }

    return RoundResult(
      player1Damage: p2DamageTaken,
      player2Damage: p1DamageTaken,
      player1Healed: p1Healed,
      player2Healed: p2Healed,
      isGameOver: isGameOver,
      winner: winner,
    );
  }
}

import 'dart:math';
import '../models/player_state.dart';
import '../models/round_result.dart';
import '../enums/card_type.dart';

class CombatResolver {
  static RoundResult resolveRound(PlayerState player1, PlayerState player2) {
    // Calculate totals for player 1
    int p1Damage = 0, p1Shield = 0, p1Heal = 0;
    for (var card in player1.selectedCards) {
      p1Damage += card.attack;
      p1Shield += card.defense;
      p1Heal += card.heal;
      card.applyEffect(player1, player2);
    }

    // Calculate totals for player 2
    int p2Damage = 0, p2Shield = 0, p2Heal = 0;
    for (var card in player2.selectedCards) {
      p2Damage += card.attack;
      p2Shield += card.defense;
      p2Heal += card.heal;
      card.applyEffect(player2, player1);
    }

    // Apply shields to reduce damage
    int p1DamageTaken = max(0, p2Damage - p1Shield);
    int p2DamageTaken = max(0, p1Damage - p2Shield);

    // Apply damage to health
    player1.health = max(0, player1.health - p1DamageTaken);
    player2.health = max(0, player2.health - p2DamageTaken);

    // Apply healing (cannot exceed max HP)
    player1.health = min(player1.maxHealth, player1.health + p1Heal);
    player2.health = min(player2.maxHealth, player2.health + p2Heal);

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
      player1Damage: p1Damage,
      player1Shield: p1Shield,
      player1Heal: p1Heal,
      player1DamageTaken: p1DamageTaken,
      player1HealthAfter: player1.health,
      player2Damage: p2Damage,
      player2Shield: p2Shield,
      player2Heal: p2Heal,
      player2DamageTaken: p2DamageTaken,
      player2HealthAfter: player2.health,
      isGameOver: isGameOver,
      winner: winner,
    );
  }
}

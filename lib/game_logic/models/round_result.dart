// class RoundResult {
//   final int player1Damage;
//   final int player1Shield;
//   final int player1Heal;
//   final int player1DamageTaken;
//   final int player1HealthAfter;

//   final int player2Damage;
//   final int player2Shield;
//   final int player2Heal;
//   final int player2DamageTaken;
//   final int player2HealthAfter;

//   final bool isGameOver;
//   final String? winner; // null, "player1", "player2", "draw"

//   RoundResult({
//     required this.player1Damage,
//     required this.player1Shield,
//     required this.player1Heal,
//     required this.player1DamageTaken,
//     required this.player1HealthAfter,
//     required this.player2Damage,
//     required this.player2Shield,
//     required this.player2Heal,
//     required this.player2DamageTaken,
//     required this.player2HealthAfter,
//     required this.isGameOver,
//     this.winner,
//   });

//   Map<String, dynamic> toJson() => {
//     'player1': {
//       'damage': player1Damage,
//       'shield': player1Shield,
//       'heal': player1Heal,
//       'damageTaken': player1DamageTaken,
//       'healthAfter': player1HealthAfter,
//     },
//     'player2': {
//       'damage': player2Damage,
//       'shield': player2Shield,
//       'heal': player2Heal,
//       'damageTaken': player2DamageTaken,
//       'healthAfter': player2HealthAfter,
//     },
//     'isGameOver': isGameOver,
//     'winner': winner,
//   };

//   @override
//   String toString() {
//     String result = 'Round Result:\n';
//     result += 'P1: ${player1Damage}ATK | ${player1Shield}DEF | ${player1Heal}HEAL → -${player1DamageTaken}HP → ${player1HealthAfter}HP\n';
//     result += 'P2: ${player2Damage}ATK | ${player2Shield}DEF | ${player2Heal}HEAL → -${player2DamageTaken}HP → ${player2HealthAfter}HP';
//     if (isGameOver) result += '\nWinner: $winner';
//     return result;
//   }
// }

class RoundResult {
  final int player1Damage;
  final int player2Damage;
  final int player1Healed;
  final int player2Healed;

  final bool isGameOver;
  final String? winner; // null, "player1", "player2", "draw"

  RoundResult({
    required this.player1Damage,
    required this.player1Healed,
    required this.player2Damage,
    required this.player2Healed,
    required this.isGameOver,
    this.winner,
  });
}

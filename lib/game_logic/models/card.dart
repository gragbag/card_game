import '../enums/card_type.dart';
import 'player_state.dart';
import 'dart:math';

class Card {
  final String id;
  final CardType type;
  final String name;

  final int attack; // for damage cards
  final int defense; // for shield cards
  final int heal; // for heal cards

  Card({
    required this.id,
    required this.type,
    required this.name,
    this.attack = 0,
    this.defense = 0,
    this.heal = 0,
  });


  void applyEffect(PlayerState owner, PlayerState opponent) {
    if (type == CardType.wild) {
      // 8~15 Random damage
      final rand = Random();
      int damage = 8 + rand.nextInt(8);

      opponent.health = (opponent.health - damage).clamp(0, opponent.maxHealth);

      print("Wild card dealt $damage damage!");
    }
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'attack': attack,
    'defense': defense,
    'heal': heal,
  };

  factory Card.fromJson(Map<String, dynamic> json) => Card(
    id: json['id'],
    type: CardType.values.firstWhere((e) => e.name == json['type']),
    name: json['name'],
    attack: json['attack'] ?? 0,
    defense: json['defense'] ?? 0,
    heal: json['heal'] ?? 0,
  );

  @override
  String toString() =>
      'Card($name, $type, ATK:$attack DEF:$defense HEAL:$heal)';
}

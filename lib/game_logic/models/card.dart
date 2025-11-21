import '../enums/card_type.dart';
import 'player_state.dart';

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

  /// Optional: special effect for wild cards or future expansion
  void applyEffect(PlayerState owner, PlayerState opponent) {
    if (type == CardType.wild) {
      // Example: random effect
      int choice =
          (0 + (3 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000))
              .floor();
      switch (choice) {
        case 0:
          owner.health = (owner.health + 3).clamp(0, owner.maxHealth);
          break;
        case 1:
          opponent.health = (opponent.health - 3).clamp(0, opponent.maxHealth);
          break;
        case 2:
          // Give small shield
          // Could implement a temp shield field later
          break;
      }
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

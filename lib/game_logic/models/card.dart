import '../enums/card_type.dart';

class Card {
  final String id;
  final CardType type;
  final String name;

  int attack; // for damage cards
  int defense; // for shield cards
  int heal; // for heal cards

  /// Optional identifier for a special effect in CardEffects.
  final String? effectKey;

  /// Optional text shown in UI.
 // final String? description;

  Card({
    required this.id,
    required this.type,
   required this.name,
    this.attack = 0,
    this.defense = 0,
    this.heal = 0,
    this.effectKey,
    //this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'attack': attack,
    'defense': defense,
    'heal': heal,
    'effectKey': effectKey,
    //'description': description,
  };

  factory Card.fromJson(Map<String, dynamic> json) => Card(
    id: json['id'],
    type: CardType.values.firstWhere((e) => e.name == json['type']),
    name: json['name'],
    attack: json['attack'] ?? 0,
    defense: json['defense'] ?? 0,
    heal: json['heal'] ?? 0,
    effectKey: json['effectKey'],
    //description: json['description'],
  );

  @override
  String toString() =>
      'Card($name, $type, ATK:$attack DEF:$defense HEAL:$heal)';
}

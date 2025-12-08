import 'package:card_game/game_logic/models/field_state.dart' show FieldState;

import 'card.dart';

class PlayerState {
  final String id;
  String name;
  int health;
  final int maxHealth;
  List<Card> hand;
  List<Card> deck;
  List<Card> discardPile;

  /// Cards currently on the board (3 lanes)
  final FieldState field;

  PlayerState({
    required this.id,
    required this.name,
    this.health = 25,
    this.maxHealth = 25,
    List<Card>? hand,
    List<Card>? deck,
    List<Card>? discardPile,
    FieldState? field,
  }) : hand = hand ?? [],
       deck = deck ?? [],
       discardPile = discardPile ?? [],
       field = field ?? FieldState();

  bool get isAlive => health > 0;
  bool get canDrawCards => deck.isNotEmpty;
  int get cardsInHand => hand.length;
  int get cardsInDeck => deck.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'health': health,
    'maxHealth': maxHealth,
    'hand': hand.map((c) => c.toJson()).toList(),
    'deck': deck.map((c) => c.toJson()).toList(),
    'discardPile': discardPile.map((c) => c.toJson()).toList(),
    'field': field.toJson(),
  };

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      id: json['id'],
      name: json['name'],
      health: json['health'],
      maxHealth: json['maxHealth'],
      hand: (json['hand'] as List<dynamic>)
          .map((e) => Card.fromJson(e as Map<String, dynamic>))
          .toList(),
      deck: (json['deck'] as List<dynamic>)
          .map((e) => Card.fromJson(e as Map<String, dynamic>))
          .toList(),
      discardPile: (json['discardPile'] as List<dynamic>)
          .map((e) => Card.fromJson(e as Map<String, dynamic>))
          .toList(),
      field: FieldState.fromJson(json['field']),
    );
  }
}

import 'package:card_game/game_logic/models/field_state.dart' show FieldState;

import 'card.dart';

class PlayerState {
  final String id;
  final String name;
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
}

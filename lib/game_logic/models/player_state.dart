import 'card.dart';

class PlayerState {
  final String id;
  final String name;
  int health;
  final int maxHealth;
  List<Card> hand;
  List<Card> deck;
  List<Card> discardPile;
  List<Card> selectedCards;

  PlayerState({
    required this.id,
    required this.name,
    this.health = 30,
    this.maxHealth = 30,
    required this.deck,
  })  : hand = [],
        discardPile = [],
        selectedCards = [];

  bool get isAlive => health > 0;
  bool get canDrawCards => deck.isNotEmpty;
  int get cardsInHand => hand.length;
  int get cardsInDeck => deck.length;
  int get selectedCount => selectedCards.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'health': health,
    'maxHealth': maxHealth,
    'hand': hand.map((c) => c.toJson()).toList(),
    'deck': deck.map((c) => c.toJson()).toList(),
    'discardPile': discardPile.map((c) => c.toJson()).toList(),
    'selectedCards': selectedCards.map((c) => c.toJson()).toList(),
  };

  @override
  String toString() => 'Player($name, HP: $health/$maxHealth, Hand: ${hand.length}, Deck: ${deck.length})';
}

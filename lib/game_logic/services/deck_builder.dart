import 'dart:math';
import '../models/card.dart';
import '../enums/card_type.dart';

class DeckBuilder {
  static List<Card> createStandardDeck() {
    List<Card> cards = [];
    int id = 0;

    // 15 Damage cards (values 6-10)
    for (int i = 0; i < 15; i++) {
      cards.add(
        Card(
          id: 'card_${id++}',
          type: CardType.damage,
          name: 'Attack',
          attack: 6 + Random().nextInt(5),
        ),
      );
    }

    // 15 Shield cards (values 2-5)
    for (int i = 0; i < 15; i++) {
      cards.add(
        Card(
          id: 'card_${id++}',
          type: CardType.shield,
          name: 'Shield',
          defense: 2 + Random().nextInt(4),
        ),
      );
    }

    // 8 Heal cards (values 2-4)
    for (int i = 0; i < 8; i++) {
      cards.add(
        Card(
          id: 'card_${id++}',
          type: CardType.heal,
          name: 'Heal',
          heal: 2 + Random().nextInt(3),
        ),
      );
    }

    // 2 Wild cards
    for (int i = 0; i < 2; i++) {
      cards.add(Card(id: 'card_${id++}', type: CardType.wild, name: 'Wild'));
    }

    return cards;
  }

  static List<List<Card>> splitDeck(List<Card> deck) {
    if (deck.length != 40) {
      throw ArgumentError('Deck must contain exactly 40 cards');
    }
    return [deck.sublist(0, 20), deck.sublist(20, 40)];
  }
}

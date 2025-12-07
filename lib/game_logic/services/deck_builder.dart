import '../models/card.dart';
import '../card_library/card_library.dart';

class DeckBuilder {
  static List<Card> buildPlayerDeck(String ownerId) {
    List<Card> cards = [];
    var idCounter = 0;

    void addCopies(String key, int copies) {
      final bp = CardLibrary.byKey(key);
      for (int i = 0; i < copies; i++) {
        cards.add(bp.toCard('${ownerId}_${key}_$idCounter'));
        idCounter++;
      }
    }

    // ---- Choose what goes into a deck ----
    // You can tweak these numbers however you want.

    // -------------------
    // ATTACK (10 cards)
    // -------------------
    addCopies('quick_strike', 3);
    addCopies('heavy_strike', 2);
    addCopies('berserker', 1);
    addCopies('paladin', 1);
    addCopies('lifesteal_blade', 1);
    addCopies('blood_pact', 1);
    addCopies('storm_archer', 1);

    // -------------------
    // DEFENSE (6 cards)
    // -------------------
    addCopies('guardian', 2);
    addCopies('shield_wall', 1);
    addCopies('thorned_guardian', 1);
    addCopies('fortify', 1);
    addCopies('shield_channeler', 1);

    // -------------------
    // HEALING (5 cards)
    // -------------------
    addCopies('healer', 2);
    addCopies('battle_priest', 2);
    addCopies('holy_beacon', 1);

    // -------------------
    // UTILITY / BUFFS (4 cards)
    // -------------------
    addCopies('war_banner', 2);
    addCopies('rallying_cry', 1);
    addCopies('overcharger', 1);

    // -------------------
    // SPECIAL / REMOVAL (5 cards)
    // -------------------
    addCopies('assassin', 2);
    addCopies('fireball', 1);
    addCopies('chain_lightning', 1);
    addCopies('healing_seal', 1);

    // Optionally, assert deck size if you care (e.g. 30 or 40 cards)
    // if (cards.length != 30) {
    //   throw ArgumentError(
    //     'Deck must contain exactly 30 cards (current: ${cards.length}).',
    //   );
    // }

    cards.shuffle();
    return cards;
  }
}

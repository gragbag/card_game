import '../models/player_state.dart';
import '../models/card.dart';

class CardManager {
  /// Draw cards until player has 5 in hand
  static void drawCards(PlayerState player) {
    while (player.hand.length < 5 && player.deck.isNotEmpty) {
      player.hand.add(player.deck.removeAt(0));
    }
  }

  /// Select a card from hand (max 3 cards)
  static bool selectCard(PlayerState player, String cardId) {
    if (player.selectedCards.length >= 3) {
      return false;
    }

    final cardIndex = player.hand.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) {
      return false;
    }

    final card = player.hand.removeAt(cardIndex);
    player.selectedCards.add(card);
    return true;
  }

  /// Deselect a card (return to hand)
  static bool deselectCard(PlayerState player, String cardId) {
    final cardIndex = player.selectedCards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) {
      return false;
    }

    final card = player.selectedCards.removeAt(cardIndex);
    player.hand.add(card);
    return true;
  }

  /// Move selected cards to discard pile
  static void discardSelected(PlayerState player) {
    player.discardPile.addAll(player.selectedCards);
    player.selectedCards.clear();
  }

  /// Clear all selections
  static void clearSelection(PlayerState player) {
    player.hand.addAll(player.selectedCards);
    player.selectedCards.clear();
  }
}

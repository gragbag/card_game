// card_manager.dart
import '../models/player_state.dart';
import '../models/card.dart';
import '../enums/lane_column.dart';

class CardManager {
  static const int _startingHandSize = 5;
  static const int _maxHandSize = 7;

  /// Draw cards until player has 5 in hand
  static void drawHand(PlayerState player) {
    while (player.hand.length < _startingHandSize && player.deck.isNotEmpty) {
      player.hand.add(player.deck.removeAt(0));
    }
  }

  /// Draw up to 2 cards (obeying max hand size)
  static void drawCards(PlayerState player) {
    for (int i = 0; i < 2; i++) {
      if (player.deck.isEmpty) break;
      if (player.hand.length >= _maxHandSize) break;
      player.hand.add(player.deck.removeAt(0));
    }
  }

  /// Play a card from hand into a specific lane.
  /// Returns false if lane occupied or card not in hand.
  static bool playCardToLane(PlayerState player, String cardId, Lane lane) {
    // lane already occupied?
    if (player.field.cardInLane(lane) != null) {
      removeCardFromLane(player, lane);
    }

    final index = player.hand.indexWhere((c) => c.id == cardId);
    if (index == -1) return false;

    final card = player.hand.removeAt(index);
    player.field.setCardInLane(lane, card);
    return true;
  }

  /// Remove the card in [lane] back to hand (or discard if hand is full).
  static bool removeCardFromLane(PlayerState player, Lane lane) {
    final card = player.field.cardInLane(lane);
    if (card == null) return false;

    if (player.hand.length < _maxHandSize) {
      player.hand.add(card);
    } else {
      player.discardPile.add(card);
    }

    player.field.setCardInLane(lane, null);
    return true;
  }

  /// Discard everything currently on the field (used in cleanup).
  static void discardField(PlayerState player) {
    for (final lane in Lane.values) {
      final card = player.field.cardInLane(lane);
      if (card != null) {
        player.discardPile.add(card);
        player.field.setCardInLane(lane, null);
      }
    }
  }

  /// Clear field, returning cards to hand if possible, otherwise discard.
  /// (If you still want a "cancel placement" behavior.)
  static void clearFieldToHand(PlayerState player) {
    for (final lane in Lane.values) {
      final card = player.field.cardInLane(lane);
      if (card != null) {
        if (player.hand.length < _maxHandSize) {
          player.hand.add(card);
        } else {
          player.discardPile.add(card);
        }
        player.field.setCardInLane(lane, null);
      }
    }
  }
}

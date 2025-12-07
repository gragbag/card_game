// card_manager.dart
import '../models/player_state.dart';
import '../models/card.dart';
import '../enums/lane_column.dart';

class CardManager {
  static const int _startingHandSize = 5;
  static const int _maxHandSize = 9;

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
    if (_cardInLane(player, lane) != null) {
      removeCardFromLane(player, lane);
    }

    final index = player.hand.indexWhere((c) => c.id == cardId);
    if (index == -1) return false;

    final card = player.hand.removeAt(index);
    _setCardInLane(player, lane, card);
    return true;
  }

  /// Remove the card in [lane] back to hand (or discard if hand is full).
  static bool removeCardFromLane(PlayerState player, Lane lane) {
    final card = _cardInLane(player, lane);
    if (card == null) return false;

    if (player.hand.length < _maxHandSize) {
      player.hand.add(card);
    } else {
      player.discardPile.add(card);
    }

    _setCardInLane(player, lane, null);
    return true;
  }

  /// Discard everything currently on the field (used in cleanup).
  static void discardField(PlayerState player) {
    for (final lane in Lane.values) {
      final card = _cardInLane(player, lane);
      if (card != null) {
        player.discardPile.add(card);
        _setCardInLane(player, lane, null);
      }
    }
  }

  /// Clear field, returning cards to hand if possible, otherwise discard.
  static void clearFieldToHand(PlayerState player) {
    for (final lane in Lane.values) {
      final card = _cardInLane(player, lane);
      if (card != null) {
        if (player.hand.length < _maxHandSize) {
          player.hand.add(card);
        } else {
          player.discardPile.add(card);
        }
        _setCardInLane(player, lane, null);
      }
    }
  }

  static void swapLanes(PlayerState player, Lane from, Lane to) {
    if (from == to) return;

    final fromCard = _cardInLane(player, from);
    final toCard = _cardInLane(player, to);

    _setCardInLane(player, from, toCard);
    _setCardInLane(player, to, fromCard);
  }

  static Card? _cardInLane(PlayerState player, Lane lane) {
    switch (lane) {
      case Lane.left:
        return player.field.left;
      case Lane.center:
        return player.field.center;
      case Lane.right:
        return player.field.right;
    }
  }

  static void _setCardInLane(PlayerState player, Lane lane, Card? card) {
    switch (lane) {
      case Lane.left:
        player.field.left = card;
        break;
      case Lane.center:
        player.field.center = card;
        break;
      case Lane.right:
        player.field.right = card;
        break;
    }
  }
}

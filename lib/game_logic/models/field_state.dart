// field_state.dart
import 'package:card_game/game_logic/enums/lane_column.dart'; // Lane enum
import 'package:card_game/game_logic/models/card.dart' show Card;

class FieldState {
  Card? left;
  Card? center;
  Card? right;

  Card? cardInLane(Lane lane) {
    switch (lane) {
      case Lane.left:
        return left;
      case Lane.center:
        return center;
      case Lane.right:
        return right;
    }
  }

  void setCardInLane(Lane lane, Card? card) {
    switch (lane) {
      case Lane.left:
        left = card;
        break;
      case Lane.center:
        center = card;
        break;
      case Lane.right:
        right = card;
        break;
    }
  }

  List<Card?> toList() => [left, center, right];

  void clear() {
    left = null;
    center = null;
    right = null;
  }
}

// field_state.dart
import 'package:card_game/game_logic/enums/lane_column.dart'; // Lane enum
import 'package:card_game/game_logic/models/card.dart' show Card;

class FieldState {
  Card? left;
  Card? center;
  Card? right;

  FieldState({this.left, this.center, this.right});

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

  Map<String, dynamic> toJson() => {
    'left': left?.toJson(),
    'center': center?.toJson(),
    'right': right?.toJson(),
  };

  factory FieldState.fromJson(Map<String, dynamic> json) {
    return FieldState()
      ..left = json['left'] != null ? Card.fromJson(json['left']) : null
      ..center = json['center'] != null ? Card.fromJson(json['center']) : null
      ..right = json['right'] != null ? Card.fromJson(json['right']) : null;
  }
}

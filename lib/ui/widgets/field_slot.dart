// field_slot.dart (new)
import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';
import '../../game_logic/models/player_state.dart';
import '../../game_logic/models/card.dart' as game_card;
import '../../game_logic/enums/lane_column.dart';
import 'card_widget.dart';

class FieldSlot extends StatelessWidget {
  final PlayerState player;
  final GameEngine engine;
  final bool isOpponent;
  final double scale;
  final Lane lane;

  const FieldSlot({
    super.key,
    required this.player,
    required this.engine,
    required this.lane,
    required this.scale,
    this.isOpponent = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = player.field.cardInLane(lane);

    return DragTarget<game_card.Card>(
      onWillAccept: (incoming) => !isOpponent && incoming != null,
      onAccept: (card) {
        engine.moveCardToLane(player.id, card, lane);
      },
      builder: (context, candidateData, rejectedData) {
        final highlight = candidateData.isNotEmpty && !isOpponent;

        return Container(
          width: 90 * scale,
          height: 120 * scale,
          decoration: BoxDecoration(
            color: highlight
                ? Colors.green.withOpacity(0.25)
                : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: card != null ? Colors.white70 : Colors.white24,
              width: card != null ? 2 * scale : 1 * scale,
            ),
          ),
          child: Center(
            child: card == null
                ? Text(
                    'EMPTY',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 14 * scale,
                    ),
                  )
                : isOpponent
                ? CardWidget(card: card, scale: scale)
                : _draggableCard(card, scale),
          ),
        );
      },
    );
  }

  Widget _draggableCard(game_card.Card card, double scale) {
    if (isOpponent) return CardWidget(card: card, scale: scale);

    return Draggable<game_card.Card>(
      data: card,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 90 * scale,
          height: 120 * scale,
          child: CardWidget(card: card, scale: scale),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: CardWidget(card: card, scale: scale),
      ),
      child: CardWidget(card: card, scale: scale),
    );
  }
}

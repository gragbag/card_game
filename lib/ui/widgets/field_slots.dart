import 'package:card_game/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';
import '../../game_logic/models/player_state.dart';
import '../../game_logic/models/card.dart' as game_card;

class FieldSlots extends StatefulWidget {
  final PlayerState player;
  final GameEngine engine;
  final bool isOpponent;
  final double scale;

  const FieldSlots({
    super.key,
    required this.player,
    required this.engine,
    this.isOpponent = false,
    required this.scale,
  });

  @override
  State<FieldSlots> createState() => _FieldSlotsState();
}

class _FieldSlotsState extends State<FieldSlots> {
  static const int maxSlots = 3;

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final engine = widget.engine;
    final isOpponent = widget.isOpponent;
    final scale = widget.scale;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(maxSlots, (index) {
          final placedCard = index < player.selectedCards.length
              ? player.selectedCards[index]
              : null;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            child: DragTarget<game_card.Card>(
              onWillAccept: (incoming) =>
                  !isOpponent &&
                  incoming != null &&
                  player.selectedCards.length < maxSlots,

              onAcceptWithDetails: (details) {
                final incomingCard = details.data;
                engine.moveCardToField(player.id, incomingCard);
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
                      color: placedCard != null
                          ? Colors.white70
                          : Colors.white24,
                      width: placedCard != null ? 2 * scale : 1 * scale,
                    ),
                  ),
                  child: Center(
                    child: placedCard == null
                        ? Text(
                            'EMPTY',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 14 * scale,
                            ),
                          )
                        : isOpponent
                        ? CardWidget(
                            card: placedCard,
                            scale: scale,
                          ) // just show
                        : _placedCardView(
                            placedCard,
                            scale,
                          ), // draggable for player
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _placedCardView(game_card.Card card, double scale) {
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

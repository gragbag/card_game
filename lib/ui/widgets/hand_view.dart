import 'package:card_game/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart' hide Card;
import '../../game_logic/models/card.dart' as game_card show Card;
import '../../game_logic/models/player_state.dart';
import '../../game_logic/game_engine.dart';

class HandView extends StatefulWidget {
  final PlayerState player;
  final GameEngine engine;
  final double scale;

  const HandView({
    super.key,
    required this.player,
    required this.engine,
    required this.scale,
  });

  @override
  State<HandView> createState() => _HandViewState();
}

class _HandViewState extends State<HandView> {
  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final scale = widget.scale;

    return Center(
      child: DragTarget<game_card.Card>(
        onWillAccept: (incoming) => incoming != null,
        onAcceptWithDetails: (details) {
          final card = details.data;
          widget.engine.moveCardToHand(widget.player.id, card);
        },
        builder: (context, candidateData, rejectedData) {
          final highlight = candidateData.isNotEmpty;
          return Container(
            height: 130 * widget.scale,
            padding: EdgeInsets.symmetric(vertical: 12 * widget.scale),
            color: highlight ? Colors.grey.shade800 : Colors.transparent,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.player.hand.length,
              itemBuilder: (context, index) {
                final card = widget.player.hand[index];
                final isSelected = widget.player.selectedCards.any(
                  (c) => c?.id == card.id,
                );

                return Draggable<game_card.Card>(
                  data: card,
                  feedback: Material(
                    color: Colors.transparent,
                    child: CardWidget(
                      card: card,
                      scale: scale,
                      selected: isSelected,
                      dragging: true,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: CardWidget(
                      card: card,
                      scale: scale,
                      selected: isSelected,
                    ),
                  ),
                  child: CardWidget(
                    card: card,
                    scale: scale,
                    selected: isSelected,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

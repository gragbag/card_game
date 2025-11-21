import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';
import '../../game_logic/models/player_state.dart';
import '../../game_logic/models/card.dart' as game_card;

class FieldSlots extends StatefulWidget {
  final PlayerState player;
  final GameEngine engine;
  final bool isOpponent;

  const FieldSlots({
    super.key,
    required this.player,
    required this.engine,
    this.isOpponent = false,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(maxSlots, (index) {
          final placedCard = index < player.selectedCards.length
              ? player.selectedCards[index]
              : null;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DragTarget<game_card.Card>(
              onWillAccept: (incoming) =>
                  !isOpponent &&
                  incoming != null &&
                  player.selectedCards.length < maxSlots,

              onAccept: (incomingCard) {
                engine.selectCard(player.id, incomingCard.id);

                setState(() {});
              },

              builder: (context, candidateData, rejectedData) {
                final highlight = candidateData.isNotEmpty && !isOpponent;

                return Container(
                  width: 90,
                  height: 120,
                  decoration: BoxDecoration(
                    color: highlight
                        ? Colors.green.withOpacity(0.25)
                        : Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: placedCard != null
                          ? Colors.white70
                          : Colors.white24,
                      width: placedCard != null ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: placedCard == null
                        ? const Text(
                            'EMPTY',
                            style: TextStyle(color: Colors.white24),
                          )
                        : _placedCardView(placedCard),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _placedCardView(game_card.Card card) {
    // Simple view for a placed card (can be replaced with your CardWidget)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (card.attack > 0)
          Text(
            'ATK ${card.attack}',
            style: const TextStyle(color: Colors.white70),
          ),
        if (card.defense > 0)
          Text(
            'DEF ${card.defense}',
            style: const TextStyle(color: Colors.white70),
          ),
        if (card.heal > 0)
          Text(
            'HEAL ${card.heal}',
            style: const TextStyle(color: Colors.white70),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart' hide Card;
import '../../game_logic/models/card.dart';
import '../../game_logic/models/player_state.dart';
import '../../game_logic/game_engine.dart';
import '../../game_logic/enums/card_type.dart';

class HandView extends StatelessWidget {
  final PlayerState player;
  final GameEngine engine;
  final VoidCallback? refresh;

  const HandView({
    super.key,
    required this.player,
    required this.engine,
    this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: player.hand.length,
          itemBuilder: (context, index) {
            final Card card = player.hand[index];
            final isSelected = player.selectedCards.any((c) => c.id == card.id);

            return Draggable<Card>(
              data: card,
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 80,
                  child: _buildCard(card, dragging: true),
                ),
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: _buildCard(card)),
              child: GestureDetector(
                onTap: () {
                  engine.selectCard(player.id, card.id);
                  refresh?.call();
                },
                child: _buildCard(card, selected: isSelected),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(Card card, {bool dragging = false, bool selected = false}) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _cardColor(card.type),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selected ? Colors.yellow : Colors.white54,
          width: selected ? 2.5 : 1.5,
        ),
        boxShadow: dragging
            ? [const BoxShadow(color: Colors.black45, blurRadius: 10)]
            : [],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(_statText(card), style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // Show the one stat that matters for the card type
  String _statText(Card card) {
    switch (card.type) {
      case CardType.damage:
        return 'ATK: ${card.attack}';
      case CardType.shield:
        return 'DEF: ${card.defense}';
      case CardType.heal:
        return 'HEAL: ${card.heal}';
      case CardType.wild:
        // Wild can show something generic or special text
        return 'WILD';
    }
  }

  // Color by enum (safer and clearer)
  Color _cardColor(CardType type) {
    switch (type) {
      case CardType.damage:
        return Colors.red.shade700;
      case CardType.shield:
        return Colors.blue.shade600;
      case CardType.heal:
        return Colors.green.shade600;
      case CardType.wild:
        return Colors.purple.shade600;
    }
  }
}

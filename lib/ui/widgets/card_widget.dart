import 'package:flutter/material.dart' hide Card;
import '../../game_logic/models/card.dart';
import '../../game_logic/enums/card_type.dart';

class CardWidget extends StatelessWidget {
  final Card card;
  final bool selected;
  final double scale;
  final bool dragging;

  const CardWidget({
    super.key,
    required this.card,
    this.selected = false,
    required this.scale,
    this.dragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80 * scale,
      height: 110 * scale,
      margin: EdgeInsets.symmetric(horizontal: 8 * scale),
      padding: EdgeInsets.all(6 * scale),
      decoration: BoxDecoration(
        color: _cardColor(card.type),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: selected ? Colors.yellow : Colors.white54,
          width: selected ? 2.5 * scale : 1.5 * scale,
        ),
        boxShadow: dragging
            ? [BoxShadow(color: Colors.black45, blurRadius: 10 * scale)]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14 * scale,
            ),
            textAlign: TextAlign.center,
          ),
          if (card.attack > 0)
            Text(
              'ATK: ${card.attack}',
              style: TextStyle(color: Colors.white70, fontSize: 12 * scale),
            ),
          if (card.defense > 0)
            Text(
              'DEF: ${card.defense}',
              style: TextStyle(color: Colors.white70, fontSize: 12 * scale),
            ),
          if (card.heal > 0)
            Text(
              'HEAL: ${card.heal}',
              style: TextStyle(color: Colors.white70, fontSize: 12 * scale),
            ),
        ],
      ),
    );
  }

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

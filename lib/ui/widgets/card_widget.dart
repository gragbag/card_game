import 'package:flutter/material.dart' hide Card;
import '../../game_logic/models/card.dart';
import '../../game_logic/enums/card_type.dart';

class CardWidget extends StatelessWidget {
  final Card card;
  final bool selected;

  const CardWidget({super.key, required this.card, this.selected = false});

  Color _cardColor() {
    switch (card.type) {
      case CardType.damage:
        return Colors.redAccent;
      case CardType.shield:
        return Colors.blueAccent;
      case CardType.heal:
        return Colors.green;
      case CardType.wild:
        return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 90,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardColor(),
        border: Border.all(
          color: selected ? Colors.yellow : Colors.black,
          width: selected ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.name,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (card.attack > 0)
            Text(
              'ATK: ${card.attack}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          if (card.defense > 0)
            Text(
              'DEF: ${card.defense}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          if (card.heal > 0)
            Text(
              'HEAL: ${card.heal}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
        ],
      ),
    );
  }
}

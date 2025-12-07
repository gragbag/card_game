import 'package:auto_size_text/auto_size_text.dart';
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
    return GestureDetector(
      onTap: () {
        _showCardDetails(context, card, scale);
      },
      child: _buildCardFront(),
    );
  }

  Widget _buildCardFront() {
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
          _buildName(scale),

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

  Widget _buildName(double scale) {
    final allowTwoLines = card.name.contains(' ');

    return AutoSizeText(
      card.name,
      textAlign: TextAlign.center,
      maxLines: allowTwoLines ? 2 : 1,
      minFontSize: 8 * scale,
      stepGranularity: 0.1 * scale,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  void _showCardDetails(BuildContext context, Card card, double scale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final nameSize = 20 * scale;
        final statSize = 14 * scale;
        final descSize = 14 * scale;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.name,
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'ATK: ${card.attack}   DEF: ${card.defense}   HEAL: ${card.heal}',
                style: TextStyle(fontSize: statSize, color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                card.description ?? 'No special effect.',
                style: TextStyle(fontSize: descSize, color: Colors.white),
              ),
            ],
          ),
        );
      },
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

// game_board.dart
import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';
import '../../game_logic/enums/lane_column.dart';
import 'lane_column_widget.dart';

class GameBoard extends StatelessWidget {
  final GameEngine engine;
  final double scale;

  final String localPlayerId;

  const GameBoard({
    super.key,
    required this.engine,
    required this.scale,
    this.localPlayerId = 'player1',
  });

  @override
  Widget build(BuildContext context) {
    final player = engine.getPlayer(localPlayerId);
    final opponent = engine.getPlayer(
      localPlayerId == 'player1' ? 'player2' : 'player1',
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: Lane.values
            .map(
              (lane) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                child: LaneColumnWidget(
                  lane: lane,
                  player: player,
                  opponent: opponent,
                  engine: engine,
                  scale: scale,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

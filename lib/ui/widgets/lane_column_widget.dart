// lane_column_widget.dart
import 'package:flutter/material.dart';
import '../../game_logic/game_engine.dart';
import '../../game_logic/models/player_state.dart';
import '../../game_logic/enums/lane_column.dart';
import 'field_slot.dart';

class LaneColumnWidget extends StatelessWidget {
  final Lane lane;
  final PlayerState player;
  final PlayerState opponent;
  final GameEngine engine;
  final double scale;

  const LaneColumnWidget({
    super.key,
    required this.lane,
    required this.player,
    required this.opponent,
    required this.engine,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Opponent slot (top)
        FieldSlot(
          player: opponent,
          engine: engine,
          lane: lane,
          scale: scale,
          isOpponent: true,
        ),
        SizedBox(height: 8 * scale),
        Text(
          lane.name.toUpperCase(),
          style: TextStyle(color: Colors.white38, fontSize: 12 * scale),
        ),
        SizedBox(height: 8 * scale),
        // Player slot (bottom)
        FieldSlot(
          player: player,
          engine: engine,
          lane: lane,
          scale: scale,
          isOpponent: false,
        ),
      ],
    );
  }
}

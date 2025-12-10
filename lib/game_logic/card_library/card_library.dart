import 'package:flutter/foundation.dart';

import '../models/card.dart';
import '../enums/card_type.dart';

class CardBlueprint {
  /// Logical ID used inside code / deck building (e.g. "fireball").
  final String key;

  final String name;
  final CardType type;

  final int attack;
  final int defense;
  final int heal;

  final String? effectKey;
  final String? description;

  const CardBlueprint({
    required this.key,
    required this.name,
    required this.type,
    this.attack = 0,
    this.defense = 0,
    this.heal = 0,
    this.effectKey,
    this.description,
  });

  /// Turn this blueprint into a concrete Card with a unique runtime id.
 Card toCard(String id) {
    return Card(
      id: id,
      type: type,
     name: name,
      attack: attack,
      defense: defense,
      heal: heal,
      effectKey: effectKey,
      //description: description,
    );
  }
}

class CardLibrary {
  /// All card designs in the game.
  static const List<CardBlueprint> all = [
    CardBlueprint(
      key: 'quick_strike',
      name: 'Quick Strike',
      type: CardType.damage,
      attack: 3,
      description: 'Simple 3 damage attacker.',
    ),
    CardBlueprint(
      key: 'heavy_strike',
      name: 'Heavy Strike',
      type: CardType.damage,
      attack: 5,
      defense: 1,
      description: 'Strong hit with a bit of armor.',
    ),
    CardBlueprint(
      key: 'guardian',
      name: 'Guardian',
      type: CardType.shield,
      attack: 2,
      defense: 7,
      description: 'Tanky unit with 2 ATK and 7 DEF.',
    ),
    CardBlueprint(
      key: 'shield_wall',
      name: 'Shield Wall',
      type: CardType.shield,
      attack: 0,
      defense: 9,
      description: 'Pure defense, no attack.',
    ),
    CardBlueprint(
      key: 'healer',
      name: 'Healer',
      type: CardType.heal,
      heal: 3,
      description: 'Heals your hero by 3.',
    ),
    CardBlueprint(
      key: 'battle_priest',
      name: 'Battle Priest',
      type: CardType.heal,
      attack: 1,
      heal: 2,
      description: 'Heals 2, deals 1 damage.',
    ),

    // --- Hybrid stat cards (no special effect) ---
    CardBlueprint(
      key: 'paladin',
      name: 'Paladin',
      type: CardType.shield,
      attack: 2,
      defense: 5,
      heal: 1,
      description: 'A balanced fighter with 2 ATK, 5 DEF, 1 HEAL.',
    ),
    CardBlueprint(
      key: 'berserker',
      name: 'Berserker',
      type: CardType.damage,
      attack: 4,
      defense: 2,
      description: 'High damage, low defense.',
    ),

    // --- Cards with resolve-only effects ---

    // 1. Fireball – direct damage to enemy hero
    CardBlueprint(
      key: 'fireball',
      name: 'Fireball',
      type: CardType.damage,
      attack: 0,
      description: 'On resolve: deal 3 damage to the enemy hero.',
      effectKey: 'fireball',
    ),

    // 2. War Banner – buffs adjacent allies
    CardBlueprint(
      key: 'war_banner',
      name: 'War Banner',
      type: CardType.shield,
      defense: 2,
      description: 'On resolve: adjacent allies gain +1 ATK.',
      effectKey: 'war_banner',
    ),

    // 3. Assassin – removes the opposing card in this lane
    CardBlueprint(
      key: 'assassin',
      name: 'Assassin',
      type: CardType.damage,
      attack: 2,
      description: 'On resolve: destroy enemy card in this lane.',
      effectKey: 'assassin',
    ),

    // 4. Battle Medic – heals more if uncontested
    CardBlueprint(
      key: 'battle_medic',
      name: 'Battle Medic',
      type: CardType.heal,
      heal: 2,
      description: 'On resolve: heal 4 instead if lane is empty.',
      effectKey: 'battle_medic',
    ),

    // 5. Lifesteal Blade – converts its attack into self-heal
    CardBlueprint(
      key: 'lifesteal_blade',
      name: 'Lifesteal Blade',
      type: CardType.damage,
      attack: 2,
      description: 'On resolve: heal your hero equal to this card’s ATK.',
      effectKey: 'lifesteal_blade',
    ),

    // 6. Rallying Cry – global attack buff
    CardBlueprint(
      key: 'rallying_cry',
      name: 'Rallying Cry',
      type: CardType.damage,
      attack: 1,
      description: 'On resolve: all your other cards gain +1 ATK this round.',
      effectKey: 'rallying_cry',
    ),

    // 7. Armor Breaker – enemy card in this lane has 0 DEF
    CardBlueprint(
      key: 'armor_breaker',
      name: 'Armor Breaker',
      type: CardType.damage,
      attack: 3,
      description: 'On resolve: enemy card here has 0 DEF this round.',
      effectKey: 'armor_breaker',
    ),

    // 8. Healing Seal – negate all healing this lane
    CardBlueprint(
      key: 'healing_seal',
      name: 'Healing Seal',
      type: CardType.damage,
      attack: 1,
      description: 'On resolve: both cards in this lane have HEAL set to 0.',
      effectKey: 'nullify_heal',
    ),

    // 9. Chain Lightning – damage enemy hero and card
    CardBlueprint(
      key: 'chain_lightning',
      name: 'Chain Lightning',
      type: CardType.damage,
      attack: 1,
      description:
          'On resolve: deal 1 to hero and 2 to enemy card in this lane.',
      effectKey: 'chain_lightning',
    ),

    // 10. Fortify – buff this card and its neighbors own DEF before combat
    CardBlueprint(
      key: 'fortify',
      name: 'Fortify',
      type: CardType.shield,
      defense: 4,
      description:
          'On resolve: this card and its neighbors gains +3 DEF before combat.',
      effectKey: 'fortify',
    ),

    // 1) Overcharger – turns its healing into extra attack
    CardBlueprint(
      key: 'overcharger',
      name: 'Overcharger',
      type: CardType.damage,
      attack: 1,
      defense: 2,
      heal: 2,
      description: 'On resolve: add 2 ATK for every HEAL point',
      effectKey: 'overcharge',
    ),

    // 2) Thorned Guardian – hits the enemy hero if it’s fighting
    CardBlueprint(
      key: 'thorned_guardian',
      name: 'Thorned Guardian',
      type: CardType.shield,
      attack: 1,
      defense: 6,
      description: 'On resolve: if contested, deal 2 damage to enemy hero.',
      effectKey: 'thorns',
    ),

    // 3) Holy Beacon – bigger heal if you have allies on board
    CardBlueprint(
      key: 'holy_beacon',
      name: 'Holy Beacon',
      type: CardType.heal,
      attack: 0,
      defense: 2,
      heal: 2,
      description:
          'On resolve: heal +2 more if you control 2+ cards on the field.',
      effectKey: 'holy_beacon',
    ),

    // 4) Storm Archer – ping enemy hero for each enemy in adjacent lanes
    CardBlueprint(
      key: 'storm_archer',
      name: 'Storm Archer',
      type: CardType.damage,
      attack: 2,
      defense: 2,
      description: 'On resolve: deal 1 damage per enemy in adjacent lanes.',
      effectKey: 'storm_archer',
    ),

    // 5) Shield Channeler – gives extra DEF to all other allies
    CardBlueprint(
      key: 'shield_channeler',
      name: 'Shield Channeler',
      type: CardType.shield,
      attack: 0,
      defense: 3,
      heal: 1,
      description: 'On resolve: other allied cards gain +2 DEF.',
      effectKey: 'shield_channeler',
    ),

    // 6) Blood Pact – hurts you but powers itself up
    CardBlueprint(
      key: 'blood_pact',
      name: 'Blood Pact',
      type: CardType.damage,
      attack: 3,
      defense: 1,
      description: 'On resolve: your hero takes 2 damage; this gains +2 ATK.',
      effectKey: 'blood_pact',
    ),
  ];

  static CardBlueprint byKey(String key) {
    for (final bp in all) {
      if (bp.key == key) return bp;
    }

    debugPrint('CardLibrary key not found: "$key"');
    throw ArgumentError('Unknown card blueprint key: $key');
  }
}

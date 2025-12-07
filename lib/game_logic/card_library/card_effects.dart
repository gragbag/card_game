// lib/game_logic/services/card_effects.dart
import 'dart:math';

import '../models/card.dart';
import '../models/player_state.dart';
import '../models/game_state.dart';
import '../enums/lane_column.dart';

class CardEffectContext {
  final GameState game;
  final PlayerState owner;
  final PlayerState opponent;
  final Lane lane;
  final Card card;

  CardEffectContext({
    required this.game,
    required this.owner,
    required this.opponent,
    required this.lane,
    required this.card,
  });

  // --- Convenience helpers ---

  void damagePlayer(PlayerState target, int amount) {
    target.health = max(0, target.health - amount);
  }

  void healPlayer(PlayerState target, int amount) {
    target.health = min(target.maxHealth, target.health + amount);
  }

  Card? allyIn(Lane l) => owner.field.cardInLane(l);
  Card? enemyIn(Lane l) => opponent.field.cardInLane(l);

  void destroyEnemyIn(Lane l) {
    final c = opponent.field.cardInLane(l);
    if (c != null) {
      opponent.discardPile.add(c);
      opponent.field.setCardInLane(l, null);
    }
  }

  void buffAllyIn(Lane l, {int atk = 0, int def = 0}) {
    final c = owner.field.cardInLane(l);
    if (c == null) return;
    c.attack += atk;
    c.defense += def;
  }

  Iterable<Lane> allLanes() => Lane.values;
}

typedef CardEffectFn = void Function(CardEffectContext ctx);

class CardEffects {
  // Registry of all effects keyed by card.effectKey
  static final Map<String, CardEffectFn> _effects = {
    // --- EXAMPLES ---

    // Deal 3 direct damage to enemy hero
    'fireball': (ctx) {
      ctx.damagePlayer(ctx.opponent, 3);
    },

    // Buff adjacent allies right before combat
    'war_banner': (ctx) {
      if (ctx.lane == Lane.center) {
        ctx.buffAllyIn(Lane.left, atk: 1);
        ctx.buffAllyIn(Lane.right, atk: 1);
      } else if (ctx.lane == Lane.left) {
        ctx.buffAllyIn(Lane.center, atk: 1);
      } else if (ctx.lane == Lane.right) {
        ctx.buffAllyIn(Lane.center, atk: 1);
      }
    },

    // Destroy enemy in same lane during resolve
    'assassin': (ctx) {
      ctx.destroyEnemyIn(ctx.lane);
    },

    // lifesteal_blade: turn its attack into hero-heal (lifesteal feel)
    'lifesteal_blade': (ctx) {
      if (ctx.card.attack > 0) {
        ctx.healPlayer(ctx.owner, ctx.card.attack);
      }
      // optional: leave attack as-is so it still deals lane damage
    },

    // rallying_cry: buff all other allies' attack
    'rallying_cry': (ctx) {
      for (final lane in Lane.values) {
        final ally = ctx.allyIn(lane);
        if (ally == null) continue;
        if (identical(ally, ctx.card)) continue; // skip self
        ally.attack += 1;
      }
    },

    // armor_breaker: enemy card in this lane has 0 DEF this round
    'armor_breaker': (ctx) {
      final enemy = ctx.enemyIn(ctx.lane);
      if (enemy != null) {
        enemy.defense = 0;
      }
    },

    // chain_lightning: damage hero and enemy card
    'chain_lightning': (ctx) {
      ctx.damagePlayer(ctx.opponent, 1);
      final enemy = ctx.enemyIn(ctx.lane);
      if (enemy != null) {
        // "2 damage to enemy card" -> reduce its defense as a simple model
        enemy.defense = max(0, enemy.defense - 2);
      }
    },

    // fortify: buff self and neighbors defense
    'fortify': (ctx) {
      ctx.card.defense += 3;
      if (ctx.lane == Lane.center) {
        ctx.buffAllyIn(Lane.left, def: 3);
        ctx.buffAllyIn(Lane.right, def: 3);
      } else if (ctx.lane == Lane.left) {
        ctx.buffAllyIn(Lane.center, def: 3);
      } else if (ctx.lane == Lane.right) {
        ctx.buffAllyIn(Lane.center, def: 3);
      }
    },

    // nullify_heal: both cards in this lane lose their HEAL this round
    'nullify_heal': (ctx) {
      final ally = ctx.allyIn(ctx.lane);
      final enemy = ctx.enemyIn(ctx.lane);
      if (ally != null) ally.heal = 0;
      if (enemy != null) enemy.heal = 0;
    },

    // “Negate healing” example: convert this card’s heal into damage instead
    'anti_heal_strike': (ctx) {
      // interpret this card's heal as damage instead
      if (ctx.card.heal > 0) {
        ctx.damagePlayer(ctx.opponent, ctx.card.heal);
        ctx.card.heal = 0; // so normal heal logic won't also fire
      }
    },

    // overcharge: convert heal into extra attack
    'overcharge': (ctx) {
      if (ctx.card.heal > 0) {
        ctx.card.attack += (ctx.card.heal * 2);
        ctx.card.heal = 0;
      }
    },

    // thorns: if fighting an enemy, ping enemy hero
    'thorns': (ctx) {
      final enemy = ctx.enemyIn(ctx.lane);
      if (enemy != null) {
        ctx.damagePlayer(ctx.opponent, 2);
      }
    },

    // holy_beacon: if you control 2+ cards on the field, boost this heal
    'holy_beacon': (ctx) {
      int allyCount = 0;
      for (final lane in ctx.allLanes()) {
        if (ctx.allyIn(lane) != null) allyCount++;
      }
      if (allyCount >= 2) {
        ctx.card.heal += 2; // base 2 => now 4
      }
    },

    // storm_archer: deal 1 damage to enemy hero per enemy in adjacent lanes
    'storm_archer': (ctx) {
      int bonusDamage = 0;

      Lane? leftOf(Lane l) {
        switch (l) {
          case Lane.left:
            return null;
          case Lane.center:
            return Lane.left;
          case Lane.right:
            return Lane.center;
        }
      }

      Lane? rightOf(Lane l) {
        switch (l) {
          case Lane.left:
            return Lane.center;
          case Lane.center:
            return Lane.right;
          case Lane.right:
            return null;
        }
      }

      final leftLane = leftOf(ctx.lane);
      final rightLane = rightOf(ctx.lane);

      if (leftLane != null && ctx.enemyIn(leftLane) != null) bonusDamage++;
      if (rightLane != null && ctx.enemyIn(rightLane) != null) bonusDamage++;

      if (bonusDamage > 0) {
        ctx.damagePlayer(ctx.opponent, bonusDamage);
      }
    },

    // shield_channeler: other allied cards get +2 DEF
    'shield_channeler': (ctx) {
      for (final lane in ctx.allLanes()) {
        final ally = ctx.allyIn(lane);
        if (ally == null) continue;
        if (identical(ally, ctx.card)) continue; // skip self
        ally.defense += 2;
      }
    },

    // blood_pact: hurt your hero, buff this card’s ATK
    'blood_pact': (ctx) {
      ctx.damagePlayer(ctx.owner, 2);
      ctx.card.attack += 2;
    },
  };

  static CardEffectFn? forCard(Card card) {
    final key = card.effectKey;
    if (key == null) return null;
    return _effects[key];
  }
}

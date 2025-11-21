import '../enums/card_type.dart';

class Card {
  final String id;
  final CardType type;
  final int value;
  final String name;

  Card({
    required this.id,
    required this.type,
    required this.value,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'value': value,
    'name': name,
  };

  factory Card.fromJson(Map<String, dynamic> json) => Card(
    id: json['id'],
    type: CardType.values.firstWhere((e) => e.name == json['type']),
    value: json['value'],
    name: json['name'],
  );

  @override
  String toString() => 'Card($name, $type, $value)';
}

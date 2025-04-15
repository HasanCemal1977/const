import 'package:uuid/uuid.dart';

class Group {
  final String id;
  String name;
  String description;
  String disciplineId;
  double quantity;
  String unit;
  double multiplierRate;
  List<String> itemIds;

  Group({
    String? id,
    required this.name,
    this.description = '',
    required this.disciplineId,
    this.quantity = 1.0,
    this.unit = 'pcs',
    this.multiplierRate = 1.0,
    List<String>? itemIds,
  })  : id = id ?? const Uuid().v4(),
        itemIds = itemIds ?? [];

  double get totalCost {
    // In a real app, this would query the items and sum their costs
    return 0.0; // Placeholder
  }

  Group copyWith({
    String? name,
    String? description,
    String? disciplineId,
    double? quantity,
    String? unit,
    double? multiplierRate,
    List<String>? itemIds,
  }) {
    return Group(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      disciplineId: disciplineId ?? this.disciplineId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      multiplierRate: multiplierRate ?? this.multiplierRate,
      itemIds: itemIds ?? this.itemIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'disciplineId': disciplineId,
      'quantity': quantity,
      'unit': unit,
      'multiplierRate': multiplierRate,
      'itemIds': itemIds,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      disciplineId: json['disciplineId'],
      quantity:
          json['quantity'] is num ? (json['quantity'] as num).toDouble() : 1.0,
      unit: json['unit'] ?? 'pcs',
      multiplierRate: json['multiplierRate'] is num
          ? (json['multiplierRate'] as num).toDouble()
          : 1.0,
      itemIds: json['itemIds'] != null
          ? List<String>.from(json['itemIds'])
          : <String>[],
    );
  }
}

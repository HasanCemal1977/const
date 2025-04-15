import 'package:uuid/uuid.dart';

class Discipline {
  final String id;
  String name;
  String description;
  String buildingId;
  double quantity;
  String unit;
  double multiplierRate;
  List<String> groupIds;

  Discipline({
    String? id,
    required this.name,
    this.description = '',
    required this.buildingId,
    this.quantity = 1.0,
    this.unit = 'pcs',
    this.multiplierRate = 1.0,
    List<String>? groupIds,
  })  : id = id ?? const Uuid().v4(),
        groupIds = groupIds ?? [];

  double get totalCost {
    // In a real app, this would query the groups and sum their costs
    return 0.0; // Placeholder
  }

  Discipline copyWith({
    String? name,
    String? description,
    String? buildingId,
    double? quantity,
    String? unit,
    double? multiplierRate,
    List<String>? groupIds,
  }) {
    return Discipline(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      buildingId: buildingId ?? this.buildingId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      multiplierRate: multiplierRate ?? this.multiplierRate,
      groupIds: groupIds ?? this.groupIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'buildingId': buildingId,
      'quantity': quantity,
      'unit': unit,
      'multiplierRate': multiplierRate,
      'groupIds': groupIds,
    };
  }

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      buildingId: json['buildingId'],
      quantity:
          json['quantity'] is num ? (json['quantity'] as num).toDouble() : 1.0,
      unit: json['unit'] ?? 'pcs',
      multiplierRate: json['multiplierRate'] is num
          ? (json['multiplierRate'] as num).toDouble()
          : 1.0,
      groupIds: json['groupIds'] != null
          ? List<String>.from(json['groupIds'])
          : <String>[],
    );
  }
}

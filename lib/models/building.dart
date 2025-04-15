import 'package:uuid/uuid.dart';

class Building {
  final String id;
  String name;
  String description;
  String projectId;
  double quantity;
  String unit;
  double multiplierRate;
  List<String> disciplineIds;

  Building({
    String? id,
    required this.name,
    this.description = '',
    required this.projectId,
    this.quantity = 1.0,
    this.unit = '',
    this.multiplierRate = 1.0,
    List<String>? disciplineIds,
  })  : id = id ?? const Uuid().v4(),
        disciplineIds = disciplineIds ?? [];

  double get totalCost {
    // In a real app, this would query the disciplines and sum their costs
    return 0.0; // Placeholder
  }

  Building copyWith({
    String? name,
    String? description,
    String? projectId,
    double? quantity,
    String? unit,
    double? multiplierRate,
    List<String>? disciplineIds,
  }) {
    return Building(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      multiplierRate: multiplierRate ?? this.multiplierRate,
      disciplineIds: disciplineIds ?? this.disciplineIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'projectId': projectId,
      'quantity': quantity,
      'unit': unit,
      'multiplierRate': multiplierRate,
      'disciplineIds': disciplineIds,
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      projectId: json['projectId'],
      quantity: json['quantity'],
      unit: json['unit'] ?? '',
      multiplierRate: json['multiplierRate'],
      disciplineIds: List<String>.from(json['disciplineIds']),
    );
  }
}

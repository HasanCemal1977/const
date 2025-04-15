import 'package:uuid/uuid.dart';

class AnalysisComponent {
  final String id;
  String parentId; // Can be an Item ID or SubItem ID
  String name;
  String description;
  String
      componentType; // Material, Labour, Equipment, Transportation, Consumable Material, Sub Contractors
  double quantity;
  String unit;
  double unitPrice;
  double mass; // Field for mass
  String origin; // Field for origin
  double manhours; // Field for manhours (only for Labour)

  AnalysisComponent({
    String? id,
    required this.parentId,
    required this.name,
    this.description = '',
    required this.componentType,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.mass = 0.0,
    this.origin = '',
    this.manhours = 0.0,
  }) : id = id ?? const Uuid().v4();

  double get totalCost {
    return quantity * unitPrice;
  }

  AnalysisComponent copyWith({
    String? parentId,
    String? name,
    String? description,
    String? componentType,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? mass,
    String? origin,
    double? manhours,
  }) {
    return AnalysisComponent(
      id: this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      description: description ?? this.description,
      componentType: componentType ?? this.componentType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      mass: mass ?? this.mass,
      origin: origin ?? this.origin,
      manhours: manhours ?? this.manhours,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'name': name,
      'description': description,
      'componentType': componentType,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'mass': mass,
      'origin': origin,
      'manhours': manhours,
    };
  }

  factory AnalysisComponent.fromJson(Map<String, dynamic> json) {
    return AnalysisComponent(
      id: json['id'],
      parentId: json['parentId'],
      name: json['name'],
      description: json['description'] ?? '',
      componentType: json['componentType'] ??
          json['type'] ??
          'Material', // Backward compatibility
      quantity:
          json['quantity'] is num ? (json['quantity'] as num).toDouble() : 1.0,
      unit: json['unit'] ?? 'pcs',
      unitPrice: json['unitPrice'] is num
          ? (json['unitPrice'] as num).toDouble()
          : (json['price'] is num
              ? (json['price'] as num).toDouble()
              : 0.0), // Backward compatibility
      mass: json['mass'] is num ? (json['mass'] as num).toDouble() : 0.0,
      origin: json['origin'] ?? '',
      manhours: json['manhours'] is num
          ? (json['manhours'] as num).toDouble()
          : (json['manhour'] is num
              ? (json['manhour'] as num).toDouble()
              : 0.0), // Backward compatibility
    );
  }
}

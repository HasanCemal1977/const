import 'package:uuid/uuid.dart';

class SubItem {
  final String id;
  String name;
  String description;
  String itemId;
  double quantity;
  String unit;
  double unitPrice;
  double multiplierRate;
  List<String> analysisComponentIds;

  SubItem({
    String? id,
    required this.name,
    this.description = '',
    required this.itemId,
    this.quantity = 1.0,
    this.unit = '',
    this.unitPrice = 0.0,
    this.multiplierRate = 1.0,
    List<String>? analysisComponentIds,
  })  : id = id ?? const Uuid().v4(),
        analysisComponentIds = analysisComponentIds ?? [];

  double get totalCost {
    return quantity * unitPrice * multiplierRate;
  }

  SubItem copyWith({
    String? name,
    String? description,
    String? itemId,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? multiplierRate,
    List<String>? analysisComponentIds,
  }) {
    return SubItem(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      multiplierRate: multiplierRate ?? this.multiplierRate,
      analysisComponentIds: analysisComponentIds ?? this.analysisComponentIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'itemId': itemId,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'multiplierRate': multiplierRate,
      'analysisComponentIds': analysisComponentIds,
    };
  }

  factory SubItem.fromJson(Map<String, dynamic> json) {
    return SubItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      itemId: json['itemId'],
      quantity: json['quantity'],
      unit: json['unit'],
      unitPrice: json['unitPrice'],
      multiplierRate: json['multiplierRate'],
      analysisComponentIds: List<String>.from(json['analysisComponentIds']),
    );
  }
}

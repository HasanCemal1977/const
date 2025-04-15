import 'package:uuid/uuid.dart';

class Item {
  final String id;
  String name;
  String description;
  String groupId;
  double quantity;
  String unit;
  double unitPrice;
  double multiplierRate;
  bool hasSubItems;
  List<String> subItemIds;
  List<String> analysisComponentIds;

  Item({
    String? id,
    required this.name,
    this.description = '',
    required this.groupId,
    this.quantity = 1.0,
    this.unit = '',
    this.unitPrice = 0.0,
    this.multiplierRate = 1.0,
    this.hasSubItems = false,
    List<String>? subItemIds,
    List<String>? analysisComponentIds,
  })  : id = id ?? const Uuid().v4(),
        subItemIds = subItemIds ?? [],
        analysisComponentIds = analysisComponentIds ?? [];

  double get totalCost {
    if (hasSubItems) {
      // In a real app, this would query the sub items and sum their costs
      return 0.0; // Placeholder
    } else {
      return quantity * unitPrice * multiplierRate;
    }
  }

  Item copyWith({
    String? name,
    String? description,
    String? groupId,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? multiplierRate,
    bool? hasSubItems,
    List<String>? subItemIds,
    List<String>? analysisComponentIds,
  }) {
    return Item(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      groupId: groupId ?? this.groupId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      multiplierRate: multiplierRate ?? this.multiplierRate,
      hasSubItems: hasSubItems ?? this.hasSubItems,
      subItemIds: subItemIds ?? this.subItemIds,
      analysisComponentIds: analysisComponentIds ?? this.analysisComponentIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'groupId': groupId,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'multiplierRate': multiplierRate,
      'hasSubItems': hasSubItems,
      'subItemIds': subItemIds,
      'analysisComponentIds': analysisComponentIds,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      groupId: json['groupId'],
      quantity: json['quantity'],
      unit: json['unit'],
      unitPrice: json['unitPrice'],
      multiplierRate: json['multiplierRate'],
      hasSubItems: json['hasSubItems'],
      subItemIds: List<String>.from(json['subItemIds']),
      analysisComponentIds: List<String>.from(json['analysisComponentIds']),
    );
  }
}

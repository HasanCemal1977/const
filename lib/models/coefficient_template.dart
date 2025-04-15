import 'package:uuid/uuid.dart';

class CoefficientTemplate {
  final String id;
  String name;
  String description;
  double materialCoefficient;
  double labourCoefficient;
  double equipmentCoefficient;
  double transportationCoefficient;
  double consumableMaterialCoefficient;
  double subContractorsCoefficient;

  CoefficientTemplate({
    String? id,
    required this.name,
    this.description = '',
    this.materialCoefficient = 1.0,
    this.labourCoefficient = 1.0,
    this.equipmentCoefficient = 1.0,
    this.transportationCoefficient = 1.0,
    this.consumableMaterialCoefficient = 1.0,
    this.subContractorsCoefficient = 1.0,
  }) : id = id ?? const Uuid().v4();

  double getCoefficientForType(String componentType) {
    switch (componentType.toLowerCase()) {
      case 'material':
        return materialCoefficient;
      case 'labour':
        return labourCoefficient;
      case 'equipment':
        return equipmentCoefficient;
      case 'transportation':
        return transportationCoefficient;
      case 'consumable material':
        return consumableMaterialCoefficient;
      case 'sub contractors':
        return subContractorsCoefficient;
      default:
        return 1.0;
    }
  }

  CoefficientTemplate copyWith({
    String? name,
    String? description,
    double? materialCoefficient,
    double? labourCoefficient,
    double? equipmentCoefficient,
    double? transportationCoefficient,
    double? consumableMaterialCoefficient,
    double? subContractorsCoefficient,
  }) {
    return CoefficientTemplate(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      materialCoefficient: materialCoefficient ?? this.materialCoefficient,
      labourCoefficient: labourCoefficient ?? this.labourCoefficient,
      equipmentCoefficient: equipmentCoefficient ?? this.equipmentCoefficient,
      transportationCoefficient:
          transportationCoefficient ?? this.transportationCoefficient,
      consumableMaterialCoefficient:
          consumableMaterialCoefficient ?? this.consumableMaterialCoefficient,
      subContractorsCoefficient:
          subContractorsCoefficient ?? this.subContractorsCoefficient,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'materialCoefficient': materialCoefficient,
      'labourCoefficient': labourCoefficient,
      'equipmentCoefficient': equipmentCoefficient,
      'transportationCoefficient': transportationCoefficient,
      'consumableMaterialCoefficient': consumableMaterialCoefficient,
      'subContractorsCoefficient': subContractorsCoefficient,
    };
  }

  factory CoefficientTemplate.fromJson(Map<String, dynamic> json) {
    return CoefficientTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      materialCoefficient: json['materialCoefficient'] is num
          ? (json['materialCoefficient'] as num).toDouble()
          : 1.0,
      labourCoefficient: json['labourCoefficient'] is num
          ? (json['labourCoefficient'] as num).toDouble()
          : 1.0,
      equipmentCoefficient: json['equipmentCoefficient'] is num
          ? (json['equipmentCoefficient'] as num).toDouble()
          : 1.0,
      transportationCoefficient: json['transportationCoefficient'] is num
          ? (json['transportationCoefficient'] as num).toDouble()
          : 1.0,
      consumableMaterialCoefficient:
          json['consumableMaterialCoefficient'] is num
              ? (json['consumableMaterialCoefficient'] as num).toDouble()
              : 1.0,
      subContractorsCoefficient: json['subContractorsCoefficient'] is num
          ? (json['subContractorsCoefficient'] as num).toDouble()
          : 1.0,
    );
  }
}

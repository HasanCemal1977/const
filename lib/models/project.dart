import 'package:uuid/uuid.dart';

class Project {
  final String id;
  String name;
  String description;
  String location;
  String client;
  String contractor;
  DateTime startDate;
  DateTime? endDate;
  String status;
  double quantity;
  double multiplierRate;
  List<String> buildingIds;

  Project({
    String? id,
    required this.name,
    this.description = '',
    this.location = '',
    this.client = '',
    this.contractor = '',
    required this.startDate,
    this.endDate,
    this.status = 'Planning',
    this.quantity = 1.0,
    this.multiplierRate = 1.0,
    List<String>? buildingIds,
  })  : id = id ?? const Uuid().v4(),
        buildingIds = buildingIds ?? [];

  double get totalCost {
    // This would be calculated based on all buildings in this project
    // In a real app, this would query the buildings and sum their costs
    return 0.0; // Placeholder
  }

  Project copyWith({
    String? name,
    String? description,
    String? location,
    String? client,
    String? contractor,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? quantity,
    double? multiplierRate,
    List<String>? buildingIds,
  }) {
    return Project(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      client: client ?? this.client,
      contractor: contractor ?? this.contractor,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      multiplierRate: multiplierRate ?? this.multiplierRate,
      buildingIds: buildingIds ?? this.buildingIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'client': client,
      'contractor': contractor,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'quantity': quantity,
      'multiplierRate': multiplierRate,
      'buildingIds': buildingIds,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      client: json['client'],
      contractor: json['contractor'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'],
      quantity: json['quantity'],
      multiplierRate: json['multiplierRate'],
      buildingIds: List<String>.from(json['buildingIds']),
    );
  }
}

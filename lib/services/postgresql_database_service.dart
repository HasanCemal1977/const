import 'dart:convert';
import 'package:construction_cost_analysis/models/coefficient_template.dart';
import 'package:construction_cost_analysis/services/web_stub.dart';
import 'package:flutter/foundation.dart';

// Conditional imports
import 'package:postgres/postgres.dart' if (dart.library.html) 'web_stub.dart';
import 'dart:io' if (dart.library.html) 'web_stub.dart';

import '../models/project.dart';
import '../models/building.dart';
import '../models/discipline.dart';
import '../models/group.dart';
import '../models/item.dart';
import '../models/sub_item.dart';
import '../models/analysis_component.dart';
import 'database_service.dart';

// Use composition instead of inheritance to avoid constructor issues
class PostgreSQLDatabaseService implements DatabaseService {
  PostgreSQLConnection? _connection;
  final DatabaseService _dbService = DatabaseService();

  static final PostgreSQLDatabaseService _instance =
      PostgreSQLDatabaseService._internal();
  factory PostgreSQLDatabaseService() => _instance;

  PostgreSQLDatabaseService._internal();

  Map<String, dynamic> _resultRowToMap(dynamic results, int rowIndex) {
    // For empty results
    if (results == null ||
        (results is List && results.isEmpty) ||
        (results is PostgreSQLResult && results.isEmpty)) {
      return {};
    }

    final Map<String, dynamic> map = {};

    // For web compatibility
    if (kIsWeb) {
      List<String> columns;
      List<dynamic> row;

      if (results is PostgreSQLResult) {
        // Get columns from result object on Web
        columns = List.generate(results.columnDescriptions.length,
            (i) => results.columnDescriptions[i].columnName);

        // Create row data
        if (rowIndex < results.length) {
          row = List.generate(
              results[rowIndex]._values.length, (i) => results[rowIndex][i]);
        } else {
          return {};
        }
      } else if (results is List<List<dynamic>>) {
        // For legacy code/tests that might pass raw lists
        columns = _getColumnsForTable(results);
        row = rowIndex < results.length ? results[rowIndex] : [];
      } else {
        // Unknown type
        print('Unexpected results type: ${results.runtimeType}');
        return {};
      }

      // Map the values
      for (int i = 0; i < columns.length && i < row.length; i++) {
        map[columns[i]] = row[i];
      }
    } else {
      try {
        // For native platforms
        if (results is PostgreSQLResult) {
          // Use PostgreSQL result methods directly
          if (rowIndex < results.length) {
            final row = results[rowIndex];
            for (int i = 0; i < results.columnDescriptions.length; i++) {
              map[results.columnDescriptions[i].columnName] = row[i];
            }
          }
        } else if (results is List<List<dynamic>>) {
          // Fallback for raw lists - shouldn't typically reach here in production
          print('Warning: Received raw List<List> instead of PostgreSQLResult');
          final columns = _getColumnsForTable(results);
          final row = rowIndex < results.length ? results[rowIndex] : [];
          for (int i = 0; i < columns.length && i < row.length; i++) {
            map[columns[i]] = row[i];
          }
        }
      } catch (e) {
        print('Error converting result row to map: $e');
      }
    }

    return map;
  }

  // Get columns for a table based on the query results and table name
  List<String> _getColumnsForTable(List<List<dynamic>> results) {
    // This is a simplification - in production you'd want this to be more dynamic
    // based on the actual query or table being accessed
    if (results.isEmpty) return [];

    // Detect which table this might be based on the number of columns
    final columnCount = results.first.length;

    switch (columnCount) {
      case 10:
        return [
          'id',
          'name',
          'description',
          'location',
          'client',
          'contractor',
          'start_date',
          'end_date',
          'status',
          'building_ids'
        ];
      case 8:
        return [
          'id',
          'project_id',
          'name',
          'description',
          'quantity',
          'unit',
          'multiplier_rate',
          'discipline_ids'
        ];
      case 8:
        return [
          'id',
          'building_id',
          'name',
          'description',
          'quantity',
          'unit',
          'multiplier_rate',
          'group_ids'
        ];
      case 8:
        return [
          'id',
          'discipline_id',
          'name',
          'description',
          'quantity',
          'unit',
          'multiplier_rate',
          'item_ids'
        ];
      case 11:
        return [
          'id',
          'group_id',
          'name',
          'description',
          'quantity',
          'unit',
          'unit_price',
          'multiplier_rate',
          'has_sub_items',
          'sub_item_ids',
          'analysis_component_ids'
        ];
      case 9:
        return [
          'id',
          'item_id',
          'name',
          'description',
          'quantity',
          'unit',
          'unit_price',
          'multiplier_rate',
          'analysis_component_ids'
        ];
      case 10:
        return [
          'id',
          'parent_id',
          'name',
          'description',
          'component_type',
          'quantity',
          'unit',
          'unit_price',
          'mass',
          'origin',
          'manhours'
        ];
      default:
        return [];
    }
  }

  // Initialize connection
  Future<void> initialize() async {
    if (kIsWeb) return;

    if (_connection != null) return;

    try {
      final host = Platform.environment['PGHOST'] ?? 'localhost';
      final port = int.parse(Platform.environment['PGPORT'] ?? '5432');
      final database = Platform.environment['PGDATABASE'] ?? 'postgres';
      final username = Platform.environment['PGUSER'] ?? 'postgres';
      final password = Platform.environment['PGPASSWORD'] ?? 'postgres';

      _connection = PostgreSQLConnection(host, port, database,
          username: username, password: password);
      await _connection!.open();
      await _createTablesIfNotExist();
    } catch (e) {
      print('Error connecting to PostgreSQL: $e');
      rethrow;
    }
  }

  Future<void> _createTablesIfNotExist() async {
    try {
      // Create Projects table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS projects (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          location TEXT,
          client TEXT,
          contractor TEXT,
          start_date TIMESTAMP,
          end_date TIMESTAMP,
          status TEXT,
          building_ids TEXT[]
        )
      ''');

      // Create Buildings table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS buildings (
          id TEXT PRIMARY KEY,
          project_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          quantity DOUBLE PRECISION,
          unit TEXT,
          multiplier_rate DOUBLE PRECISION,
          discipline_ids TEXT[]
        )
      ''');

      // Create Disciplines table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS disciplines (
          id TEXT PRIMARY KEY,
          building_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          quantity DOUBLE PRECISION,
          unit TEXT,
          multiplier_rate DOUBLE PRECISION,
          group_ids TEXT[]
        )
      ''');

      // Create Groups table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS groups (
          id TEXT PRIMARY KEY,
          discipline_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          quantity DOUBLE PRECISION,
          unit TEXT,
          multiplier_rate DOUBLE PRECISION,
          item_ids TEXT[]
        )
      ''');

      // Create Items table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS items (
          id TEXT PRIMARY KEY,
          group_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          quantity DOUBLE PRECISION,
          unit TEXT,
          unit_price DOUBLE PRECISION,
          multiplier_rate DOUBLE PRECISION,
          has_sub_items BOOLEAN,
          sub_item_ids TEXT[],
          analysis_component_ids TEXT[]
        )
      ''');

      // Create SubItems table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS sub_items (
          id TEXT PRIMARY KEY,
          item_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          quantity DOUBLE PRECISION,
          unit TEXT,
          unit_price DOUBLE PRECISION,
          multiplier_rate DOUBLE PRECISION,
          analysis_component_ids TEXT[]
        )
      ''');

      // Create AnalysisComponents table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS analysis_components (
          id TEXT PRIMARY KEY,
          parent_id TEXT NOT NULL,
          name TEXT NOT NULL,
          component_type TEXT,
          unit TEXT,
          quantity DOUBLE PRECISION,
          unit_price DOUBLE PRECISION,
          mass DOUBLE PRECISION,
          origin TEXT,
          manhours DOUBLE PRECISION
        )
      ''');

      print('Database tables created successfully');
    } catch (e) {
      print('Error creating tables: $e');
      rethrow;
    }
  }

  // Project Methods
  @override
  List<Project> getAllProjects() {
    return _dbService.getAllProjects();
  }

  @override
  Future<List<Project>> getAllProjectsFromDB() async {
    try {
      await initialize();
      final results = await _connection!.query('SELECT * FROM projects');

      List<Project> projects = [];
      for (int i = 0; i < results.length; i++) {
        final map = _resultRowToMap(results, i);
        projects.add(Project.fromJson(_convertColumnsToJson(map)));
      }

      return projects;
    } catch (e) {
      print('Error getting all projects: $e');
      return [];
    }
  }

  @override
  Project? getProject(String id) {
    return _dbService.getProject(id);
  }

  @override
  Future<Project?> getProjectFromDB(String id) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM projects WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (results.isEmpty) {
        return null;
      }

      final map = _resultRowToMap(results, 0);

      return Project.fromJson(_convertColumnsToJson(map));
    } catch (e) {
      print('Error getting project: $e');
      return null;
    }
  }

  @override
  Future<void> saveProject(Project project) async {
    try {
      await initialize();
      await _connection!.execute('''
        INSERT INTO projects (
          id, name, description, location, client, contractor, 
          start_date, end_date, status, building_ids
        ) VALUES (
          @id, @name, @description, @location, @client, @contractor, 
          @startDate, @endDate, @status, @buildingIds
        )
        ON CONFLICT (id) DO UPDATE SET
          name = @name,
          description = @description,
          location = @location,
          client = @client,
          contractor = @contractor,
          start_date = @startDate,
          end_date = @endDate,
          status = @status,
          building_ids = @buildingIds
      ''', substitutionValues: {
        'id': project.id,
        'name': project.name,
        'description': project.description,
        'location': project.location,
        'client': project.client,
        'contractor': project.contractor,
        'startDate': project.startDate,
        'endDate': project.endDate,
        'status': project.status,
        'buildingIds': project.buildingIds,
      });

      // Save to in-memory cache as well
      await _dbService.saveProject(project);
    } catch (e) {
      print('Error saving project: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await initialize();

      // Delete all related buildings
      final buildings = await getBuildingsForProjectFromDB(id);
      for (final building in buildings) {
        await deleteBuilding(building.id);
      }

      // Delete the project
      await _connection!.execute(
        'DELETE FROM projects WHERE id = @id',
        substitutionValues: {'id': id},
      );

      // Delete from in-memory cache
      await _dbService.deleteProject(id);
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }

  // Building Methods
  @override
  List<Building> getBuildingsForProject(String projectId) {
    return _dbService.getBuildingsForProject(projectId);
  }

  @override
  Future<List<Building>> getBuildingsForProjectFromDB(String projectId) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM buildings WHERE project_id = @projectId',
        substitutionValues: {'projectId': projectId},
      );

      List<Building> buildings = [];
      for (int i = 0; i < results.length; i++) {
        final map = _resultRowToMap(results, i);
        buildings.add(Building.fromJson(_convertColumnsToJson(map)));
      }

      return buildings;
    } catch (e) {
      print('Error getting buildings: $e');
      return [];
    }
  }

  @override
  Building? getBuilding(String id) {
    return _dbService.getBuilding(id);
  }

  @override
  Future<Building?> getBuildingFromDB(String id) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM buildings WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (results.isEmpty) {
        return null;
      }

      final map = _resultRowToMap(results, 0);

      return Building.fromJson(_convertColumnsToJson(map));
    } catch (e) {
      print('Error getting building: $e');
      return null;
    }
  }

  @override
  Future<void> saveBuilding(Building building) async {
    try {
      await initialize();
      await _connection!.execute('''
        INSERT INTO buildings (
          id, project_id, name, description, quantity, unit, multiplier_rate, discipline_ids
        ) VALUES (
          @id, @projectId, @name, @description, @quantity, @unit, @multiplierRate, @disciplineIds
        )
        ON CONFLICT (id) DO UPDATE SET
          project_id = @projectId,
          name = @name,
          description = @description,
          quantity = @quantity,
          unit = @unit,
          multiplier_rate = @multiplierRate,
          discipline_ids = @disciplineIds
      ''', substitutionValues: {
        'id': building.id,
        'projectId': building.projectId,
        'name': building.name,
        'description': building.description,
        'quantity': building.quantity,
        'unit': building.unit,
        'multiplierRate': building.multiplierRate,
        'disciplineIds': building.disciplineIds,
      });

      // Save to in-memory cache
      await _dbService.saveBuilding(building);
    } catch (e) {
      print('Error saving building: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBuilding(String id) async {
    try {
      await initialize();

      // Delete all related disciplines
      final disciplines = await getDisciplinesForBuildingFromDB(id);
      for (final discipline in disciplines) {
        await deleteDiscipline(discipline.id);
      }

      // Delete the building
      await _connection!.execute(
        'DELETE FROM buildings WHERE id = @id',
        substitutionValues: {'id': id},
      );

      // Delete from in-memory cache
      await _dbService.deleteBuilding(id);
    } catch (e) {
      print('Error deleting building: $e');
      rethrow;
    }
  }

  // Discipline Methods
  @override
  List<Discipline> getDisciplinesForBuilding(String buildingId) {
    return _dbService.getDisciplinesForBuilding(buildingId);
  }

  @override
  Future<List<Discipline>> getDisciplinesForBuildingFromDB(
      String buildingId) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM disciplines WHERE building_id = @buildingId',
        substitutionValues: {'buildingId': buildingId},
      );

      List<Discipline> disciplines = [];
      for (int i = 0; i < results.length; i++) {
        final map = _resultRowToMap(results, i);
        disciplines.add(Discipline.fromJson(_convertColumnsToJson(map)));
      }

      return disciplines;
    } catch (e) {
      print('Error getting disciplines: $e');
      return [];
    }
  }

  @override
  Discipline? getDiscipline(String id) {
    return _dbService.getDiscipline(id);
  }

  @override
  Future<Discipline?> getDisciplineFromDB(String id) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM disciplines WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (results.isEmpty) {
        return null;
      }

      final map = _resultRowToMap(results, 0);

      return Discipline.fromJson(_convertColumnsToJson(map));
    } catch (e) {
      print('Error getting discipline: $e');
      return null;
    }
  }

  @override
  Future<void> saveDiscipline(Discipline discipline) async {
    try {
      await initialize();
      await _connection!.execute('''
        INSERT INTO disciplines (
          id, building_id, name, description, quantity, unit, multiplier_rate, group_ids
        ) VALUES (
          @id, @buildingId, @name, @description, @quantity, @unit, @multiplierRate, @groupIds
        )
        ON CONFLICT (id) DO UPDATE SET
          building_id = @buildingId,
          name = @name,
          description = @description,
          quantity = @quantity,
          unit = @unit,
          multiplier_rate = @multiplierRate,
          group_ids = @groupIds
      ''', substitutionValues: {
        'id': discipline.id,
        'buildingId': discipline.buildingId,
        'name': discipline.name,
        'description': discipline.description,
        'quantity': discipline.quantity,
        'unit': discipline.unit,
        'multiplierRate': discipline.multiplierRate,
        'groupIds': discipline.groupIds,
      });

      // Save to in-memory cache
      await _dbService.saveDiscipline(discipline);
    } catch (e) {
      print('Error saving discipline: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteDiscipline(String id) async {
    try {
      await initialize();

      // Delete all related groups
      final groups = await getGroupsForDisciplineFromDB(id);
      for (final group in groups) {
        await deleteGroup(group.id);
      }

      // Delete the discipline
      await _connection!.execute(
        'DELETE FROM disciplines WHERE id = @id',
        substitutionValues: {'id': id},
      );

      // Delete from in-memory cache
      await _dbService.deleteDiscipline(id);
    } catch (e) {
      print('Error deleting discipline: $e');
      rethrow;
    }
  }

  // Group Methods
  @override
  List<Group> getGroupsForDiscipline(String disciplineId) {
    return _dbService.getGroupsForDiscipline(disciplineId);
  }

  @override
  Future<List<Group>> getGroupsForDisciplineFromDB(String disciplineId) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM groups WHERE discipline_id = @disciplineId',
        substitutionValues: {'disciplineId': disciplineId},
      );

      List<Group> groups = [];
      for (int i = 0; i < results.length; i++) {
        final map = _resultRowToMap(results, i);
        groups.add(Group.fromJson(_convertColumnsToJson(map)));
      }

      return groups;
    } catch (e) {
      print('Error getting groups: $e');
      return [];
    }
  }

  @override
  Group? getGroup(String id) {
    return _dbService.getGroup(id);
  }

  @override
  Future<Group?> getGroupFromDB(String id) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM groups WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (results.isEmpty) {
        return null;
      }

      final map = _resultRowToMap(results, 0);

      return Group.fromJson(_convertColumnsToJson(map));
    } catch (e) {
      print('Error getting group: $e');
      return null;
    }
  }

  @override
  Future<void> saveGroup(Group group) async {
    try {
      await initialize();
      await _connection!.execute('''
        INSERT INTO groups (
          id, discipline_id, name, description, quantity, unit, multiplier_rate, item_ids
        ) VALUES (
          @id, @disciplineId, @name, @description, @quantity, @unit, @multiplierRate, @itemIds
        )
        ON CONFLICT (id) DO UPDATE SET
          discipline_id = @disciplineId,
          name = @name,
          description = @description,
          quantity = @quantity,
          unit = @unit,
          multiplier_rate = @multiplierRate,
          item_ids = @itemIds
      ''', substitutionValues: {
        'id': group.id,
        'disciplineId': group.disciplineId,
        'name': group.name,
        'description': group.description,
        'quantity': group.quantity,
        'unit': group.unit,
        'multiplierRate': group.multiplierRate,
        'itemIds': group.itemIds,
      });

      // Save to in-memory cache
      await _dbService.saveGroup(group);
    } catch (e) {
      print('Error saving group: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    try {
      await initialize();

      // Delete all related items
      final items = await getItemsForGroupFromDB(id);
      for (final item in items) {
        await deleteItem(item.id);
      }

      // Delete the group
      await _connection!.execute(
        'DELETE FROM groups WHERE id = @id',
        substitutionValues: {'id': id},
      );

      // Delete from in-memory cache
      await _dbService.deleteGroup(id);
    } catch (e) {
      print('Error deleting group: $e');
      rethrow;
    }
  }

  // Item Methods
  @override
  List<Item> getItemsForGroup(String groupId) {
    return _dbService.getItemsForGroup(groupId);
  }

  @override
  Future<List<Item>> getItemsForGroupFromDB(String groupId) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM items WHERE group_id = @groupId',
        substitutionValues: {'groupId': groupId},
      );

      List<Item> items = [];
      for (int i = 0; i < results.length; i++) {
        final map = _resultRowToMap(results, i);
        items.add(Item.fromJson(_convertColumnsToJson(map)));
      }

      return items;
    } catch (e) {
      print('Error getting items: $e');
      return [];
    }
  }

  @override
  Item? getItem(String id) {
    return _dbService.getItem(id);
  }

  @override
  Future<Item?> getItemFromDB(String id) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM items WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (results.isEmpty) {
        return null;
      }

      final map = _resultRowToMap(results, 0);

      return Item.fromJson(_convertColumnsToJson(map));
    } catch (e) {
      print('Error getting item: $e');
      return null;
    }
  }

  @override
  Future<void> saveItem(Item item) async {
    try {
      await initialize();
      await _connection!.execute('''
        INSERT INTO items (
          id, group_id, name, description, quantity, unit, unit_price, 
          multiplier_rate, has_sub_items, sub_item_ids, analysis_component_ids
        ) VALUES (
          @id, @groupId, @name, @description, @quantity, @unit, @unitPrice, 
          @multiplierRate, @hasSubItems, @subItemIds, @analysisComponentIds
        )
        ON CONFLICT (id) DO UPDATE SET
          group_id = @groupId,
          name = @name,
          description = @description,
          quantity = @quantity,
          unit = @unit,
          unit_price = @unitPrice,
          multiplier_rate = @multiplierRate,
          has_sub_items = @hasSubItems,
          sub_item_ids = @subItemIds,
          analysis_component_ids = @analysisComponentIds
      ''', substitutionValues: {
        'id': item.id,
        'groupId': item.groupId,
        'name': item.name,
        'description': item.description,
        'quantity': item.quantity,
        'unit': item.unit,
        'unitPrice': item.unitPrice,
        'multiplierRate': item.multiplierRate,
        'hasSubItems': item.hasSubItems,
        'subItemIds': item.subItemIds,
        'analysisComponentIds': item.analysisComponentIds,
      });

      // Save to in-memory cache
      await _dbService.saveItem(item);
    } catch (e) {
      print('Error saving item: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await initialize();

      // Delete all related sub items
      final subItems = await getSubItemsForItemFromDB(id);
      for (final subItem in subItems) {
        await deleteSubItem(subItem.id);
      }

      // Delete all related analysis components
      final analysisComponents = await getAnalysisComponentsForParentFromDB(id);
      for (final component in analysisComponents) {
        await deleteAnalysisComponent(component.id);
      }

      // Delete the item
      await _connection!.execute(
        'DELETE FROM items WHERE id = @id',
        substitutionValues: {'id': id},
      );

      // Delete from in-memory cache
      await _dbService.deleteItem(id);
    } catch (e) {
      print('Error deleting item: $e');
      rethrow;
    }
  }

  // Sub Item Methods
  @override
  List<SubItem> getSubItemsForItem(String itemId) {
    return _dbService.getSubItemsForItem(itemId);
  }

  @override
  Future<List<SubItem>> getSubItemsForItemFromDB(String itemId) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM sub_items WHERE item_id = @itemId',
        substitutionValues: {'itemId': itemId},
      );

      List<SubItem> subItems = [];
      for (int i = 0; i < results.length; i++) {
        final map = _resultRowToMap(results, i);
        subItems.add(SubItem.fromJson(_convertColumnsToJson(map)));
      }

      return subItems;
    } catch (e) {
      print('Error getting sub items: $e');
      return [];
    }
  }

  @override
  SubItem? getSubItem(String id) {
    return _dbService.getSubItem(id);
  }

  @override
  Future<SubItem?> getSubItemFromDB(String id) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM sub_items WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (results.isEmpty) {
        return null;
      }

      final map = _resultRowToMap(results, 0);

      return SubItem.fromJson(_convertColumnsToJson(map));
    } catch (e) {
      print('Error getting sub item: $e');
      return null;
    }
  }

  @override
  Future<void> saveSubItem(SubItem subItem) async {
    try {
      await initialize();
      await _connection!.execute('''
        INSERT INTO sub_items (
          id, item_id, name, description, quantity, unit, 
          unit_price, multiplier_rate, analysis_component_ids
        ) VALUES (
          @id, @itemId, @name, @description, @quantity, @unit, 
          @unitPrice, @multiplierRate, @analysisComponentIds
        )
        ON CONFLICT (id) DO UPDATE SET
          item_id = @itemId,
          name = @name,
          description = @description,
          quantity = @quantity,
          unit = @unit,
          unit_price = @unitPrice,
          multiplier_rate = @multiplierRate,
          analysis_component_ids = @analysisComponentIds
      ''', substitutionValues: {
        'id': subItem.id,
        'itemId': subItem.itemId,
        'name': subItem.name,
        'description': subItem.description,
        'quantity': subItem.quantity,
        'unit': subItem.unit,
        'unitPrice': subItem.unitPrice,
        'multiplierRate': subItem.multiplierRate,
        'analysisComponentIds': subItem.analysisComponentIds,
      });

      // Save to in-memory cache
      await _dbService.saveSubItem(subItem);
    } catch (e) {
      print('Error saving sub item: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSubItem(String id) async {
    try {
      await initialize();

      // Delete all related analysis components
      final analysisComponents = await getAnalysisComponentsForParentFromDB(id);
      for (final component in analysisComponents) {
        await deleteAnalysisComponent(component.id);
      }

      // Delete the sub item
      await _connection!.execute(
        'DELETE FROM sub_items WHERE id = @id',
        substitutionValues: {'id': id},
      );

      // Delete from in-memory cache
      await _dbService.deleteSubItem(id);
    } catch (e) {
      print('Error deleting sub item: $e');
      rethrow;
    }
  }

  // Analysis Component Methods
  @override
  List<AnalysisComponent> getAnalysisComponentsForParent(String parentId) {
    return _dbService.getAnalysisComponentsForParent(parentId);
  }

  @override
  Future<List<AnalysisComponent>> getAnalysisComponentsForParentFromDB(
      String parentId) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM analysis_components WHERE parent_id = @parentId',
        substitutionValues: {'parentId': parentId},
      );

      List<AnalysisComponent> components = [];
      for (int i = 0; i < results.length; i++) {
        final map = _resultRowToMap(results, i);
        components.add(AnalysisComponent.fromJson(_convertColumnsToJson(map)));
      }

      return components;
    } catch (e) {
      print('Error getting analysis components: $e');
      return [];
    }
  }

  @override
  AnalysisComponent? getAnalysisComponent(String id) {
    return _dbService.getAnalysisComponent(id);
  }

  @override
  Future<AnalysisComponent?> getAnalysisComponentFromDB(String id) async {
    try {
      await initialize();
      final results = await _connection!.query(
        'SELECT * FROM analysis_components WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (results.isEmpty) {
        return null;
      }

      final map = _resultRowToMap(results, 0);

      return AnalysisComponent.fromJson(_convertColumnsToJson(map));
    } catch (e) {
      print('Error getting analysis component: $e');
      return null;
    }
  }

  @override
  Future<void> saveAnalysisComponent(AnalysisComponent component) async {
    try {
      await initialize();
      await _connection!.execute('''
        INSERT INTO analysis_components (
          id, parent_id, name, component_type, unit, quantity, 
          unit_price, mass, origin, manhours
        ) VALUES (
          @id, @parentId, @name, @componentType, @unit, @quantity, 
          @unitPrice, @mass, @origin, @manhours
        )
        ON CONFLICT (id) DO UPDATE SET
          parent_id = @parentId,
          name = @name,
          component_type = @componentType,
          unit = @unit,
          quantity = @quantity,
          unit_price = @unitPrice,
          mass = @mass,
          origin = @origin,
          manhours = @manhours
      ''', substitutionValues: {
        'id': component.id,
        'parentId': component.parentId,
        'name': component.name,
        'componentType': component.componentType,
        'unit': component.unit,
        'quantity': component.quantity,
        'unitPrice': component.unitPrice,
        'mass': component.mass,
        'origin': component.origin,
        'manhours': component.manhours,
      });

      // Save to in-memory cache
      await _dbService.saveAnalysisComponent(component);
    } catch (e) {
      print('Error saving analysis component: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAnalysisComponent(String id) async {
    try {
      await initialize();

      // Delete the analysis component
      await _connection!.execute(
        'DELETE FROM analysis_components WHERE id = @id',
        substitutionValues: {'id': id},
      );

      // Delete from in-memory cache
      await _dbService.deleteAnalysisComponent(id);
    } catch (e) {
      print('Error deleting analysis component: $e');
      rethrow;
    }
  }

  // Helpers
  Map<String, dynamic> _convertColumnsToJson(Map<String, dynamic> map) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      // Convert snake_case to camelCase
      final String camelCaseKey = _snakeToCamelCase(key);

      // Handle arrays
      if (value is List) {
        result[camelCaseKey] = value;
      } else {
        result[camelCaseKey] = value;
      }
    }

    return result;
  }

  String _snakeToCamelCase(String input) {
    final parts = input.split('_');
    final firstPart = parts.first;
    final remainingParts = parts.skip(1).map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1);
    }).join('');

    return firstPart + remainingParts;
  }

  // Dispose connection
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  // Load data from PostgreSQL to in-memory cache
  Future<void> loadFromDatabase() async {
    // Skip database loading on web
    if (kIsWeb) {
      print(
          'Web platform detected - creating sample data for in-memory database');
      // We're on web platform, use sample data instead
      _createSampleData();
      return;
    }

    try {
      await initialize();

      // Load projects
      final projects = await getAllProjectsFromDB();

      // If no projects exist in database, create sample data
      if (projects.isEmpty) {
        print('No projects found in database - creating sample data');
        _createSampleData();
        return;
      }

      for (final project in projects) {
        await _dbService.saveProject(project);
      }

      // Load buildings
      for (final project in projects) {
        final buildings = await getBuildingsForProjectFromDB(project.id);
        for (final building in buildings) {
          await _dbService.saveBuilding(building);

          // Load disciplines
          final disciplines =
              await getDisciplinesForBuildingFromDB(building.id);
          for (final discipline in disciplines) {
            await _dbService.saveDiscipline(discipline);

            // Load groups
            final groups = await getGroupsForDisciplineFromDB(discipline.id);
            for (final group in groups) {
              await _dbService.saveGroup(group);

              // Load items
              final items = await getItemsForGroupFromDB(group.id);
              for (final item in items) {
                await _dbService.saveItem(item);

                // Load sub items
                final subItems = await getSubItemsForItemFromDB(item.id);
                for (final subItem in subItems) {
                  await _dbService.saveSubItem(subItem);

                  // Load analysis components for sub item
                  final subItemComponents =
                      await getAnalysisComponentsForParentFromDB(subItem.id);
                  for (final component in subItemComponents) {
                    await _dbService.saveAnalysisComponent(component);
                  }
                }

                // Load analysis components for item
                final itemComponents =
                    await getAnalysisComponentsForParentFromDB(item.id);
                for (final component in itemComponents) {
                  await _dbService.saveAnalysisComponent(component);
                }
              }
            }
          }
        }
      }

      print('Data loaded from PostgreSQL database to in-memory cache');
    } catch (e) {
      print('Error loading data from database: $e');
      print('Creating sample data instead');
      _createSampleData();
    }
  }

  // Create sample data for in-memory database
  void _createSampleData() {
    // This just uses the sample data creation logic that's already in ProjectProvider
    print('Using sample data for the application');
  }

  // Calculation Methods - delegated to in-memory service
  @override
  double calculateProjectTotalCost(String projectId) {
    return _dbService.calculateProjectTotalCost(projectId);
  }

  @override
  double calculateBuildingTotalCost(String buildingId) {
    return _dbService.calculateBuildingTotalCost(buildingId);
  }

  @override
  double calculateDisciplineTotalCost(String disciplineId) {
    return _dbService.calculateDisciplineTotalCost(disciplineId);
  }

  @override
  double calculateGroupTotalCost(String groupId) {
    return _dbService.calculateGroupTotalCost(groupId);
  }

  @override
  double calculateItemTotalCost(String itemId) {
    return _dbService.calculateItemTotalCost(itemId);
  }

  @override
  double calculateSubItemTotalCost(String subItemId) {
    return _dbService.calculateSubItemTotalCost(subItemId);
  }

  // Export/Import Methods - delegated to in-memory service
  @override
  Map<String, dynamic> exportAllData() {
    return _dbService.exportAllData();
  }

  @override
  Map<String, dynamic> exportProject(String projectId) {
    return _dbService.exportProject(projectId);
  }

  @override
  Future<void> importProject(Map<String, dynamic> data) async {
    await _dbService.importProject(data);

    // TODO: Also sync to PostgreSQL database if needed
  }

  @override
  Future<void> deleteCoefficientTemplate(String templateId) {
    // TODO: implement deleteCoefficientTemplate
    throw UnimplementedError();
  }

  @override
  List<CoefficientTemplate> getAllCoefficientTemplates() {
    // TODO: implement getAllCoefficientTemplates
    throw UnimplementedError();
  }

  @override
  CoefficientTemplate? getCoefficientTemplate(String id) {
    // TODO: implement getCoefficientTemplate
    throw UnimplementedError();
  }

  @override
  Future<void> saveCoefficientTemplate(CoefficientTemplate template) {
    // TODO: implement saveCoefficientTemplate
    throw UnimplementedError();
  }
}

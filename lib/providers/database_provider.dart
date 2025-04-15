import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/project.dart';
import '../models/building.dart';
import '../models/discipline.dart';
import '../models/group.dart';
import '../models/item.dart';
import '../models/sub_item.dart';
import '../models/analysis_component.dart';
import '../services/database_service.dart';
import '../services/postgresql_database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseService _memoryDbService = DatabaseService();
  final PostgreSQLDatabaseService _postgresDbService =
      PostgreSQLDatabaseService();
  bool _usePostgreSQL = false;
  bool _isLoading = false;
  String _errorMessage = '';

  DatabaseProvider() {
    _initialize();
  }

  bool get usePostgreSQL => _usePostgreSQL;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      // Check if running on web platform
      if (kIsWeb) {
        print('Running on web platform - using in-memory database');
        _usePostgreSQL = false;
      } else {
        // Initialize PostgreSQL connection
        await _postgresDbService.initialize();

        // Load data from PostgreSQL to memory
        await _postgresDbService.loadFromDatabase();

        // Set to use PostgreSQL
        _usePostgreSQL = true;
      }
      _setError('');
    } catch (e) {
      print('Error initializing PostgreSQL: $e');
      _setError('Failed to connect to database: $e');
      _usePostgreSQL = false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Project Methods
  Future<List<Project>> getAllProjects() async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final projects = await _postgresDbService.getAllProjectsFromDB();
        _setError('');
        return projects;
      } else {
        return _memoryDbService.getAllProjects();
      }
    } catch (e) {
      _setError('Error loading projects: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Project?> getProject(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final project = await _postgresDbService.getProjectFromDB(id);
        _setError('');
        return project;
      } else {
        return _memoryDbService.getProject(id);
      }
    } catch (e) {
      _setError('Error loading project: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveProject(Project project) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.saveProject(project);
      } else {
        await _memoryDbService.saveProject(project);
      }
      _setError('');
    } catch (e) {
      _setError('Error saving project: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProject(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.deleteProject(id);
      } else {
        await _memoryDbService.deleteProject(id);
      }
      _setError('');
    } catch (e) {
      _setError('Error deleting project: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Building Methods
  Future<List<Building>> getBuildingsForProject(String projectId) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final buildings =
            await _postgresDbService.getBuildingsForProjectFromDB(projectId);
        _setError('');
        return buildings;
      } else {
        return _memoryDbService.getBuildingsForProject(projectId);
      }
    } catch (e) {
      _setError('Error loading buildings: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Building?> getBuilding(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final building = await _postgresDbService.getBuildingFromDB(id);
        _setError('');
        return building;
      } else {
        return _memoryDbService.getBuilding(id);
      }
    } catch (e) {
      _setError('Error loading building: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveBuilding(Building building) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.saveBuilding(building);
      } else {
        await _memoryDbService.saveBuilding(building);
      }
      _setError('');
    } catch (e) {
      _setError('Error saving building: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBuilding(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.deleteBuilding(id);
      } else {
        await _memoryDbService.deleteBuilding(id);
      }
      _setError('');
    } catch (e) {
      _setError('Error deleting building: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Discipline Methods
  Future<List<Discipline>> getDisciplinesForBuilding(String buildingId) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final disciplines = await _postgresDbService
            .getDisciplinesForBuildingFromDB(buildingId);
        _setError('');
        return disciplines;
      } else {
        return _memoryDbService.getDisciplinesForBuilding(buildingId);
      }
    } catch (e) {
      _setError('Error loading disciplines: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Discipline?> getDiscipline(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final discipline = await _postgresDbService.getDisciplineFromDB(id);
        _setError('');
        return discipline;
      } else {
        return _memoryDbService.getDiscipline(id);
      }
    } catch (e) {
      _setError('Error loading discipline: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveDiscipline(Discipline discipline) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.saveDiscipline(discipline);
      } else {
        await _memoryDbService.saveDiscipline(discipline);
      }
      _setError('');
    } catch (e) {
      _setError('Error saving discipline: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteDiscipline(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.deleteDiscipline(id);
      } else {
        await _memoryDbService.deleteDiscipline(id);
      }
      _setError('');
    } catch (e) {
      _setError('Error deleting discipline: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Group Methods
  Future<List<Group>> getGroupsForDiscipline(String disciplineId) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final groups =
            await _postgresDbService.getGroupsForDisciplineFromDB(disciplineId);
        _setError('');
        return groups;
      } else {
        return _memoryDbService.getGroupsForDiscipline(disciplineId);
      }
    } catch (e) {
      _setError('Error loading groups: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Group?> getGroup(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final group = await _postgresDbService.getGroupFromDB(id);
        _setError('');
        return group;
      } else {
        return _memoryDbService.getGroup(id);
      }
    } catch (e) {
      _setError('Error loading group: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveGroup(Group group) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.saveGroup(group);
      } else {
        await _memoryDbService.saveGroup(group);
      }
      _setError('');
    } catch (e) {
      _setError('Error saving group: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteGroup(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.deleteGroup(id);
      } else {
        await _memoryDbService.deleteGroup(id);
      }
      _setError('');
    } catch (e) {
      _setError('Error deleting group: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Item Methods
  Future<List<Item>> getItemsForGroup(String groupId) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final items = await _postgresDbService.getItemsForGroupFromDB(groupId);
        _setError('');
        return items;
      } else {
        return _memoryDbService.getItemsForGroup(groupId);
      }
    } catch (e) {
      _setError('Error loading items: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Item?> getItem(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final item = await _postgresDbService.getItemFromDB(id);
        _setError('');
        return item;
      } else {
        return _memoryDbService.getItem(id);
      }
    } catch (e) {
      _setError('Error loading item: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveItem(Item item) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.saveItem(item);
      } else {
        await _memoryDbService.saveItem(item);
      }
      _setError('');
    } catch (e) {
      _setError('Error saving item: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteItem(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.deleteItem(id);
      } else {
        await _memoryDbService.deleteItem(id);
      }
      _setError('');
    } catch (e) {
      _setError('Error deleting item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Sub Item Methods
  Future<List<SubItem>> getSubItemsForItem(String itemId) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final subItems =
            await _postgresDbService.getSubItemsForItemFromDB(itemId);
        _setError('');
        return subItems;
      } else {
        return _memoryDbService.getSubItemsForItem(itemId);
      }
    } catch (e) {
      _setError('Error loading sub items: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<SubItem?> getSubItem(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final subItem = await _postgresDbService.getSubItemFromDB(id);
        _setError('');
        return subItem;
      } else {
        return _memoryDbService.getSubItem(id);
      }
    } catch (e) {
      _setError('Error loading sub item: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveSubItem(SubItem subItem) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.saveSubItem(subItem);
      } else {
        await _memoryDbService.saveSubItem(subItem);
      }
      _setError('');
    } catch (e) {
      _setError('Error saving sub item: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSubItem(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.deleteSubItem(id);
      } else {
        await _memoryDbService.deleteSubItem(id);
      }
      _setError('');
    } catch (e) {
      _setError('Error deleting sub item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Analysis Component Methods
  Future<List<AnalysisComponent>> getAnalysisComponentsForParent(
      String parentId) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final components = await _postgresDbService
            .getAnalysisComponentsForParentFromDB(parentId);
        _setError('');
        return components;
      } else {
        return _memoryDbService.getAnalysisComponentsForParent(parentId);
      }
    } catch (e) {
      _setError('Error loading analysis components: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<AnalysisComponent?> getAnalysisComponent(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        final component =
            await _postgresDbService.getAnalysisComponentFromDB(id);
        _setError('');
        return component;
      } else {
        return _memoryDbService.getAnalysisComponent(id);
      }
    } catch (e) {
      _setError('Error loading analysis component: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveAnalysisComponent(AnalysisComponent component) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.saveAnalysisComponent(component);
      } else {
        await _memoryDbService.saveAnalysisComponent(component);
      }
      _setError('');
    } catch (e) {
      _setError('Error saving analysis component: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAnalysisComponent(String id) async {
    _setLoading(true);
    try {
      if (_usePostgreSQL) {
        await _postgresDbService.deleteAnalysisComponent(id);
      } else {
        await _memoryDbService.deleteAnalysisComponent(id);
      }
      _setError('');
    } catch (e) {
      _setError('Error deleting analysis component: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Calculation Methods
  double calculateProjectTotalCost(String projectId) {
    return _memoryDbService.calculateProjectTotalCost(projectId);
  }

  double calculateBuildingTotalCost(String buildingId) {
    return _memoryDbService.calculateBuildingTotalCost(buildingId);
  }

  double calculateDisciplineTotalCost(String disciplineId) {
    return _memoryDbService.calculateDisciplineTotalCost(disciplineId);
  }

  double calculateGroupTotalCost(String groupId) {
    return _memoryDbService.calculateGroupTotalCost(groupId);
  }

  double calculateItemTotalCost(String itemId) {
    return _memoryDbService.calculateItemTotalCost(itemId);
  }

  double calculateSubItemTotalCost(String subItemId) {
    return _memoryDbService.calculateSubItemTotalCost(subItemId);
  }

  // Import/Export Methods
  Map<String, dynamic> exportAllData() {
    return _memoryDbService.exportAllData();
  }

  Map<String, dynamic> exportProject(String projectId) {
    return _memoryDbService.exportProject(projectId);
  }

  Future<void> importProject(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _memoryDbService.importProject(data);

      if (_usePostgreSQL) {
        // Also import to PostgreSQL
        final project = data['project'];
        final buildings = data['buildings'];
        final disciplines = data['disciplines'];
        final groups = data['groups'];
        final items = data['items'];
        final subItems = data['subItems'];
        final analysisComponents = data['analysisComponents'];

        // Import project
        await _postgresDbService.saveProject(Project.fromJson(project));

        // Import buildings
        for (final buildingData in buildings) {
          await _postgresDbService
              .saveBuilding(Building.fromJson(buildingData));
        }

        // Import disciplines
        for (final disciplineData in disciplines) {
          await _postgresDbService
              .saveDiscipline(Discipline.fromJson(disciplineData));
        }

        // Import groups
        for (final groupData in groups) {
          await _postgresDbService.saveGroup(Group.fromJson(groupData));
        }

        // Import items
        for (final itemData in items) {
          await _postgresDbService.saveItem(Item.fromJson(itemData));
        }

        // Import sub items
        for (final subItemData in subItems) {
          await _postgresDbService.saveSubItem(SubItem.fromJson(subItemData));
        }

        // Import analysis components
        for (final componentData in analysisComponents) {
          await _postgresDbService
              .saveAnalysisComponent(AnalysisComponent.fromJson(componentData));
        }
      }

      _setError('');
    } catch (e) {
      _setError('Error importing project data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle between PostgreSQL and in-memory database
  Future<void> toggleDatabaseMode() async {
    if (!_usePostgreSQL) {
      // Switching to PostgreSQL
      _setLoading(true);
      try {
        await _postgresDbService.initialize();

        // Export all data from memory
        final data = _memoryDbService.exportAllData();

        // Import all data to PostgreSQL
        if (data['projects'].isNotEmpty) {
          for (final projectData in data['projects']) {
            await _postgresDbService.saveProject(Project.fromJson(projectData));
          }

          for (final buildingData in data['buildings']) {
            await _postgresDbService
                .saveBuilding(Building.fromJson(buildingData));
          }

          for (final disciplineData in data['disciplines']) {
            await _postgresDbService
                .saveDiscipline(Discipline.fromJson(disciplineData));
          }

          for (final groupData in data['groups']) {
            await _postgresDbService.saveGroup(Group.fromJson(groupData));
          }

          for (final itemData in data['items']) {
            await _postgresDbService.saveItem(Item.fromJson(itemData));
          }

          for (final subItemData in data['subItems']) {
            await _postgresDbService.saveSubItem(SubItem.fromJson(subItemData));
          }

          for (final componentData in data['analysisComponents']) {
            await _postgresDbService.saveAnalysisComponent(
                AnalysisComponent.fromJson(componentData));
          }
        }

        // Switch to PostgreSQL mode
        _usePostgreSQL = true;
        _setError('');
      } catch (e) {
        _setError('Failed to switch to PostgreSQL: $e');
      } finally {
        _setLoading(false);
      }
    } else {
      // Switching to in-memory database
      _usePostgreSQL = false;
      notifyListeners();
    }
  }

  // Close PostgreSQL connection when app is closed
  Future<void> dispose() async {
    if (_usePostgreSQL) {
      await _postgresDbService.close();
    }
    super.dispose();
  }
}

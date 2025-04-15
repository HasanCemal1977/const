import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../constants/strings.dart';
import '../models/project.dart';
import '../models/building.dart';
import '../models/discipline.dart';
import '../models/group.dart';
import '../models/item.dart';
import '../models/sub_item.dart';
import '../models/analysis_component.dart';
import '../models/coefficient_template.dart';
import '../services/database_service.dart';

class ProjectProvider with ChangeNotifier {
  Project? _currentProject;
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  ProjectProvider() {
    _loadProjects();
  }

  // Getters
  Project? get currentProject => _currentProject;
  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProject => _currentProject != null;

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    if (errorMessage != null) {
      print('Error: $errorMessage'); // For debugging
    }
    notifyListeners();
  }

  // Load projects
  void _loadProjects() {
    _setLoading(true);
    try {
      // Create some sample projects
      final project1 = Project(
        id: '1',
        name: 'Residential Building Project',
        description: 'A 10-floor residential building with 40 apartments',
        location: 'Downtown',
        client: 'ABC Real Estate',
        contractor: 'Best Construction Co.',
        startDate: DateTime(2023, 5, 10),
        endDate: DateTime(2024, 12, 15),
        status: 'In progress',
      );

      final project2 = Project(
        id: '2',
        name: 'Commercial Office Tower',
        description: 'A 25-floor office tower with retail spaces',
        location: 'Business District',
        client: 'XYZ Investments',
        contractor: 'Modern Builders Ltd.',
        startDate: DateTime(2023, 2, 5),
        endDate: DateTime(2025, 4, 30),
        status: 'Planning',
      );

      // Save to database service
      _dbService.saveProject(project1);
      _dbService.saveProject(project2);

      // Load into local variables
      _projects = _dbService.getAllProjects();
      _currentProject = project1;
    } catch (e) {
      _setError('Failed to load projects: $e');
    }
    _setLoading(false);
  }

  // Create a new project
  Future<void> createProject(Project project) async {
    _setLoading(true);
    try {
      await _dbService.saveProject(project);
      _projects = _dbService.getAllProjects();
      _currentProject = project;
      notifyListeners();
    } catch (e) {
      _setError('Failed to create project: $e');
    }
    _setLoading(false);
  }

  // Set current project
  void setCurrentProject(String projectId) {
    final project = _dbService.getProject(projectId);
    if (project != null) {
      _currentProject = project;
      notifyListeners();
    } else {
      _setError('Project not found');
    }
  }

  // Get all buildings for the current project
  List<Building> getBuildingsForCurrentProject() {
    if (_currentProject == null) return [];
    return _dbService.getBuildingsForProject(_currentProject!.id);
  }

  // Update a project
  Future<void> updateProject(Project project) async {
    _setLoading(true);
    try {
      await _dbService.saveProject(project);

      // Update local projects list
      _projects = _dbService.getAllProjects();

      if (_currentProject?.id == project.id) {
        _currentProject = project;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to update project: $e');
    }
    _setLoading(false);
  }

  // Add a building to the current project
  Future<void> addBuilding(Building building) async {
    _setLoading(true);
    try {
      await _dbService.saveBuilding(building);

      if (_currentProject != null) {
        final updatedProject = _currentProject!.copyWith(
          buildingIds: [..._currentProject!.buildingIds, building.id],
        );
        await updateProject(updatedProject);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to add building: $e');
    }
    _setLoading(false);
  }

  // Update a building
  Future<void> updateBuilding(Building building) async {
    _setLoading(true);
    try {
      await _dbService.saveBuilding(building);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update building: $e');
    }
    _setLoading(false);
  }

  // Add a discipline
  Future<void> addDiscipline(Discipline discipline) async {
    _setLoading(true);
    try {
      await _dbService.saveDiscipline(discipline);

      // Find the building and update it
      final building = _dbService.getBuilding(discipline.buildingId);
      if (building != null) {
        final updatedBuilding = building.copyWith(
          disciplineIds: [...building.disciplineIds, discipline.id],
        );
        await updateBuilding(updatedBuilding);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to add discipline: $e');
    }
    _setLoading(false);
  }

  // Get all disciplines for a building
  List<Discipline> getDisciplinesForBuilding(String buildingId) {
    return _dbService.getDisciplinesForBuilding(buildingId);
  }

  // Update a discipline
  Future<void> updateDiscipline(Discipline discipline) async {
    _setLoading(true);
    try {
      await _dbService.saveDiscipline(discipline);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update discipline: $e');
    }
    _setLoading(false);
  }

  // Add a group to a discipline
  Future<void> addGroup(Group group) async {
    _setLoading(true);
    try {
      await _dbService.saveGroup(group);

      // Find the discipline and update it
      final discipline = _dbService.getDiscipline(group.disciplineId);
      if (discipline != null) {
        final updatedDiscipline = discipline.copyWith(
          groupIds: [...discipline.groupIds, group.id],
        );
        await updateDiscipline(updatedDiscipline);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to add group: $e');
    }
    _setLoading(false);
  }

  // Get all groups for a discipline
  List<Group> getGroupsForDiscipline(String disciplineId) {
    return _dbService.getGroupsForDiscipline(disciplineId);
  }

  // Update a group
  Future<void> updateGroup(Group group) async {
    _setLoading(true);
    try {
      await _dbService.saveGroup(group);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update group: $e');
    }
    _setLoading(false);
  }

  // Delete a group and all its children
  Future<void> deleteGroup(String groupId) async {
    _setLoading(true);
    try {
      // Get the group to get its disciplineId before removing
      final group = _dbService.getGroup(groupId);

      if (group != null) {
        // Get the discipline to update its groupIds
        final discipline = _dbService.getDiscipline(group.disciplineId);

        // Delete the group from the database (will delete all children)
        await _dbService.deleteGroup(groupId);

        // Update the discipline's groupIds
        if (discipline != null) {
          final updatedDiscipline = discipline.copyWith(
            groupIds: discipline.groupIds.where((id) => id != groupId).toList(),
          );
          await updateDiscipline(updatedDiscipline);
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete group: $e');
    }
    _setLoading(false);
  }

  // Add an item to a group
  Future<void> addItem(Item item) async {
    _setLoading(true);
    try {
      await _dbService.saveItem(item);

      // Update group's itemIds
      final group = _dbService.getGroup(item.groupId);
      if (group != null) {
        final updatedGroup = group.copyWith(
          itemIds: [...group.itemIds, item.id],
        );
        await updateGroup(updatedGroup);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to add item: $e');
    }
    _setLoading(false);
  }

  // Get all items for a group
  List<Item> getItemsForGroup(String groupId) {
    return _dbService.getItemsForGroup(groupId);
  }

  // Update an item
  Future<void> updateItem(Item item) async {
    _setLoading(true);
    try {
      await _dbService.saveItem(item);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update item: $e');
    }
    _setLoading(false);
  }

  // Delete an item
  Future<void> deleteItem(String itemId) async {
    _setLoading(true);
    try {
      // Get the item to get its groupId before removing
      final item = _dbService.getItem(itemId);

      if (item != null) {
        // Get the group to update its itemIds
        final group = _dbService.getGroup(item.groupId);

        // Delete the item from the database (will delete all children)
        await _dbService.deleteItem(itemId);

        // Update the group's itemIds
        if (group != null) {
          final updatedGroup = group.copyWith(
            itemIds: group.itemIds.where((id) => id != itemId).toList(),
          );
          await updateGroup(updatedGroup);
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete item: $e');
    }
    _setLoading(false);
  }

  // Add a sub item to an item
  Future<void> addSubItem(SubItem subItem) async {
    _setLoading(true);
    try {
      await _dbService.saveSubItem(subItem);

      // Update item's subItemIds and set hasSubItems to true
      final item = _dbService.getItem(subItem.itemId);
      if (item != null) {
        final updatedItem = item.copyWith(
          hasSubItems: true,
          subItemIds: [...item.subItemIds, subItem.id],
        );
        await updateItem(updatedItem);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to add sub item: $e');
    }
    _setLoading(false);
  }

  // Get all sub items for an item
  List<SubItem> getSubItemsForItem(String itemId) {
    return _dbService.getSubItemsForItem(itemId);
  }

  // Update a sub item
  Future<void> updateSubItem(SubItem subItem) async {
    _setLoading(true);
    try {
      await _dbService.saveSubItem(subItem);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update sub item: $e');
    }
    _setLoading(false);
  }

  // Delete a sub item
  Future<void> deleteSubItem(String subItemId) async {
    _setLoading(true);
    try {
      // Get the sub item to get its itemId before removing
      final subItem = _dbService.getSubItem(subItemId);

      if (subItem != null) {
        // Get the item to update its subItemIds
        final item = _dbService.getItem(subItem.itemId);

        // Delete the sub item from the database (will delete all children)
        await _dbService.deleteSubItem(subItemId);

        // Update the item's subItemIds and hasSubItems
        if (item != null) {
          final updatedSubItemIds =
              item.subItemIds.where((id) => id != subItemId).toList();
          final updatedItem = item.copyWith(
            subItemIds: updatedSubItemIds,
            hasSubItems: updatedSubItemIds.isNotEmpty,
          );
          await updateItem(updatedItem);
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete sub item: $e');
    }
    _setLoading(false);
  }

  // Add an analysis component to an item or sub item
  Future<void> addAnalysisComponent(AnalysisComponent component) async {
    _setLoading(true);
    try {
      await _dbService.saveAnalysisComponent(component);

      // Update parent's analysisComponentIds
      if (component.parentId.isNotEmpty) {
        // Check if parent is an item
        final item = _dbService.getItem(component.parentId);
        if (item != null) {
          // Item class has analysisComponentIds property
          final updatedItem = item.copyWith(
            analysisComponentIds: [...item.analysisComponentIds, component.id],
          );
          await updateItem(updatedItem);
        } else {
          // Check if parent is a sub item
          final subItem = _dbService.getSubItem(component.parentId);
          if (subItem != null) {
            // SubItem class has analysisComponentIds property
            final updatedSubItem = subItem.copyWith(
              analysisComponentIds: [
                ...subItem.analysisComponentIds,
                component.id
              ],
            );
            await updateSubItem(updatedSubItem);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to add analysis component: $e');
    }
    _setLoading(false);
  }

  // Get all analysis components for a parent (item or sub item)
  List<AnalysisComponent> getAnalysisComponentsForParent(String parentId) {
    return _dbService.getAnalysisComponentsForParent(parentId);
  }

  // Update an analysis component
  Future<void> updateAnalysisComponent(AnalysisComponent component) async {
    _setLoading(true);
    try {
      await _dbService.saveAnalysisComponent(component);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update analysis component: $e');
    }
    _setLoading(false);
  }

  // Delete an analysis component
  Future<void> deleteAnalysisComponent(String componentId) async {
    _setLoading(true);
    try {
      // Get the component to get its parentId before removing
      final component = _dbService.getAnalysisComponent(componentId);

      if (component != null) {
        // Update parent's analysisComponentIds
        if (component.parentId.isNotEmpty) {
          // Check if parent is an item
          final item = _dbService.getItem(component.parentId);
          if (item != null) {
            // Item class has analysisComponentIds property
            final updatedItem = item.copyWith(
              analysisComponentIds: item.analysisComponentIds
                  .where((id) => id != componentId)
                  .toList(),
            );
            await updateItem(updatedItem);
          } else {
            // Check if parent is a sub item
            final subItem = _dbService.getSubItem(component.parentId);
            if (subItem != null) {
              // SubItem class has analysisComponentIds property
              final updatedSubItem = subItem.copyWith(
                analysisComponentIds: subItem.analysisComponentIds
                    .where((id) => id != componentId)
                    .toList(),
              );
              await updateSubItem(updatedSubItem);
            }
          }
        }

        // Delete the component
        await _dbService.deleteAnalysisComponent(componentId);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to delete analysis component: $e');
    }
    _setLoading(false);
  }

  // Create default disciplines for a building
  Future<void> createDefaultDisciplines(String buildingId) async {
    for (final disciplineName in Strings.defaultDisciplines) {
      final discipline = Discipline(
        id: const Uuid().v4(),
        name: disciplineName,
        buildingId: buildingId,
      );
      await addDiscipline(discipline);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Calculate total cost methods
  double calculateProjectTotalCost(String projectId) {
    return _dbService.calculateProjectTotalCost(projectId);
  }

  double calculateBuildingTotalCost(String buildingId) {
    return _dbService.calculateBuildingTotalCost(buildingId);
  }

  double calculateDisciplineTotalCost(String disciplineId) {
    return _dbService.calculateDisciplineTotalCost(disciplineId);
  }

  double calculateGroupTotalCost(String groupId) {
    return _dbService.calculateGroupTotalCost(groupId);
  }

  double calculateItemTotalCost(String itemId) {
    return _dbService.calculateItemTotalCost(itemId);
  }

  double calculateSubItemTotalCost(String subItemId) {
    return _dbService.calculateSubItemTotalCost(subItemId);
  }

  // Coefficient Template methods
  List<CoefficientTemplate> _coefficientTemplates = [];

  List<CoefficientTemplate> get coefficientTemplates => _coefficientTemplates;

  Future<void> loadCoefficientTemplates() async {
    _setLoading(true);
    try {
      _coefficientTemplates = _dbService.getAllCoefficientTemplates();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load coefficient templates: $e');
    }
    _setLoading(false);
  }

  Future<void> addCoefficientTemplate(CoefficientTemplate template) async {
    _setLoading(true);
    try {
      await _dbService.saveCoefficientTemplate(template);
      _coefficientTemplates = _dbService.getAllCoefficientTemplates();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add coefficient template: $e');
    }
    _setLoading(false);
  }

  Future<void> updateCoefficientTemplate(CoefficientTemplate template) async {
    _setLoading(true);
    try {
      await _dbService.saveCoefficientTemplate(template);
      _coefficientTemplates = _dbService.getAllCoefficientTemplates();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update coefficient template: $e');
    }
    _setLoading(false);
  }

  Future<void> deleteCoefficientTemplate(String templateId) async {
    _setLoading(true);
    try {
      await _dbService.deleteCoefficientTemplate(templateId);
      _coefficientTemplates = _dbService.getAllCoefficientTemplates();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete coefficient template: $e');
    }
    _setLoading(false);
  }

  CoefficientTemplate? getCoefficientTemplate(String templateId) {
    return _dbService.getCoefficientTemplate(templateId);
  }

  // Project Deletion Method
  Future<void> deleteProject(String projectId) async {
    _setLoading(true);
    try {
      await _dbService.deleteProject(projectId);

      // Update local projects list
      _projects = _dbService.getAllProjects();

      // If deleted project was the current project, set current project to null
      if (_currentProject?.id == projectId) {
        _currentProject = _projects.isNotEmpty ? _projects.first : null;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete project: $e');
    }
    _setLoading(false);
  }
}

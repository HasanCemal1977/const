import '../models/project.dart';
import '../models/building.dart';
import '../models/discipline.dart';
import '../models/group.dart';
import '../models/item.dart';
import '../models/sub_item.dart';
import '../models/analysis_component.dart';
import '../models/coefficient_template.dart';

/// A service class to handle database operations using in-memory lists
class DatabaseService {
  // Lists for all model types - protected for subclasses to access
  final List<Project> _projects;
  final List<Building> _buildings;
  final List<Discipline> _disciplines;
  final List<Group> _groups;
  final List<Item> _items;
  final List<SubItem> _subItems;
  final List<AnalysisComponent> _analysisComponents;
  final List<CoefficientTemplate> _coefficientTemplates;

  // Singleton instance
  static final DatabaseService _instance = DatabaseService._internal();

  // Private constructor
  DatabaseService._internal()
      : _projects = [],
        _buildings = [],
        _disciplines = [],
        _groups = [],
        _items = [],
        _subItems = [],
        _analysisComponents = [],
        _coefficientTemplates = [];

  // Factory constructor to get the singleton instance
  factory DatabaseService() {
    return _instance;
  }

  // Project Methods
  List<Project> getAllProjects() {
    return List.from(_projects);
  }

  // Method for PostgreSQL override
  Future<List<Project>> getAllProjectsFromDB() async {
    return getAllProjects();
  }

  Project? getProject(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method for PostgreSQL override
  Future<Project?> getProjectFromDB(String id) async {
    return getProject(id);
  }

  Future<void> saveProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
    } else {
      _projects.add(project);
    }
  }

  Future<void> deleteProject(String id) async {
    // Get all buildings for this project
    final buildingsToDelete =
        _buildings.where((building) => building.projectId == id).toList();

    // Delete each building and its children
    for (final building in buildingsToDelete) {
      await deleteBuilding(building.id);
    }

    // Delete the project itself
    _projects.removeWhere((project) => project.id == id);
  }

  // Building Methods
  List<Building> getBuildingsForProject(String projectId) {
    return _buildings
        .where((building) => building.projectId == projectId)
        .toList();
  }

  // Method for PostgreSQL override
  Future<List<Building>> getBuildingsForProjectFromDB(String projectId) async {
    return getBuildingsForProject(projectId);
  }

  Building? getBuilding(String id) {
    try {
      return _buildings.firstWhere((building) => building.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method for PostgreSQL override
  Future<Building?> getBuildingFromDB(String id) async {
    return getBuilding(id);
  }

  Future<void> saveBuilding(Building building) async {
    final index = _buildings.indexWhere((b) => b.id == building.id);
    if (index >= 0) {
      _buildings[index] = building;
    } else {
      _buildings.add(building);
    }
  }

  Future<void> deleteBuilding(String id) async {
    // Get all disciplines for this building
    final disciplinesToDelete = _disciplines
        .where((discipline) => discipline.buildingId == id)
        .toList();

    // Delete each discipline and its children
    for (final discipline in disciplinesToDelete) {
      await deleteDiscipline(discipline.id);
    }

    // Delete the building itself
    _buildings.removeWhere((building) => building.id == id);
  }

  // Discipline Methods
  List<Discipline> getDisciplinesForBuilding(String buildingId) {
    return _disciplines
        .where((discipline) => discipline.buildingId == buildingId)
        .toList();
  }

  // Method for PostgreSQL override
  Future<List<Discipline>> getDisciplinesForBuildingFromDB(
      String buildingId) async {
    return getDisciplinesForBuilding(buildingId);
  }

  Discipline? getDiscipline(String id) {
    try {
      return _disciplines.firstWhere((discipline) => discipline.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method for PostgreSQL override
  Future<Discipline?> getDisciplineFromDB(String id) async {
    return getDiscipline(id);
  }

  Future<void> saveDiscipline(Discipline discipline) async {
    final index = _disciplines.indexWhere((d) => d.id == discipline.id);
    if (index >= 0) {
      _disciplines[index] = discipline;
    } else {
      _disciplines.add(discipline);
    }
  }

  Future<void> deleteDiscipline(String id) async {
    // Get all groups for this discipline
    final groupsToDelete =
        _groups.where((group) => group.disciplineId == id).toList();

    // Delete each group and its children
    for (final group in groupsToDelete) {
      await deleteGroup(group.id);
    }

    // Delete the discipline itself
    _disciplines.removeWhere((discipline) => discipline.id == id);
  }

  // Group Methods
  List<Group> getGroupsForDiscipline(String disciplineId) {
    return _groups
        .where((group) => group.disciplineId == disciplineId)
        .toList();
  }

  // Method for PostgreSQL override
  Future<List<Group>> getGroupsForDisciplineFromDB(String disciplineId) async {
    return getGroupsForDiscipline(disciplineId);
  }

  Group? getGroup(String id) {
    try {
      return _groups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method for PostgreSQL override
  Future<Group?> getGroupFromDB(String id) async {
    return getGroup(id);
  }

  Future<void> saveGroup(Group group) async {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index >= 0) {
      _groups[index] = group;
    } else {
      _groups.add(group);
    }
  }

  Future<void> deleteGroup(String id) async {
    // Get all items for this group
    final itemsToDelete = _items.where((item) => item.groupId == id).toList();

    // Delete each item and its children
    for (final item in itemsToDelete) {
      await deleteItem(item.id);
    }

    // Delete the group itself
    _groups.removeWhere((group) => group.id == id);
  }

  // Item Methods
  List<Item> getItemsForGroup(String groupId) {
    return _items.where((item) => item.groupId == groupId).toList();
  }

  // Method for PostgreSQL override
  Future<List<Item>> getItemsForGroupFromDB(String groupId) async {
    return getItemsForGroup(groupId);
  }

  Item? getItem(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method for PostgreSQL override
  Future<Item?> getItemFromDB(String id) async {
    return getItem(id);
  }

  Future<void> saveItem(Item item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
  }

  Future<void> deleteItem(String id) async {
    // Get all sub items for this item
    final subItemsToDelete =
        _subItems.where((subItem) => subItem.itemId == id).toList();

    // Delete each sub item and its children
    for (final subItem in subItemsToDelete) {
      await deleteSubItem(subItem.id);
    }

    // Delete analysis components directly attached to this item
    final componentsToDelete = _analysisComponents
        .where((component) => component.parentId == id)
        .toList();

    for (final component in componentsToDelete) {
      await deleteAnalysisComponent(component.id);
    }

    // Delete the item itself
    _items.removeWhere((item) => item.id == id);
  }

  // Sub Item Methods
  List<SubItem> getSubItemsForItem(String itemId) {
    return _subItems.where((subItem) => subItem.itemId == itemId).toList();
  }

  // Method for PostgreSQL override
  Future<List<SubItem>> getSubItemsForItemFromDB(String itemId) async {
    return getSubItemsForItem(itemId);
  }

  SubItem? getSubItem(String id) {
    try {
      return _subItems.firstWhere((subItem) => subItem.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method for PostgreSQL override
  Future<SubItem?> getSubItemFromDB(String id) async {
    return getSubItem(id);
  }

  Future<void> saveSubItem(SubItem subItem) async {
    final index = _subItems.indexWhere((si) => si.id == subItem.id);
    if (index >= 0) {
      _subItems[index] = subItem;
    } else {
      _subItems.add(subItem);
    }
  }

  Future<void> deleteSubItem(String id) async {
    // Delete analysis components for this sub item
    final componentsToDelete = _analysisComponents
        .where((component) => component.parentId == id)
        .toList();

    for (final component in componentsToDelete) {
      await deleteAnalysisComponent(component.id);
    }

    // Delete the sub item itself
    _subItems.removeWhere((subItem) => subItem.id == id);
  }

  // Analysis Component Methods
  List<AnalysisComponent> getAnalysisComponentsForParent(String parentId) {
    return _analysisComponents
        .where((component) => component.parentId == parentId)
        .toList();
  }

  // Method for PostgreSQL override
  Future<List<AnalysisComponent>> getAnalysisComponentsForParentFromDB(
      String parentId) async {
    return getAnalysisComponentsForParent(parentId);
  }

  AnalysisComponent? getAnalysisComponent(String id) {
    try {
      return _analysisComponents.firstWhere((component) => component.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method for PostgreSQL override
  Future<AnalysisComponent?> getAnalysisComponentFromDB(String id) async {
    return getAnalysisComponent(id);
  }

  Future<void> saveAnalysisComponent(AnalysisComponent component) async {
    final index = _analysisComponents.indexWhere((ac) => ac.id == component.id);
    if (index >= 0) {
      _analysisComponents[index] = component;
    } else {
      _analysisComponents.add(component);
    }
  }

  Future<void> deleteAnalysisComponent(String id) async {
    _analysisComponents.removeWhere((component) => component.id == id);
  }

  // Coefficient Template Methods
  List<CoefficientTemplate> getAllCoefficientTemplates() {
    return List.from(_coefficientTemplates);
  }

  CoefficientTemplate? getCoefficientTemplate(String id) {
    try {
      return _coefficientTemplates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCoefficientTemplate(CoefficientTemplate template) async {
    final index = _coefficientTemplates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      _coefficientTemplates[index] = template;
    } else {
      _coefficientTemplates.add(template);
    }
  }

  Future<void> deleteCoefficientTemplate(String templateId) async {
    _coefficientTemplates.removeWhere((template) => template.id == templateId);
  }

  // Querying and Calculation Methods

  /// Calculate total cost of a project including all its children
  double calculateProjectTotalCost(String projectId) {
    double totalCost = 0;

    final buildings = getBuildingsForProject(projectId);
    for (final building in buildings) {
      totalCost += calculateBuildingTotalCost(building.id);
    }

    return totalCost;
  }

  /// Calculate total cost of a building including all its children
  double calculateBuildingTotalCost(String buildingId) {
    double totalCost = 0;

    final building = getBuilding(buildingId);
    if (building == null) return 0;

    final disciplines = getDisciplinesForBuilding(buildingId);
    for (final discipline in disciplines) {
      totalCost += calculateDisciplineTotalCost(discipline.id);
    }

    return totalCost * building.multiplierRate;
  }

  /// Calculate total cost of a discipline including all its children
  double calculateDisciplineTotalCost(String disciplineId) {
    double totalCost = 0;

    final discipline = getDiscipline(disciplineId);
    if (discipline == null) return 0;

    final groups = getGroupsForDiscipline(disciplineId);
    for (final group in groups) {
      totalCost += calculateGroupTotalCost(group.id);
    }

    return totalCost * discipline.multiplierRate;
  }

  /// Calculate total cost of a group including all its children
  double calculateGroupTotalCost(String groupId) {
    double totalCost = 0;

    final group = getGroup(groupId);
    if (group == null) return 0;

    final items = getItemsForGroup(groupId);
    for (final item in items) {
      totalCost += calculateItemTotalCost(item.id);
    }

    return totalCost * group.multiplierRate;
  }

  /// Calculate total cost of an item including all its children
  double calculateItemTotalCost(String itemId) {
    final item = getItem(itemId);
    if (item == null) return 0;

    if (item.hasSubItems) {
      double totalCost = 0;

      final subItems = getSubItemsForItem(itemId);
      for (final subItem in subItems) {
        totalCost += calculateSubItemTotalCost(subItem.id);
      }

      return totalCost * item.multiplierRate;
    } else {
      double componentCost = 0;

      final components = getAnalysisComponentsForParent(itemId);
      for (final component in components) {
        componentCost += component.totalCost;
      }

      if (componentCost > 0) {
        return componentCost * item.multiplierRate;
      } else {
        return item.quantity * item.unitPrice * item.multiplierRate;
      }
    }
  }

  /// Calculate total cost of a sub item including all its children
  double calculateSubItemTotalCost(String subItemId) {
    final subItem = getSubItem(subItemId);
    if (subItem == null) return 0;

    double componentCost = 0;

    final components = getAnalysisComponentsForParent(subItemId);
    for (final component in components) {
      componentCost += component.totalCost;
    }

    if (componentCost > 0) {
      return componentCost * subItem.multiplierRate;
    } else {
      return subItem.quantity * subItem.unitPrice * subItem.multiplierRate;
    }
  }

  // Export/Import Methods

  /// Export all data to a single Map structure
  Map<String, dynamic> exportAllData() {
    return {
      'projects': _projects.map((p) => p.toJson()).toList(),
      'buildings': _buildings.map((b) => b.toJson()).toList(),
      'disciplines': _disciplines.map((d) => d.toJson()).toList(),
      'groups': _groups.map((g) => g.toJson()).toList(),
      'items': _items.map((i) => i.toJson()).toList(),
      'subItems': _subItems.map((si) => si.toJson()).toList(),
      'analysisComponents':
          _analysisComponents.map((ac) => ac.toJson()).toList(),
      'coefficientTemplates':
          _coefficientTemplates.map((ct) => ct.toJson()).toList(),
    };
  }

  /// Export a single project with all its data
  Map<String, dynamic> exportProject(String projectId) {
    final project = getProject(projectId);
    if (project == null) {
      throw Exception('Project not found');
    }

    final buildings = getBuildingsForProject(projectId);
    final List<String> buildingIds = buildings.map((b) => b.id).toList();

    final List<Discipline> disciplines = [];
    final List<Group> groups = [];
    final List<Item> items = [];
    final List<SubItem> subItems = [];
    final List<AnalysisComponent> components = [];

    // Get all disciplines for these buildings
    for (final building in buildings) {
      final buildingDisciplines = getDisciplinesForBuilding(building.id);
      disciplines.addAll(buildingDisciplines);

      // Get all groups for these disciplines
      for (final discipline in buildingDisciplines) {
        final disciplineGroups = getGroupsForDiscipline(discipline.id);
        groups.addAll(disciplineGroups);

        // Get all items for these groups
        for (final group in disciplineGroups) {
          final groupItems = getItemsForGroup(group.id);
          items.addAll(groupItems);

          // Get all sub items and components for these items
          for (final item in groupItems) {
            final itemSubItems = getSubItemsForItem(item.id);
            subItems.addAll(itemSubItems);

            // Get components for the item itself
            components.addAll(getAnalysisComponentsForParent(item.id));

            // Get components for each sub item
            for (final subItem in itemSubItems) {
              components.addAll(getAnalysisComponentsForParent(subItem.id));
            }
          }
        }
      }
    }

    return {
      'project': project.toJson(),
      'buildings': buildings.map((b) => b.toJson()).toList(),
      'disciplines': disciplines.map((d) => d.toJson()).toList(),
      'groups': groups.map((g) => g.toJson()).toList(),
      'items': items.map((i) => i.toJson()).toList(),
      'subItems': subItems.map((si) => si.toJson()).toList(),
      'analysisComponents': components.map((ac) => ac.toJson()).toList(),
    };
  }

  /// Import project data from a Map structure
  Future<void> importProject(Map<String, dynamic> data) async {
    // Import project
    final projectData = data['project'];
    final project = Project.fromJson(projectData);
    await saveProject(project);

    // Import buildings
    for (final buildingData in data['buildings']) {
      final building = Building.fromJson(buildingData);
      await saveBuilding(building);
    }

    // Import disciplines
    for (final disciplineData in data['disciplines']) {
      final discipline = Discipline.fromJson(disciplineData);
      await saveDiscipline(discipline);
    }

    // Import groups
    for (final groupData in data['groups']) {
      final group = Group.fromJson(groupData);
      await saveGroup(group);
    }

    // Import items
    for (final itemData in data['items']) {
      final item = Item.fromJson(itemData);
      await saveItem(item);
    }

    // Import sub items
    for (final subItemData in data['subItems']) {
      final subItem = SubItem.fromJson(subItemData);
      await saveSubItem(subItem);
    }

    // Import analysis components
    for (final componentData in data['analysisComponents']) {
      final component = AnalysisComponent.fromJson(componentData);
      await saveAnalysisComponent(component);
    }
  }
}

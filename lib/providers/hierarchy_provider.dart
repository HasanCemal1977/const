import 'package:flutter/foundation.dart';
import '../models/building.dart';
import '../models/discipline.dart';
import '../models/group.dart';
import '../models/item.dart';
import '../models/sub_item.dart';

// This provider keeps track of the current hierarchy level and selected items
class HierarchyProvider with ChangeNotifier {
  // Current level (1=Project, 2=Building, 3=Discipline, 4=Group, 5=Item, 6=SubItem, 7=Analysis)
  int _currentLevel = 1;

  // Selected IDs at each level
  String? _selectedBuildingId;
  String? _selectedDisciplineId;
  String? _selectedGroupId;
  String? _selectedItemId;
  String? _selectedSubItemId;

  // Navigation history for backtracking
  List<int> _levelHistory = [1];

  // Getters
  int get currentLevel => _currentLevel;
  String? get selectedBuildingId => _selectedBuildingId;
  String? get selectedDisciplineId => _selectedDisciplineId;
  String? get selectedGroupId => _selectedGroupId;
  String? get selectedItemId => _selectedItemId;
  String? get selectedSubItemId => _selectedSubItemId;

  bool get canGoBack => _levelHistory.length > 1;

  // Selected items with their names (for breadcrumb navigation)
  Building? _selectedBuilding;
  Discipline? _selectedDiscipline;
  Group? _selectedGroup;
  Item? _selectedItem;
  SubItem? _selectedSubItem;

  Building? get selectedBuilding => _selectedBuilding;
  Discipline? get selectedDiscipline => _selectedDiscipline;
  Group? get selectedGroup => _selectedGroup;
  Item? get selectedItem => _selectedItem;
  SubItem? get selectedSubItem => _selectedSubItem;

  // Navigate to a specific level
  void navigateToLevel(
    int level, {
    Building? building,
    Discipline? discipline,
    Group? group,
    Item? item,
    SubItem? subItem,
  }) {
    // Store the current level in history for back navigation
    if (_currentLevel != level) {
      _levelHistory.add(_currentLevel);
    }

    _currentLevel = level;

    // Update selected items based on the level
    if (level >= 2 && building != null) {
      _selectedBuildingId = building.id;
      _selectedBuilding = building;
    }

    if (level >= 3 && discipline != null) {
      _selectedDisciplineId = discipline.id;
      _selectedDiscipline = discipline;
    }

    if (level >= 4 && group != null) {
      _selectedGroupId = group.id;
      _selectedGroup = group;
    }

    if (level >= 5 && item != null) {
      _selectedItemId = item.id;
      _selectedItem = item;
    }

    if (level >= 6 && subItem != null) {
      _selectedSubItemId = subItem.id;
      _selectedSubItem = subItem;
    }

    // Clear irrelevant selections
    if (level < 3) {
      _selectedDisciplineId = null;
      _selectedDiscipline = null;
    }

    if (level < 4) {
      _selectedGroupId = null;
      _selectedGroup = null;
    }

    if (level < 5) {
      _selectedItemId = null;
      _selectedItem = null;
    }

    if (level < 6) {
      _selectedSubItemId = null;
      _selectedSubItem = null;
    }

    notifyListeners();
  }

  // Navigate back to the previous level
  void navigateBack() {
    if (_levelHistory.isNotEmpty) {
      final previousLevel = _levelHistory.removeLast();
      _currentLevel = previousLevel;

      // Clear selections based on the new level
      if (_currentLevel < 2) {
        _selectedBuildingId = null;
        _selectedBuilding = null;
      }

      if (_currentLevel < 3) {
        _selectedDisciplineId = null;
        _selectedDiscipline = null;
      }

      if (_currentLevel < 4) {
        _selectedGroupId = null;
        _selectedGroup = null;
      }

      if (_currentLevel < 5) {
        _selectedItemId = null;
        _selectedItem = null;
      }

      if (_currentLevel < 6) {
        _selectedSubItemId = null;
        _selectedSubItem = null;
      }

      notifyListeners();
    }
  }

  // Reset to project level (level 1)
  void resetToProjectLevel() {
    _currentLevel = 1;
    _selectedBuildingId = null;
    _selectedDisciplineId = null;
    _selectedGroupId = null;
    _selectedItemId = null;
    _selectedSubItemId = null;

    _selectedBuilding = null;
    _selectedDiscipline = null;
    _selectedGroup = null;
    _selectedItem = null;
    _selectedSubItem = null;

    _levelHistory = [1];

    notifyListeners();
  }

  // Get the label for the current level (for display purposes)
  String getCurrentLevelLabel() {
    switch (_currentLevel) {
      case 1:
        return 'Project';
      case 2:
        return 'Buildings';
      case 3:
        return 'Disciplines';
      case 4:
        return 'Groups';
      case 5:
        return 'Items';
      case 6:
        return 'Sub Items';
      case 7:
        return 'Analysis';
      default:
        return 'Unknown Level';
    }
  }

  // Get breadcrumb path for navigation
  List<BreadcrumbItem> getBreadcrumbPath() {
    final List<BreadcrumbItem> path = [];

    // Always include Project level
    path.add(BreadcrumbItem(
      level: 1,
      label: 'Project',
      isActive: _currentLevel == 1,
    ));

    if (_selectedBuilding != null) {
      path.add(BreadcrumbItem(
        level: 2,
        label: _selectedBuilding!.name,
        isActive: _currentLevel == 2,
      ));
    }

    if (_selectedDiscipline != null) {
      path.add(BreadcrumbItem(
        level: 3,
        label: _selectedDiscipline!.name,
        isActive: _currentLevel == 3,
      ));
    }

    if (_selectedGroup != null) {
      path.add(BreadcrumbItem(
        level: 4,
        label: _selectedGroup!.name,
        isActive: _currentLevel == 4,
      ));
    }

    if (_selectedItem != null) {
      path.add(BreadcrumbItem(
        level: 5,
        label: _selectedItem!.name,
        isActive: _currentLevel == 5,
      ));
    }

    if (_selectedSubItem != null) {
      path.add(BreadcrumbItem(
        level: 6,
        label: _selectedSubItem!.name,
        isActive: _currentLevel == 6,
      ));
    }

    if (_currentLevel == 7) {
      path.add(BreadcrumbItem(
        level: 7,
        label: 'Analysis',
        isActive: true,
      ));
    }

    return path;
  }
}

class BreadcrumbItem {
  final int level;
  final String label;
  final bool isActive;

  BreadcrumbItem({
    required this.level,
    required this.label,
    required this.isActive,
  });
}

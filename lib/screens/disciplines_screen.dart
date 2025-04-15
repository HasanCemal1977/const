import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/strings.dart';
import '../models/discipline.dart';
import '../models/building.dart';
import '../providers/project_provider.dart';
import '../providers/hierarchy_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hierarchy_list_item.dart';
import '../widgets/add_item_form.dart';
import 'groups_screen.dart';
import '../services/database_service.dart';

class DisciplinesScreen extends StatelessWidget {
  const DisciplinesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final hierarchyProvider = Provider.of<HierarchyProvider>(context);

    final selectedBuildingId = hierarchyProvider.selectedBuildingId;

    if (selectedBuildingId == null) {
      return const Scaffold(
        body: Center(child: Text('No building selected')),
      );
    }

    final building = hierarchyProvider.selectedBuilding;
    final disciplines =
        projectProvider.getDisciplinesForBuilding(selectedBuildingId);
    final breadcrumbs = hierarchyProvider.getBreadcrumbPath();

    return Scaffold(
      appBar: CustomAppBar(
        title: '${building?.name ?? 'Building'} - Disciplines',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                _showAddDisciplineDialog(context, selectedBuildingId),
            tooltip: 'Add Discipline',
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb navigation
          if (breadcrumbs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < breadcrumbs.length; i++) ...[
                      if (i > 0)
                        const Icon(Icons.chevron_right,
                            size: 18, color: AppColors.textLight),
                      InkWell(
                        onTap: breadcrumbs[i].isActive
                            ? null
                            : () {
                                hierarchyProvider
                                    .navigateToLevel(breadcrumbs[i].level);
                                if (breadcrumbs[i].level < 2) {
                                  Navigator.popUntil(
                                      context,
                                      (route) =>
                                          route.settings.name == '/project');
                                } else if (breadcrumbs[i].level < 3) {
                                  Navigator.pop(context);
                                }
                              },
                        child: Text(
                          breadcrumbs[i].label,
                          style: TextStyle(
                            color: breadcrumbs[i].isActive
                                ? AppColors.primary
                                : AppColors.text,
                            fontWeight: breadcrumbs[i].isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Disciplines list
          Expanded(
            child: disciplines.isEmpty
                ? _buildEmptyState(context, selectedBuildingId)
                : _buildDisciplinesList(context, disciplines),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String buildingId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category_outlined,
              size: 80, color: AppColors.level3),
          const SizedBox(height: 16),
          const Text('No Disciplines Added Yet', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          const Text('Add your first discipline to continue',
              style: AppTextStyles.bodyLarge),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.level3),
            onPressed: () => _showAddDisciplineDialog(context, buildingId),
            child: const Text('Add Discipline'),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplinesList(
      BuildContext context, List<Discipline> disciplines) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: disciplines.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final discipline = disciplines[index];
        return HierarchyListItem(
          title: discipline.name,
          subtitle: discipline.description,
          level: 3,
          onTap: () {
            final hierarchyProvider =
                Provider.of<HierarchyProvider>(context, listen: false);
            hierarchyProvider.navigateToLevel(4, discipline: discipline);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GroupsScreen()));
          },
          onEdit: () => _showEditDisciplineDialog(context, discipline),
          onDelete: () => _showDeleteConfirmation(context, discipline),
        );
      },
    );
  }

  void _showAddDisciplineDialog(BuildContext context, String buildingId) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Add Discipline',
        nameLabel: 'Discipline Name',
        descriptionLabel: 'Description (Optional)',
        onSave: (name, description, quantity, multiplierRate) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);
          final discipline = Discipline(
            name: name,
            description: description,
            buildingId: buildingId,
            quantity: quantity,
            multiplierRate: multiplierRate,
          );

          projectProvider.addDiscipline(discipline).then((_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Discipline added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showEditDisciplineDialog(BuildContext context, Discipline discipline) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Edit Discipline',
        nameLabel: 'Discipline Name',
        descriptionLabel: 'Description (Optional)',
        initialName: discipline.name,
        initialDescription: discipline.description,
        initialQuantity: discipline.quantity,
        initialMultiplierRate: discipline.multiplierRate,
        onSave: (name, description, quantity, multiplierRate) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);
          final updatedDiscipline = discipline.copyWith(
            name: name,
            description: description,
            quantity: quantity,
            multiplierRate: multiplierRate,
          );

          projectProvider.updateDiscipline(updatedDiscipline).then((_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Discipline updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Discipline discipline) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Discipline?'),
        content: Text(
          'Are you sure you want to delete "${discipline.name}"? '
          'This will also delete all groups, items, and analysis data associated with it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () {
              final projectProvider =
                  Provider.of<ProjectProvider>(context, listen: false);
              final hierarchyProvider =
                  Provider.of<HierarchyProvider>(context, listen: false);

              final databaseService = DatabaseService();
              final building =
                  databaseService.getBuilding(discipline.buildingId);

              if (building != null) {
                final updatedBuilding = building.copyWith(
                  disciplineIds: building.disciplineIds
                      .where((id) => id != discipline.id)
                      .toList(),
                );

                projectProvider.updateBuilding(updatedBuilding).then((_) {
                  Navigator.pop(context);

                  if (hierarchyProvider.selectedDisciplineId == discipline.id) {
                    hierarchyProvider.navigateToLevel(2, building: building);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Discipline deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                });
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(Strings.delete),
          ),
        ],
      ),
    );
  }
}

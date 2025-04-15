import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/strings.dart';
import '../models/building.dart';
import '../providers/project_provider.dart';
import '../providers/hierarchy_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hierarchy_list_item.dart';
import '../widgets/add_item_form.dart';
import 'disciplines_screen.dart';

class BuildingsScreen extends StatelessWidget {
  const BuildingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final hierarchyProvider = Provider.of<HierarchyProvider>(context);
    final project = projectProvider.currentProject;

    if (project == null) {
      return const Scaffold(
        body: Center(
          child: Text('No project selected'),
        ),
      );
    }

    final buildings = projectProvider.getBuildingsForCurrentProject();
    final breadcrumbs = hierarchyProvider.getBreadcrumbPath();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Buildings',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddBuildingDialog(context, project.id);
            },
            tooltip: 'Add Building',
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
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.textLight,
                        ),
                      InkWell(
                        onTap: breadcrumbs[i].isActive
                            ? null
                            : () {
                                hierarchyProvider.navigateToLevel(
                                  breadcrumbs[i].level,
                                );
                                if (breadcrumbs[i].level < 2) {
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

          // Buildings list
          Expanded(
            child: buildings.isEmpty
                ? _buildEmptyState(context, project.id)
                : _buildBuildingsList(context, buildings),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String projectId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.home_work_outlined,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Buildings Added Yet',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first building to continue',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddBuildingDialog(context, projectId),
            child: const Text('Add Building'),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingsList(BuildContext context, List<Building> buildings) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: buildings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final building = buildings[index];
        return HierarchyListItem(
          title: building.name,
          subtitle: building.description,
          level: 2, // Building level
          onTap: () {
            final hierarchyProvider =
                Provider.of<HierarchyProvider>(context, listen: false);
            hierarchyProvider.navigateToLevel(3, building: building);

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DisciplinesScreen()),
            );
          },
          onEdit: () => _showEditBuildingDialog(context, building),
          onDelete: () => _showDeleteConfirmation(context, building),
        );
      },
    );
  }

  void _showAddBuildingDialog(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Add Building',
        nameLabel: 'Building Name',
        descriptionLabel: 'Description (Optional)',
        onSave: (
          name,
          description,
          quantity,
          multiplierRate, {
          String? unit,
          double? unitPrice,
        }) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);

          final building = Building(
            name: name,
            description: description,
            projectId: projectId,
            quantity: quantity,
            multiplierRate: multiplierRate,
          );

          projectProvider.addBuilding(building).then((_) {
            projectProvider.createDefaultDisciplines(building.id);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Building added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showEditBuildingDialog(BuildContext context, Building building) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Edit Building',
        nameLabel: 'Building Name',
        descriptionLabel: 'Description (Optional)',
        initialName: building.name,
        initialDescription: building.description,
        initialQuantity: building.quantity,
        initialMultiplierRate: building.multiplierRate,
        onSave: (
          name,
          description,
          quantity,
          multiplierRate, {
          String? unit,
          double? unitPrice,
        }) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);

          final updatedBuilding = building.copyWith(
            name: name,
            description: description,
            quantity: quantity,
            multiplierRate: multiplierRate,
          );

          projectProvider.updateBuilding(updatedBuilding).then((_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Building updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Building building) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Building?'),
        content: Text('Are you sure you want to delete "${building.name}"? '
            'This will also delete all disciplines, groups, items and analysis data associated with this building.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () {
              final projectProvider =
                  Provider.of<ProjectProvider>(context, listen: false);
              final project = projectProvider.currentProject;

              if (project != null) {
                // Update the project's buildingIds
                final updatedProject = project.copyWith(
                  buildingIds: project.buildingIds
                      .where((id) => id != building.id)
                      .toList(),
                );

                projectProvider.updateProject(updatedProject).then((_) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Building deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                });
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(Strings.delete),
          ),
        ],
      ),
    );
  }
}

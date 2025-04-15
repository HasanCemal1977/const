import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/strings.dart';
import '../models/discipline.dart';
import '../models/group.dart';
import '../providers/project_provider.dart';
import '../providers/hierarchy_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hierarchy_list_item.dart';
import '../widgets/add_item_form.dart';
import 'items_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final hierarchyProvider = Provider.of<HierarchyProvider>(context);

    final selectedDisciplineId = hierarchyProvider.selectedDisciplineId;

    if (selectedDisciplineId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No discipline selected'),
        ),
      );
    }

    final groups = projectProvider.getGroupsForDiscipline(selectedDisciplineId);
    final breadcrumbs = hierarchyProvider.getBreadcrumbPath();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Groups',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddGroupDialog(context, selectedDisciplineId);
            },
            tooltip: 'Add Group',
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
                                // Navigate back based on level
                                if (breadcrumbs[i].level < 2) {
                                  Navigator.popUntil(
                                    context,
                                    (route) =>
                                        route.settings.name == '/project',
                                  );
                                } else if (breadcrumbs[i].level < 3) {
                                  Navigator.popUntil(
                                    context,
                                    (route) =>
                                        route.settings.name == '/buildings',
                                  );
                                } else if (breadcrumbs[i].level < 4) {
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

          // Groups list
          Expanded(
            child: groups.isEmpty
                ? _buildEmptyState(context, selectedDisciplineId)
                : _buildGroupsList(context, groups),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String disciplineId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_outlined,
            size: 80,
            color: AppColors.level4,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Groups Added Yet',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first group to continue',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.level4,
            ),
            onPressed: () => _showAddGroupDialog(context, disciplineId),
            child: const Text('Add Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(BuildContext context, List<Group> groups) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = groups[index];
        return HierarchyListItem(
          title: group.name,
          subtitle: group.description,
          level: 4, // Group level
          onTap: () {
            final hierarchyProvider =
                Provider.of<HierarchyProvider>(context, listen: false);
            hierarchyProvider.navigateToLevel(5, group: group);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ItemsScreen()),
            );
          },
          onEdit: () => _showEditGroupDialog(context, group),
          onDelete: () => _showDeleteConfirmation(context, group),
        );
      },
    );
  }

  void _showAddGroupDialog(BuildContext context, String disciplineId) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Add Group',
        nameLabel: 'Group Name',
        descriptionLabel: 'Description (Optional)',
        onSave: (name, description, quantity, multiplierRate) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);

          final group = Group(
            name: name,
            description: description,
            disciplineId: disciplineId,
            quantity: quantity,
            multiplierRate: multiplierRate,
          );

          projectProvider.addGroup(group).then((_) {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Group added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Edit Group',
        nameLabel: 'Group Name',
        descriptionLabel: 'Description (Optional)',
        initialName: group.name,
        initialDescription: group.description,
        initialQuantity: group.quantity,
        initialMultiplierRate: group.multiplierRate,
        onSave: (name, description, quantity, multiplierRate) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);

          final updatedGroup = group.copyWith(
            name: name,
            description: description,
            quantity: quantity,
            multiplierRate: multiplierRate,
          );

          projectProvider.updateGroup(updatedGroup).then((_) {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Group updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group?'),
        content: Text('Are you sure you want to delete "${group.name}"? '
            'This will also delete all items and analysis data associated with this group.'),
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

              // Get the discipline
              final databaseService = DatabaseService();
              final discipline =
                  databaseService.getDiscipline(group.disciplineId);

              if (discipline != null) {
                // Update the discipline's groupIds
                final updatedDiscipline = discipline.copyWith(
                  groupIds: discipline.groupIds
                      .where((id) => id != group.id)
                      .toList(),
                );

                projectProvider.updateDiscipline(updatedDiscipline).then((_) {
                  Navigator.pop(context);

                  // If we're deleting the current group, navigate back
                  if (hierarchyProvider.selectedGroupId == group.id) {
                    hierarchyProvider.navigateToLevel(3,
                        discipline: discipline);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group deleted successfully'),
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

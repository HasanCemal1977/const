import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/strings.dart';
import '../models/item.dart';
import '../models/sub_item.dart';
import '../providers/project_provider.dart';
import '../providers/hierarchy_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hierarchy_list_item.dart';
import '../widgets/add_item_form.dart';
import 'analysis_screen.dart';

class SubItemsScreen extends StatelessWidget {
  const SubItemsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final hierarchyProvider = Provider.of<HierarchyProvider>(context);

    final selectedItemId = hierarchyProvider.selectedItemId;

    if (selectedItemId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No item selected'),
        ),
      );
    }

    final subItems = projectProvider.getSubItemsForItem(selectedItemId);
    final breadcrumbs = hierarchyProvider.getBreadcrumbPath();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sub Items',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddSubItemDialog(context, selectedItemId);
            },
            tooltip: 'Add Sub Item',
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
                                  Navigator.popUntil(
                                    context,
                                    (route) =>
                                        route.settings.name == '/disciplines',
                                  );
                                } else if (breadcrumbs[i].level < 5) {
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.settings.name == '/groups',
                                  );
                                } else if (breadcrumbs[i].level < 6) {
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

          // Sub Items list
          Expanded(
            child: subItems.isEmpty
                ? _buildEmptyState(context, selectedItemId)
                : _buildSubItemsList(context, subItems),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String itemId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.list_alt_outlined,
            size: 80,
            color: AppColors.level6,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Sub Items Added Yet',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add sub items for more detailed cost analysis',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.level6,
            ),
            onPressed: () => _showAddSubItemDialog(context, itemId),
            child: const Text('Add Sub Item'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              final hierarchyProvider =
                  Provider.of<HierarchyProvider>(context, listen: false);
              hierarchyProvider.navigateToLevel(7);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalysisScreen()),
              );
            },
            child: const Text('Skip to Analysis'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubItemsList(BuildContext context, List<SubItem> subItems) {
    double totalCost = 0;
    for (var subItem in subItems) {
      totalCost +=
          subItem.quantity * subItem.unitPrice * subItem.multiplierRate;
    }

    return Column(
      children: [
        // Total cost summary
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: AppColors.background,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Cost of Sub Items:',
                    style: AppTextStyles.bodyLarge,
                  ),
                  Text(
                    '\$${totalCost.toStringAsFixed(2)}',
                    style: AppTextStyles.totalCost,
                  ),
                ],
              ),
            ),
          ),
        ),

        // List of sub items
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: subItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final subItem = subItems[index];
              return HierarchyListItem(
                title: subItem.name,
                subtitle: subItem.description.isNotEmpty
                    ? subItem.description
                    : '${subItem.quantity} ${subItem.unit} at ${subItem.unitPrice}',
                level: 6, // Sub Item level
                additionalInfo:
                    'Total: \$${(subItem.quantity * subItem.unitPrice * subItem.multiplierRate).toStringAsFixed(2)}',
                onTap: () {
                  final hierarchyProvider =
                      Provider.of<HierarchyProvider>(context, listen: false);
                  hierarchyProvider.navigateToLevel(7, subItem: subItem);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnalysisScreen()),
                  );
                },
                onEdit: () => _showEditSubItemDialog(context, subItem),
                onDelete: () => _showDeleteConfirmation(context, subItem),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddSubItemDialog(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Add Sub Item',
        nameLabel: 'Sub Item Name',
        descriptionLabel: 'Description (Optional)',
        includeUnitPrice: true,
        includeUnit: true,
        onSave: (name, description, quantity, multiplierRate,
            {String? unit, double? unitPrice}) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);

          final subItem = SubItem(
            name: name,
            description: description,
            itemId: itemId,
            quantity: quantity,
            unit: unit ?? '',
            unitPrice: unitPrice ?? 0.0,
            multiplierRate: multiplierRate,
          );

          projectProvider.addSubItem(subItem).then((_) {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sub Item added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showEditSubItemDialog(BuildContext context, SubItem subItem) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Edit Sub Item',
        nameLabel: 'Sub Item Name',
        descriptionLabel: 'Description (Optional)',
        initialName: subItem.name,
        initialDescription: subItem.description,
        initialQuantity: subItem.quantity,
        initialMultiplierRate: subItem.multiplierRate,
        includeUnitPrice: true,
        includeUnit: true,
        initialUnit: subItem.unit,
        initialUnitPrice: subItem.unitPrice,
        onSave: (name, description, quantity, multiplierRate,
            {String? unit, double? unitPrice}) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);

          final updatedSubItem = subItem.copyWith(
            name: name,
            description: description,
            quantity: quantity,
            unit: unit ?? subItem.unit,
            unitPrice: unitPrice ?? subItem.unitPrice,
            multiplierRate: multiplierRate,
          );

          projectProvider.updateSubItem(updatedSubItem).then((_) {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sub Item updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SubItem subItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sub Item?'),
        content: Text('Are you sure you want to delete "${subItem.name}"? '
            'This will also delete all analysis data associated with this sub item.'),
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

              // Get the item
              final databaseService = DatabaseService();
              final item = databaseService.getItem(subItem.itemId);

              if (item != null) {
                // Update the item's subItemIds
                final updatedSubItemIds =
                    item.subItemIds.where((id) => id != subItem.id).toList();

                final updatedItem = item.copyWith(
                  subItemIds: updatedSubItemIds,
                  hasSubItems: updatedSubItemIds.isNotEmpty,
                );

                projectProvider.updateItem(updatedItem).then((_) {
                  Navigator.pop(context);

                  // If we're deleting the current sub item, navigate back
                  if (hierarchyProvider.selectedSubItemId == subItem.id) {
                    hierarchyProvider.navigateToLevel(5, item: item);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sub Item deleted successfully'),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/strings.dart';
import '../models/group.dart';
import '../models/item.dart';
import '../providers/project_provider.dart';
import '../providers/hierarchy_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hierarchy_list_item.dart';
import '../widgets/add_item_form.dart';
import 'sub_items_screen.dart';
import 'analysis_screen.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final hierarchyProvider = Provider.of<HierarchyProvider>(context);

    final selectedGroupId = hierarchyProvider.selectedGroupId;

    if (selectedGroupId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No group selected'),
        ),
      );
    }

    final items = projectProvider.getItemsForGroup(selectedGroupId);
    final breadcrumbs = hierarchyProvider.getBreadcrumbPath();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Items',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddItemDialog(context, selectedGroupId);
            },
            tooltip: 'Add Item',
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

          // Items list
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState(context, selectedGroupId)
                : _buildItemsList(context, items),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String groupId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.level5,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Items Added Yet',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first BoQ item to continue',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.level5,
            ),
            onPressed: () => _showAddItemDialog(context, groupId),
            child: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, List<Item> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return HierarchyListItem(
          title: item.name,
          subtitle: item.description.isNotEmpty
              ? item.description
              : '${item.quantity} ${item.unit} at ${item.unitPrice}',
          level: 5, // Item level
          additionalInfo:
              'Total: \$${(item.quantity * item.unitPrice * item.multiplierRate).toStringAsFixed(2)}',
          onTap: () {
            final hierarchyProvider =
                Provider.of<HierarchyProvider>(context, listen: false);
            hierarchyProvider.navigateToLevel(6, item: item);

            if (item.hasSubItems) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubItemsScreen()),
              );
            } else {
              // If no sub items, go directly to analysis
              hierarchyProvider.navigateToLevel(7, item: item);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalysisScreen()),
              );
            }
          },
          onEdit: () => _showEditItemDialog(context, item),
          onDelete: () => _showDeleteConfirmation(context, item),
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Add Item',
        nameLabel: 'Item Name',
        descriptionLabel: 'Description (Optional)',
        includeUnitPrice: true,
        includeUnit: true,
        onSave: (name, description, quantity, multiplierRate,
            {String? unit, double? unitPrice}) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);

          final item = Item(
            name: name,
            description: description,
            groupId: groupId,
            quantity: quantity,
            unit: unit ?? '',
            unitPrice: unitPrice ?? 0.0,
            multiplierRate: multiplierRate,
          );

          projectProvider.addItem(item).then((_) {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AddItemForm(
        title: 'Edit Item',
        nameLabel: 'Item Name',
        descriptionLabel: 'Description (Optional)',
        initialName: item.name,
        initialDescription: item.description,
        initialQuantity: item.quantity,
        initialMultiplierRate: item.multiplierRate,
        includeUnitPrice: true,
        includeUnit: true,
        initialUnit: item.unit,
        initialUnitPrice: item.unitPrice,
        onSave: (name, description, quantity, multiplierRate,
            {String? unit, double? unitPrice}) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);

          final updatedItem = item.copyWith(
            name: name,
            description: description,
            quantity: quantity,
            unit: unit ?? item.unit,
            unitPrice: unitPrice ?? item.unitPrice,
            multiplierRate: multiplierRate,
          );

          projectProvider.updateItem(updatedItem).then((_) {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to delete "${item.name}"? '
            'This will also delete all sub items and analysis data associated with this item.'),
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

              // Get the group
              final databaseService = DatabaseService();
              final group = databaseService.getGroup(item.groupId);

              if (group != null) {
                // Update the group's itemIds
                final updatedGroup = group.copyWith(
                  itemIds: group.itemIds.where((id) => id != item.id).toList(),
                );

                projectProvider.updateGroup(updatedGroup).then((_) {
                  Navigator.pop(context);

                  // If we're deleting the current item, navigate back
                  if (hierarchyProvider.selectedItemId == item.id) {
                    hierarchyProvider.navigateToLevel(4, group: group);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted successfully'),
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

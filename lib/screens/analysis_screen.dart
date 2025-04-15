import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/strings.dart';
import '../models/item.dart';
import '../models/sub_item.dart';
import '../models/analysis_component.dart';
import '../providers/project_provider.dart';
import '../providers/hierarchy_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/validators.dart';
import '../services/database_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1.0');
  final _unitController = TextEditingController();
  final _priceController = TextEditingController(text: '0.0');
  final _massController = TextEditingController();
  final _originController = TextEditingController();
  final _manhourController = TextEditingController();

  String _componentType = 'Material';

  bool _isAddingComponent = false;

  final List<String> _componentTypes = [
    'Material',
    'Labour',
    'Equipment',
    'Transportation',
    'Consumable Material',
    'Sub Contractors'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _massController.dispose();
    _originController.dispose();
    _manhourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final hierarchyProvider = Provider.of<HierarchyProvider>(context);

    final selectedItemId = hierarchyProvider.selectedItemId;
    final selectedSubItemId = hierarchyProvider.selectedSubItemId;

    // We need either an item or a sub-item
    if (selectedItemId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No item selected'),
        ),
      );
    }

    // Determine the parent and get components
    final String parentId = selectedSubItemId ?? selectedItemId;
    final components = projectProvider.getAnalysisComponentsForParent(parentId);
    final breadcrumbs = hierarchyProvider.getBreadcrumbPath();

    // Get parent name for display
    String parentName = '';
    final databaseService = DatabaseService();
    if (selectedSubItemId != null) {
      final subItem = databaseService.getSubItem(selectedSubItemId);
      if (subItem != null) {
        parentName = subItem.name;
      }
    } else {
      final item = databaseService.getItem(selectedItemId);
      if (item != null) {
        parentName = item.name;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Analysis: $parentName',
        showBackButton: true,
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
                                if (breadcrumbs[i].level <
                                    hierarchyProvider.currentLevel) {
                                  Navigator.popUntil(
                                    context,
                                    (route) =>
                                        route.settings.name == null ||
                                        route.settings.name == '/project',
                                  );
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

          // Component Form or List
          Expanded(
            child: _isAddingComponent
                ? _buildComponentForm(context, parentId)
                : _buildComponentsList(context, components, parentId),
          ),
        ],
      ),
      floatingActionButton: !_isAddingComponent
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _resetForm();
                  _isAddingComponent = true;
                });
              },
              backgroundColor: AppColors.level7,
              child: const Icon(Icons.add),
              tooltip: 'Add Analysis Component',
            )
          : null,
    );
  }

  Widget _buildComponentsList(BuildContext context,
      List<AnalysisComponent> components, String parentId) {
    if (components.isEmpty) {
      return _buildEmptyState(context);
    }

    // Calculate total cost
    double totalCost = 0;
    for (var component in components) {
      totalCost += component.totalCost;
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Analysis Cost:',
                        style: AppTextStyles.bodyLarge,
                      ),
                      Text(
                        '\$${totalCost.toStringAsFixed(2)}',
                        style: AppTextStyles.totalCost,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Show type breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCostTypeIndicator(
                          'Material', components, AppColors.primary),
                      _buildCostTypeIndicator(
                          'Labour', components, AppColors.secondary),
                      _buildCostTypeIndicator(
                          'Equipment', components, AppColors.level4),
                      _buildCostTypeIndicator(
                          'Transportation', components, AppColors.level7),
                      _buildCostTypeIndicator(
                          'Consumable Material', components, AppColors.level2),
                      _buildCostTypeIndicator(
                          'Sub Contractors', components, AppColors.level5),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Component list by type
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Group components by type
              for (final type in _componentTypes)
                if (components.any((c) => c.componentType == type)) ...[
                  _buildComponentTypeHeader(type),
                  const SizedBox(height: 8),
                  ...components.where((c) => c.componentType == type).map(
                      (component) =>
                          _buildComponentListItem(context, component)),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostTypeIndicator(
      String type, List<AnalysisComponent> components, Color color) {
    double typeCost = 0;
    for (var c in components.where((c) => c.componentType == type)) {
      typeCost += c.totalCost;
    }

    return Column(
      children: [
        Text(
          type,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          '\$${typeCost.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildComponentTypeHeader(String type) {
    Color color;
    IconData icon;

    switch (type) {
      case 'Material':
        color = AppColors.primary;
        icon = Icons.inventory;
        break;
      case 'Labour':
        color = AppColors.secondary;
        icon = Icons.people;
        break;
      case 'Equipment':
        color = AppColors.level4;
        icon = Icons.construction;
        break;
      case 'Transportation':
        color = AppColors.level7;
        icon = Icons.local_shipping;
        break;
      default:
        color = AppColors.text;
        icon = Icons.category;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            type,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentListItem(
      BuildContext context, AnalysisComponent component) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getColorForComponentType(component.componentType)
              .withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    component.name,
                    style: AppTextStyles.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorForComponentType(component.componentType)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getColorForComponentType(component.componentType)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    component.componentType,
                    style: TextStyle(
                      color: _getColorForComponentType(component.componentType),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (component.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                component.description,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _buildComponentInfoItem('Quantity', '${component.quantity}'),
                _buildComponentInfoItem('Unit', component.unit),
                _buildComponentInfoItem('Price', '\$${component.unitPrice}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildComponentInfoItem('Mass', '${component.mass}'),
                if (component.origin.isNotEmpty)
                  _buildComponentInfoItem('Origin', component.origin),
                if (component.manhours > 0)
                  _buildComponentInfoItem('Man Hours', '${component.manhours}'),
                const Spacer(),
                Text(
                  'Total: \$${component.totalCost.toStringAsFixed(2)}',
                  style: AppTextStyles.totalCost.copyWith(
                    fontSize: 14,
                    color: _getColorForComponentType(component.componentType),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editComponent(context, component),
                  color: AppColors.text,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _showDeleteConfirmation(context, component),
                  color: Colors.red,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.analytics_outlined,
            size: 80,
            color: AppColors.level7,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Analysis Components Added',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add materials, labour, equipment, and transportation costs',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.level7,
            ),
            onPressed: () {
              setState(() {
                _resetForm();
                _isAddingComponent = true;
              });
            },
            child: const Text('Add Component'),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentForm(BuildContext context, String parentId) {
    final isMaterial = _componentType == 'Material';
    final isLabour = _componentType == 'Labour';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form title
            Text(
              'Add Analysis Component',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),

            // Component Type
            DropdownButtonFormField<String>(
              value: _componentType,
              decoration: const InputDecoration(
                labelText: 'Component Type',
                border: OutlineInputBorder(),
              ),
              items: _componentTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _componentType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter component name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.validateRequired(value, 'Name'),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Quantity and Unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        Validators.validateDouble(value, 'Quantity'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'e.g., m³, kg, hrs',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        Validators.validateRequired(value, 'Unit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price per Unit',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => Validators.validateDouble(value, 'Price'),
            ),
            const SizedBox(height: 16),

            // Mass (for Material)
            if (isMaterial)
              TextFormField(
                controller: _massController,
                decoration: const InputDecoration(
                  labelText: 'Mass (Optional)',
                  hintText: 'Enter mass in kg',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            if (isMaterial) const SizedBox(height: 16),

            // Origin (for Material and Transportation)
            if (isMaterial || _componentType == 'Transportation')
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Origin (Optional)',
                  hintText: 'Enter origin/source',
                  border: OutlineInputBorder(),
                ),
              ),
            if (isMaterial || _componentType == 'Transportation')
              const SizedBox(height: 16),

            // Man Hours (for Labour)
            if (isLabour)
              TextFormField(
                controller: _manhourController,
                decoration: const InputDecoration(
                  labelText: 'Man Hours',
                  hintText: 'Enter labor hours',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (isLabour) {
                    return Validators.validateDouble(value, 'Man Hours');
                  }
                  return null;
                },
              ),
            if (isLabour) const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingComponent = false;
                    });
                  },
                  child: const Text(Strings.cancel),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getColorForComponentType(_componentType),
                  ),
                  onPressed: () => _saveComponent(context, parentId),
                  child: const Text(Strings.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveComponent(BuildContext context, String parentId) {
    if (_formKey.currentState!.validate()) {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);

      final double mass = _massController.text.isNotEmpty
          ? double.tryParse(_massController.text) ?? 0.0
          : 0.0;

      final double manhours = _manhourController.text.isNotEmpty
          ? double.tryParse(_manhourController.text) ?? 0.0
          : 0.0;

      final component = AnalysisComponent(
        parentId: parentId,
        name: _nameController.text,
        description: _descriptionController.text,
        componentType: _componentType,
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text,
        unitPrice: double.parse(_priceController.text),
        mass: mass,
        origin: _originController.text,
        manhours: manhours,
      );

      projectProvider.addAnalysisComponent(component).then((_) {
        setState(() {
          _isAddingComponent = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Component added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      });
    }
  }

  void _editComponent(BuildContext context, AnalysisComponent component) {
    // Set form values to the component's values
    _nameController.text = component.name;
    _descriptionController.text = component.description;
    _componentType = component.componentType;
    _quantityController.text = component.quantity.toString();
    _unitController.text = component.unit;
    _priceController.text = component.unitPrice.toString();

    // mass is now non-nullable
    _massController.text = component.mass.toString();

    // origin is now non-nullable
    _originController.text = component.origin;

    // manhours is now non-nullable and renamed
    _manhourController.text = component.manhours.toString();

    setState(() {
      _isAddingComponent = true;
    });
  }

  void _showDeleteConfirmation(
      BuildContext context, AnalysisComponent component) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Component?'),
        content: Text('Are you sure you want to delete "${component.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () {
              final projectProvider =
                  Provider.of<ProjectProvider>(context, listen: false);

              projectProvider.deleteAnalysisComponent(component.id).then((_) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Component deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              });
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

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _quantityController.text = '1.0';
    _unitController.clear();
    _priceController.text = '0.0';
    _massController.clear();
    _originController.clear();
    _manhourController.clear();
    _componentType = 'Material';
  }

  Color _getColorForComponentType(String type) {
    switch (type) {
      case 'Material':
        return AppColors.primary;
      case 'Labour':
        return AppColors.secondary;
      case 'Equipment':
        return AppColors.level4;
      case 'Transportation':
        return AppColors.level7;
      default:
        return AppColors.primary;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/coefficient_template.dart';
import '../providers/project_provider.dart';
import '../widgets/custom_app_bar.dart';

class CoefficientTemplatesScreen extends StatefulWidget {
  const CoefficientTemplatesScreen({Key? key}) : super(key: key);

  @override
  State<CoefficientTemplatesScreen> createState() =>
      _CoefficientTemplatesScreenState();
}

class _CoefficientTemplatesScreenState
    extends State<CoefficientTemplatesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _materialController = TextEditingController(text: '1.0');
  final _labourController = TextEditingController(text: '1.0');
  final _equipmentController = TextEditingController(text: '1.0');
  final _transportationController = TextEditingController(text: '1.0');
  final _consumableMaterialController = TextEditingController(text: '1.0');
  final _subContractorsController = TextEditingController(text: '1.0');

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _materialController.dispose();
    _labourController.dispose();
    _equipmentController.dispose();
    _transportationController.dispose();
    _consumableMaterialController.dispose();
    _subContractorsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final templates = projectProvider.coefficientTemplates;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Coefficient Templates',
        showBackButton: true,
      ),
      body: templates.isEmpty
          ? _buildEmptyState(context)
          : _buildTemplatesList(context, templates),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTemplateDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calculate_outlined,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Coefficient Templates',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first coefficient template to get started',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateTemplateDialog(context),
            child: const Text('Create Template'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList(
      BuildContext context, List<CoefficientTemplate> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Your Coefficient Templates',
            style: AppTextStyles.heading3,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () => _showEditTemplateDialog(context, template),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                template.name,
                                style: AppTextStyles.heading4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Template',
                              onPressed: () =>
                                  _showDeleteTemplateDialog(context, template),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        if (template.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            template.description,
                            style: AppTextStyles.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildCoefficientChip(
                                'Material', template.materialCoefficient),
                            _buildCoefficientChip(
                                'Labour', template.labourCoefficient),
                            _buildCoefficientChip(
                                'Equipment', template.equipmentCoefficient),
                            _buildCoefficientChip('Transportation',
                                template.transportationCoefficient),
                            _buildCoefficientChip('Consumable',
                                template.consumableMaterialCoefficient),
                            _buildCoefficientChip('Sub Contractors',
                                template.subContractorsCoefficient),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCoefficientChip(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(2)}',
        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  void _showCreateTemplateDialog(BuildContext context) {
    // Reset form fields
    _nameController.clear();
    _descriptionController.clear();
    _materialController.text = '1.0';
    _labourController.text = '1.0';
    _equipmentController.text = '1.0';
    _transportationController.text = '1.0';
    _consumableMaterialController.text = '1.0';
    _subContractorsController.text = '1.0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Coefficient Template'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'Enter template name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a template name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter template description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildCoefficientField(
                    'Material Coefficient', _materialController),
                const SizedBox(height: 8),
                _buildCoefficientField('Labour Coefficient', _labourController),
                const SizedBox(height: 8),
                _buildCoefficientField(
                    'Equipment Coefficient', _equipmentController),
                const SizedBox(height: 8),
                _buildCoefficientField(
                    'Transportation Coefficient', _transportationController),
                const SizedBox(height: 8),
                _buildCoefficientField('Consumable Material Coefficient',
                    _consumableMaterialController),
                const SizedBox(height: 8),
                _buildCoefficientField(
                    'Sub Contractors Coefficient', _subContractorsController),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _createTemplate(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditTemplateDialog(
      BuildContext context, CoefficientTemplate template) {
    // Set form fields with template values
    _nameController.text = template.name;
    _descriptionController.text = template.description;
    _materialController.text = template.materialCoefficient.toString();
    _labourController.text = template.labourCoefficient.toString();
    _equipmentController.text = template.equipmentCoefficient.toString();
    _transportationController.text =
        template.transportationCoefficient.toString();
    _consumableMaterialController.text =
        template.consumableMaterialCoefficient.toString();
    _subContractorsController.text =
        template.subContractorsCoefficient.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Coefficient Template'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'Enter template name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a template name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter template description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildCoefficientField(
                    'Material Coefficient', _materialController),
                const SizedBox(height: 8),
                _buildCoefficientField('Labour Coefficient', _labourController),
                const SizedBox(height: 8),
                _buildCoefficientField(
                    'Equipment Coefficient', _equipmentController),
                const SizedBox(height: 8),
                _buildCoefficientField(
                    'Transportation Coefficient', _transportationController),
                const SizedBox(height: 8),
                _buildCoefficientField('Consumable Material Coefficient',
                    _consumableMaterialController),
                const SizedBox(height: 8),
                _buildCoefficientField(
                    'Sub Contractors Coefficient', _subContractorsController),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updateTemplate(context, template);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoefficientField(
      String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter coefficient value',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        try {
          final double number = double.parse(value);
          if (number <= 0) {
            return 'Value must be greater than 0';
          }
        } catch (_) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  void _createTemplate(BuildContext context) {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);

    final template = CoefficientTemplate(
      name: _nameController.text,
      description: _descriptionController.text,
      materialCoefficient: double.parse(_materialController.text),
      labourCoefficient: double.parse(_labourController.text),
      equipmentCoefficient: double.parse(_equipmentController.text),
      transportationCoefficient: double.parse(_transportationController.text),
      consumableMaterialCoefficient:
          double.parse(_consumableMaterialController.text),
      subContractorsCoefficient: double.parse(_subContractorsController.text),
    );

    projectProvider.addCoefficientTemplate(template);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template "${template.name}" created successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateTemplate(BuildContext context, CoefficientTemplate template) {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);

    final updatedTemplate = template.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      materialCoefficient: double.parse(_materialController.text),
      labourCoefficient: double.parse(_labourController.text),
      equipmentCoefficient: double.parse(_equipmentController.text),
      transportationCoefficient: double.parse(_transportationController.text),
      consumableMaterialCoefficient:
          double.parse(_consumableMaterialController.text),
      subContractorsCoefficient: double.parse(_subContractorsController.text),
    );

    projectProvider.updateCoefficientTemplate(updatedTemplate);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Template "${updatedTemplate.name}" updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteTemplateDialog(
      BuildContext context, CoefficientTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
          'Are you sure you want to delete "${template.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final projectProvider =
                  Provider.of<ProjectProvider>(context, listen: false);
              projectProvider.deleteCoefficientTemplate(template.id);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Template "${template.name}" deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/strings.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../providers/hierarchy_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/cost_summary_card.dart';
import 'buildings_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({Key? key}) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _clientController = TextEditingController();
  final _contractorController = TextEditingController();
  String _status = 'Planning';
  late DateTime _startDate;
  DateTime? _endDate;

  bool _isEditing = false;

  // Status options
  final List<String> _statusOptions = [
    'Planning',
    'In Progress',
    'On Hold',
    'Completed',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();

    // Reset hierarchy to project level
    final hierarchyProvider =
        Provider.of<HierarchyProvider>(context, listen: false);
    hierarchyProvider.resetToProjectLevel();

    _loadProjectData();
  }

  void _loadProjectData() {
    final project =
        Provider.of<ProjectProvider>(context, listen: false).currentProject;

    if (project != null) {
      _nameController.text = project.name;
      _descriptionController.text = project.description;
      _locationController.text = project.location;
      _clientController.text = project.client;
      _contractorController.text = project.contractor;
      _status = project.status;
      _startDate = project.startDate;
      _endDate = project.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _clientController.dispose();
    _contractorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final project = projectProvider.currentProject;

    if (project == null) {
      return const Scaffold(
        body: Center(
          child: Text('No project selected'),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Project' : project.name,
        showBackButton: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  _loadProjectData();
                });
              },
            ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _isEditing
          ? _buildEditForm(context, project)
          : _buildProjectDetails(context, project),
      floatingActionButton: !_isEditing
          ? FloatingActionButton(
              onPressed: () => _navigateToBuildingsScreen(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.arrow_forward),
              tooltip: 'Go to Buildings',
            )
          : null,
    );
  }

  Widget _buildProjectDetails(BuildContext context, Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Project Details',
                        style: AppTextStyles.heading3,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(project.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          project.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildDetailItem(
                      'Description',
                      project.description.isNotEmpty
                          ? project.description
                          : 'No description provided'),
                  _buildDetailItem(
                      'Location',
                      project.location.isNotEmpty
                          ? project.location
                          : 'No location specified'),
                  _buildDetailItem(
                      'Client',
                      project.client.isNotEmpty
                          ? project.client
                          : 'No client specified'),
                  _buildDetailItem(
                      'Contractor',
                      project.contractor.isNotEmpty
                          ? project.contractor
                          : 'No contractor specified'),
                  _buildDetailItem(
                      'Start Date', _formatDate(project.startDate)),
                  if (project.endDate != null)
                    _buildDetailItem('End Date', _formatDate(project.endDate!)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CostSummaryCard(
            title: 'Project Cost Summary',
            quantity: project.quantity,
            multiplierRate: project.multiplierRate,
            totalCost: project.totalCost,
            onEdit: () {
              _showQuantityMultiplierDialog(context, project);
            },
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Buildings',
                        style: AppTextStyles.heading3,
                      ),
                      TextButton.icon(
                        onPressed: () => _navigateToBuildingsScreen(context),
                        icon: const Icon(Icons.visibility),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildBuildingSummary(context, project),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingSummary(BuildContext context, Project project) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final buildings = projectProvider.getBuildingsForCurrentProject();

    if (buildings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.home_work_outlined,
                size: 48,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 16),
              const Text(
                'No buildings added yet',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _navigateToBuildingsScreen(context),
                child: const Text('Add Buildings'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < buildings.length; i++)
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  buildings[i].name,
                  style: AppTextStyles.bodyLarge,
                ),
                subtitle: Text(
                  buildings[i].description.isNotEmpty
                      ? buildings[i].description
                      : 'No description',
                  style: AppTextStyles.bodySmall,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  final hierarchyProvider =
                      Provider.of<HierarchyProvider>(context, listen: false);
                  hierarchyProvider.navigateToLevel(2, building: buildings[i]);
                  _navigateToBuildingsScreen(context);
                },
              ),
              if (i < buildings.length - 1) const Divider(),
            ],
          ),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context, Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'Enter project name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter project description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter project location',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clientController,
              decoration: const InputDecoration(
                labelText: 'Client',
                hintText: 'Enter client name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contractorController,
              decoration: const InputDecoration(
                labelText: 'Contractor',
                hintText: 'Enter contractor name',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _status = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectStartDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                ),
                child: Text(_formatDate(_startDate)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectEndDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Date (Optional)',
                ),
                child: Text(_endDate != null
                    ? _formatDate(_endDate!)
                    : 'Not specified'),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  child: const Text(Strings.cancel),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _updateProject(context, project);
                    }
                  },
                  child: const Text(Strings.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;

        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _updateProject(BuildContext context, Project project) {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);

    final updatedProject = project.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      client: _clientController.text,
      contractor: _contractorController.text,
      status: _status,
      startDate: _startDate,
      endDate: _endDate,
    );

    projectProvider.updateProject(updatedProject).then((_) {
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  void _showQuantityMultiplierDialog(BuildContext context, Project project) {
    final quantityController =
        TextEditingController(text: project.quantity.toString());
    final multiplierController =
        TextEditingController(text: project.multiplierRate.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Cost Factors'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: multiplierController,
              decoration: const InputDecoration(
                labelText: 'Multiplier Rate',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final projectProvider =
                  Provider.of<ProjectProvider>(context, listen: false);

              final double quantity =
                  double.tryParse(quantityController.text) ?? project.quantity;
              final double multiplierRate =
                  double.tryParse(multiplierController.text) ??
                      project.multiplierRate;

              final updatedProject = project.copyWith(
                quantity: quantity,
                multiplierRate: multiplierRate,
              );

              projectProvider.updateProject(updatedProject).then((_) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cost factors updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              });
            },
            child: const Text(Strings.save),
          ),
        ],
      ),
    );
  }

  void _navigateToBuildingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BuildingsScreen()),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Colors.blue;
      case 'in progress':
        return Colors.amber;
      case 'on hold':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

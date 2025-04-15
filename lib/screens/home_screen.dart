import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/strings.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import 'project_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _clientController = TextEditingController();
  final _contractorController = TextEditingController();
  DateTime _startDate = DateTime.now();

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
    final projects = projectProvider.projects;

    return Scaffold(
      appBar: const CustomAppBar(
        title: Strings.appName,
        showBackButton: false,
      ),
      drawer: const CustomDrawer(),
      body: projectProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : projects.isEmpty
              ? _buildEmptyState(context)
              : _buildProjectList(context, projects),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
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
            Icons.bubble_chart,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            Strings.welcome,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first construction project to get started',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateProjectDialog(context),
            child: Text(Strings.startNewProject),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, List<Project> projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Your Projects',
            style: AppTextStyles.heading3,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () {
                    final projectProvider =
                        Provider.of<ProjectProvider>(context, listen: false);
                    projectProvider.setCurrentProject(project.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProjectScreen()),
                    );
                  },
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
                                project.name,
                                style: AppTextStyles.heading4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'Delete Project',
                                  onPressed: () => _showDeleteProjectDialog(
                                      context, project),
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
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
                          ],
                        ),
                        if (project.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            project.description,
                            style: AppTextStyles.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              project.location.isNotEmpty
                                  ? project.location
                                  : 'No location',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.calendar_today,
                                size: 16, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatDate(project.startDate)}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person,
                                size: 16, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              'Client: ${project.client.isNotEmpty ? project.client : 'Not specified'}',
                              style: AppTextStyles.bodySmall,
                            ),
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

  void _showCreateProjectDialog(BuildContext context) {
    // Reset form fields
    _nameController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _clientController.clear();
    _contractorController.clear();
    _startDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                    ),
                    child: Text(_formatDate(_startDate)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _createProject(context);
              }
            },
            child: const Text(Strings.create),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _createProject(BuildContext context) {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);

    final newProject = Project(
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      client: _clientController.text,
      contractor: _contractorController.text,
      startDate: _startDate,
      status: 'Planning',
    );

    projectProvider.createProject(newProject).then((_) {
      Navigator.pop(context); // Close dialog
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProjectScreen()),
      );
    });
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
      case 'completed':
        return Colors.green;
      case 'on hold':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteProjectDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${project.name}"? '
          'This will delete all associated buildings, disciplines, groups, items, and analysis components. '
          'This action cannot be undone.',
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
              projectProvider.deleteProject(project.id).then((_) {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Project "${project.name}" deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              });
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

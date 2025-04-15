import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/strings.dart';
import '../providers/project_provider.dart';
import '../providers/hierarchy_provider.dart';
import '../models/project.dart';
import '../screens/home_screen.dart';
import '../screens/project_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final hierarchyProvider = Provider.of<HierarchyProvider>(context);
    final currentProject = projectProvider.currentProject;
    final projects = projectProvider.projects;

    return Drawer(
      child: Column(
        children: [
          // Drawer header with app name
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      Strings.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Close drawer button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Current project indicator
                if (currentProject != null) ...[
                  const Text(
                    'Current Project:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentProject.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  const Text(
                    'No Project Selected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Drawer items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false, // Remove all previous routes
                    );
                  },
                ),
                if (currentProject != null) ...[
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Project Dashboard',
                    onTap: () {
                      hierarchyProvider.resetToProjectLevel();
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProjectScreen(),
                          settings: const RouteSettings(name: '/project'),
                        ),
                        (route) => route.isFirst, // Keep only the first route
                      );
                    },
                  ),
                ],

                // Hierarchy navigation if a project is selected
                if (currentProject != null) ...[
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'PROJECT HIERARCHY',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Navigate to project level
                  _buildHierarchyItem(
                    context: context,
                    level: 1,
                    title: 'Project',
                    currentLevel: hierarchyProvider.currentLevel,
                    onTap: () {
                      hierarchyProvider.resetToProjectLevel();
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProjectScreen(),
                          settings: const RouteSettings(name: '/project'),
                        ),
                        (route) => route.isFirst, // Keep only the first route
                      );
                    },
                  ),

                  // Navigate to buildings level
                  _buildHierarchyItem(
                    context: context,
                    level: 2,
                    title: 'Buildings',
                    currentLevel: hierarchyProvider.currentLevel,
                    onTap: () {
                      if (hierarchyProvider.currentLevel < 2) {
                        // We need to navigate to buildings from project level
                        final buildings =
                            projectProvider.getBuildingsForCurrentProject();
                        if (buildings.isNotEmpty) {
                          hierarchyProvider.navigateToLevel(2,
                              building: buildings.first);
                        } else {
                          hierarchyProvider.navigateToLevel(2);
                        }
                      }

                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/buildings');
                    },
                  ),

                  // Navigate to disciplines level (if a building is selected)
                  if (hierarchyProvider.selectedBuildingId != null)
                    _buildHierarchyItem(
                      context: context,
                      level: 3,
                      title: 'Disciplines',
                      currentLevel: hierarchyProvider.currentLevel,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/disciplines');
                      },
                    ),

                  // Navigate to groups level (if a discipline is selected)
                  if (hierarchyProvider.selectedDisciplineId != null)
                    _buildHierarchyItem(
                      context: context,
                      level: 4,
                      title: 'Groups',
                      currentLevel: hierarchyProvider.currentLevel,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/groups');
                      },
                    ),

                  // Navigate to items level (if a group is selected)
                  if (hierarchyProvider.selectedGroupId != null)
                    _buildHierarchyItem(
                      context: context,
                      level: 5,
                      title: 'Items',
                      currentLevel: hierarchyProvider.currentLevel,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/items');
                      },
                    ),

                  // Navigate to sub items level (if an item is selected and has sub items)
                  if (hierarchyProvider.selectedItemId != null)
                    _buildHierarchyItem(
                      context: context,
                      level: 6,
                      title: 'Sub Items',
                      currentLevel: hierarchyProvider.currentLevel,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/subitems');
                      },
                    ),

                  // Navigate to analysis level (if an item or sub item is selected)
                  if (hierarchyProvider.selectedItemId != null ||
                      hierarchyProvider.selectedSubItemId != null)
                    _buildHierarchyItem(
                      context: context,
                      level: 7,
                      title: 'Analysis',
                      currentLevel: hierarchyProvider.currentLevel,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/analysis');
                      },
                    ),
                ],

                const Divider(),

                // Projects section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'YOUR PROJECTS',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // List of projects
                if (projects.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'No projects created yet',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...projects.map((project) => _buildProjectItem(
                        context: context,
                        project: project,
                        isSelected: currentProject?.id == project.id,
                        onTap: () {
                          // Change project
                          projectProvider.setCurrentProject(project.id);
                          hierarchyProvider.resetToProjectLevel();

                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProjectScreen(),
                              settings: const RouteSettings(name: '/project'),
                            ),
                            (route) =>
                                route.isFirst, // Keep only the first route
                          );
                        },
                      )),

                const SizedBox(height: 8),
                // Create new project button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('New Project'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );

                      // Show create project dialog (simulate a tap on the FAB)
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        // Trigger the create project dialog
                        // This would need to be implemented in the HomeScreen
                        // For now, we just navigate to the HomeScreen
                      });
                    },
                  ),
                ),

                const Divider(),

                // Other options
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings feature coming soon'),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to help screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support feature coming soon'),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    // Show about dialog
                    showAboutDialog(
                      context: context,
                      applicationName: Strings.appName,
                      applicationVersion: 'v1.0.0',
                      applicationIcon: const Icon(
                        Icons.construction,
                        size: 40,
                        color: AppColors.primary,
                      ),
                      children: [
                        const Text(
                          'A comprehensive tool for construction cost analysis and tender preparation with a 7-level hierarchical structure.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.text),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium,
      ),
      onTap: onTap,
    );
  }

  Widget _buildHierarchyItem({
    required BuildContext context,
    required int level,
    required String title,
    required int currentLevel,
    required VoidCallback onTap,
  }) {
    final Color levelColor = _getLevelColor(level);
    final bool isSelected = level == currentLevel;

    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: levelColor.withOpacity(isSelected ? 1.0 : 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            level.toString(),
            style: TextStyle(
              color: isSelected ? Colors.white : levelColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? levelColor : AppColors.text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildProjectItem({
    required BuildContext context,
    required Project project,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: const Icon(Icons.folder, color: AppColors.primary),
      title: Text(
        project.name,
        style: TextStyle(
          color: AppColors.text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        project.status,
        style: TextStyle(
          color: _getStatusColor(project.status),
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return AppColors.level1;
      case 2:
        return AppColors.level2;
      case 3:
        return AppColors.level3;
      case 4:
        return AppColors.level4;
      case 5:
        return AppColors.level5;
      case 6:
        return AppColors.level6;
      case 7:
        return AppColors.level7;
      default:
        return AppColors.text;
    }
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

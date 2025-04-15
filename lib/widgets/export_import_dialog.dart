import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/project.dart';
import '../providers/database_provider.dart';
import '../services/export_service.dart';
import '../services/import_service.dart';

class ExportImportDialog extends StatefulWidget {
  final Project? project;
  final String? parentId; // If provided, for analysis component export/import

  const ExportImportDialog({
    Key? key,
    this.project,
    this.parentId,
  }) : super(key: key);

  @override
  _ExportImportDialogState createState() => _ExportImportDialogState();
}

class _ExportImportDialogState extends State<ExportImportDialog> {
  bool _isExporting = false;
  bool _isImporting = false;
  String _statusMessage = '';
  final ExportService _exportService = ExportService();
  final ImportService _importService = ImportService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Export / Import Data',
              //      style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Export Section
            Text(
              'Export Data',
              //    style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),

            if (widget.project != null) ...[
              // Export project data options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildExportButton(
                    label: 'CSV',
                    onPressed: () => _exportProjectToCSV(widget.project!.id),
                    icon: Icons.article_outlined,
                  ),
                  _buildExportButton(
                    label: 'Excel',
                    onPressed: () => _exportProjectToExcel(widget.project!.id),
                    icon: Icons.grid_on,
                  ),
                  _buildExportButton(
                    label: 'PDF',
                    onPressed: () => _exportProjectToPDF(widget.project!.id),
                    icon: Icons.picture_as_pdf,
                  ),
                  _buildExportButton(
                    label: 'JSON',
                    onPressed: () => _exportProjectToJSON(widget.project!.id),
                    icon: Icons.code,
                  ),
                ],
              ),
            ] else if (widget.parentId != null) ...[
              // Export analysis components
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildExportButton(
                    label: 'CSV',
                    onPressed: () => _exportAnalysisToCSV(widget.parentId!),
                    icon: Icons.article_outlined,
                  ),
                  _buildExportButton(
                    label: 'Excel',
                    onPressed: () => _exportAnalysisToExcel(widget.parentId!),
                    icon: Icons.grid_on,
                  ),
                  _buildExportButton(
                    label: 'PDF',
                    onPressed: () => _exportAnalysisToPDF(widget.parentId!),
                    icon: Icons.picture_as_pdf,
                  ),
                ],
              ),
            ] else ...[
              // Export all data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildExportButton(
                    label: 'JSON (All Data)',
                    onPressed: _exportAllDataToJSON,
                    icon: Icons.code,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Import Section
            Text(
              'Import Data',
              //    style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),

            if (widget.parentId != null) ...[
              // Import analysis components
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImportButton(
                    label: 'CSV',
                    onPressed: () => _importAnalysisFromCSV(widget.parentId!),
                    icon: Icons.article_outlined,
                  ),
                  _buildImportButton(
                    label: 'Excel',
                    onPressed: () => _importAnalysisFromExcel(widget.parentId!),
                    icon: Icons.grid_on,
                  ),
                ],
              ),
            ] else ...[
              // Import project data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImportButton(
                    label: 'JSON',
                    onPressed: _importProjectFromJSON,
                    icon: Icons.code,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Error')
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (_isExporting || _isImporting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: _isExporting || _isImporting ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildImportButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: _isExporting || _isImporting ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Export Methods
  Future<void> _exportProjectToCSV(String projectId) async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting project to CSV...';
    });

    try {
      final csvData = await _exportService.exportProjectToCSV(projectId);

      // Download the file
      final blob = html.Blob([csvData], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'project_export.csv')
        ..click();
      html.Url.revokeObjectUrl(url);

      setState(() {
        _statusMessage = 'Project successfully exported to CSV';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting project to CSV: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportProjectToExcel(String projectId) async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting project to Excel...';
    });

    try {
      final bytes = await _exportService.exportProjectToExcel(projectId);

      // Download the file
      final blob = html.Blob([bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'project_export.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);

      setState(() {
        _statusMessage = 'Project successfully exported to Excel';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting project to Excel: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportProjectToPDF(String projectId) async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting project to PDF...';
    });

    try {
      final bytes = await _exportService.exportProjectToPDF(projectId);

      // Download the file
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'project_export.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      setState(() {
        _statusMessage = 'Project successfully exported to PDF';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting project to PDF: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportProjectToJSON(String projectId) async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting project to JSON...';
    });

    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      final jsonData = dbProvider.exportProject(projectId);
      final jsonString = jsonEncode(jsonData);

      // Download the file
      final blob = html.Blob([jsonString], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'project_export.json')
        ..click();
      html.Url.revokeObjectUrl(url);

      setState(() {
        _statusMessage = 'Project successfully exported to JSON';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting project to JSON: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportAllDataToJSON() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting all data to JSON...';
    });

    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      final jsonData = dbProvider.exportAllData();
      final jsonString = jsonEncode(jsonData);

      // Download the file
      final blob = html.Blob([jsonString], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'all_data_export.json')
        ..click();
      html.Url.revokeObjectUrl(url);

      setState(() {
        _statusMessage = 'All data successfully exported to JSON';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting all data to JSON: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportAnalysisToCSV(String parentId) async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting analysis to CSV...';
    });

    try {
      final csvData = await _exportService.exportAnalysisToCSV(parentId);

      // Download the file
      final blob = html.Blob([csvData], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'analysis_export.csv')
        ..click();
      html.Url.revokeObjectUrl(url);

      setState(() {
        _statusMessage = 'Analysis successfully exported to CSV';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting analysis to CSV: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportAnalysisToExcel(String parentId) async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting analysis to Excel...';
    });

    try {
      final bytes = await _exportService.exportAnalysisToExcel(parentId);

      // Download the file
      final blob = html.Blob([bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'analysis_export.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);

      setState(() {
        _statusMessage = 'Analysis successfully exported to Excel';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting analysis to Excel: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportAnalysisToPDF(String parentId) async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting analysis to PDF...';
    });

    try {
      final bytes = await _exportService.exportAnalysisToPDF(parentId);

      // Download the file
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'analysis_export.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      setState(() {
        _statusMessage = 'Analysis successfully exported to PDF';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting analysis to PDF: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // Import Methods
  Future<void> _importProjectFromJSON() async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Importing project from JSON...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final jsonString = utf8.decode(result.files.single.bytes!);
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

        final dbProvider =
            Provider.of<DatabaseProvider>(context, listen: false);
        await dbProvider.importProject(jsonData);

        setState(() {
          _statusMessage = 'Project successfully imported from JSON';
        });
      } else {
        setState(() {
          _statusMessage = 'No file selected';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error importing project from JSON: $e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _importAnalysisFromCSV(String parentId) async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Importing analysis from CSV...';
    });

    try {
      final components = await _importService.pickAndImportCSV(parentId);
      await _importService.saveImportedComponents(components, parentId);

      setState(() {
        _statusMessage =
            '${components.length} components successfully imported from CSV';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error importing analysis from CSV: $e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _importAnalysisFromExcel(String parentId) async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Importing analysis from Excel...';
    });

    try {
      final components = await _importService.pickAndImportExcel(parentId);
      await _importService.saveImportedComponents(components, parentId);

      setState(() {
        _statusMessage =
            '${components.length} components successfully imported from Excel';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error importing analysis from Excel: $e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }
}

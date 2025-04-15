import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../models/project.dart';
import '../models/building.dart';
import '../models/discipline.dart';
import '../models/group.dart';
import '../models/item.dart';
import '../models/sub_item.dart';
import '../models/analysis_component.dart';
import 'database_service.dart';

class ExportService {
  final DatabaseService _dbService = DatabaseService();

  // CSV Export Methods
  Future<String> exportProjectToCSV(String projectId) async {
    final project = _dbService.getProject(projectId);
    if (project == null) {
      throw Exception('Project not found');
    }

    final buildings = _dbService.getBuildingsForProject(projectId);
    final List<List<dynamic>> rows = [];

    // Add header row
    rows.add([
      'Project',
      'ID',
      'Name',
      'Description',
      'Location',
      'Client',
      'Contractor',
      'Start Date',
      'End Date',
      'Status',
      'Total Cost'
    ]);

    // Add project row
    rows.add([
      'Project',
      project.id,
      project.name,
      project.description,
      project.location,
      project.client,
      project.contractor,
      project.startDate.toIso8601String(),
      project.endDate!.toIso8601String(),
      project.status,
      _dbService.calculateProjectTotalCost(projectId)
    ]);

    // Add buildings
    for (final building in buildings) {
      rows.add([
        'Building',
        building.id,
        building.name,
        building.description,
        '', // location
        '', // client
        '', // contractor
        '', // start date
        '', // end date
        '', // status
        _dbService.calculateBuildingTotalCost(building.id)
      ]);

      // Add disciplines for this building
      final disciplines = _dbService.getDisciplinesForBuilding(building.id);
      for (final discipline in disciplines) {
        rows.add([
          'Discipline',
          discipline.id,
          discipline.name,
          discipline.description,
          '', // location
          '', // client
          '', // contractor
          '', // start date
          '', // end date
          '', // status
          _dbService.calculateDisciplineTotalCost(discipline.id)
        ]);

        // Add groups for this discipline
        final groups = _dbService.getGroupsForDiscipline(discipline.id);
        for (final group in groups) {
          rows.add([
            'Group',
            group.id,
            group.name,
            group.description,
            '', // location
            '', // client
            '', // contractor
            '', // start date
            '', // end date
            '', // status
            _dbService.calculateGroupTotalCost(group.id)
          ]);

          // Add items for this group
          final items = _dbService.getItemsForGroup(group.id);
          for (final item in items) {
            rows.add([
              'Item',
              item.id,
              item.name,
              item.description,
              '', // location
              '', // client
              '', // contractor
              '', // start date
              '', // end date
              '', // status
              _dbService.calculateItemTotalCost(item.id)
            ]);

            if (item.hasSubItems) {
              // Add sub items for this item
              final subItems = _dbService.getSubItemsForItem(item.id);
              for (final subItem in subItems) {
                rows.add([
                  'Sub Item',
                  subItem.id,
                  subItem.name,
                  subItem.description,
                  '', // location
                  '', // client
                  '', // contractor
                  '', // start date
                  '', // end date
                  '', // status
                  _dbService.calculateSubItemTotalCost(subItem.id)
                ]);
              }
            }
          }
        }
      }
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final fileName = 'project_${project.name.replaceAll(' ', '_')}.csv';

    if (kIsWeb) {
      // For web, return the CSV data for browser download
      return csvData;
    } else {
      // For mobile/desktop, save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csvData);
      return path;
    }
  }

  Future<String> exportBuildingToCSV(String buildingId) async {
    final building = _dbService.getBuilding(buildingId);
    if (building == null) {
      throw Exception('Building not found');
    }

    final disciplines = _dbService.getDisciplinesForBuilding(buildingId);
    final List<List<dynamic>> rows = [];

    // Add header row
    rows.add([
      'Type',
      'ID',
      'Name',
      'Description',
      'Quantity',
      'Unit',
      'Unit Price',
      'Multiplier Rate',
      'Total Cost'
    ]);

    // Add building row
    rows.add([
      'Building',
      building.id,
      building.name,
      building.description,
      building.quantity,
      building.unit,
      0.0, // unit price (N/A for building)
      building.multiplierRate,
      _dbService.calculateBuildingTotalCost(buildingId)
    ]);

    // Add disciplines
    for (final discipline in disciplines) {
      rows.add([
        'Discipline',
        discipline.id,
        discipline.name,
        discipline.description,
        discipline.quantity,
        discipline.unit,
        0.0, // unit price (N/A for discipline)
        discipline.multiplierRate,
        _dbService.calculateDisciplineTotalCost(discipline.id)
      ]);

      // Add groups for this discipline
      final groups = _dbService.getGroupsForDiscipline(discipline.id);
      for (final group in groups) {
        rows.add([
          'Group',
          group.id,
          group.name,
          group.description,
          group.quantity,
          group.unit,
          0.0, // unit price (N/A for group)
          group.multiplierRate,
          _dbService.calculateGroupTotalCost(group.id)
        ]);

        // Add items for this group
        final items = _dbService.getItemsForGroup(group.id);
        for (final item in items) {
          rows.add([
            'Item',
            item.id,
            item.name,
            item.description,
            item.quantity,
            item.unit,
            item.unitPrice,
            item.multiplierRate,
            _dbService.calculateItemTotalCost(item.id)
          ]);

          if (item.hasSubItems) {
            // Add sub items for this item
            final subItems = _dbService.getSubItemsForItem(item.id);
            for (final subItem in subItems) {
              rows.add([
                'Sub Item',
                subItem.id,
                subItem.name,
                subItem.description,
                subItem.quantity,
                subItem.unit,
                subItem.unitPrice,
                subItem.multiplierRate,
                _dbService.calculateSubItemTotalCost(subItem.id)
              ]);
            }
          }
        }
      }
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final fileName = 'building_${building.name.replaceAll(' ', '_')}.csv';

    if (kIsWeb) {
      // For web, return the CSV data for browser download
      return csvData;
    } else {
      // For mobile/desktop, save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csvData);
      return path;
    }
  }

  Future<String> exportAnalysisToCSV(String parentId) async {
    final analysisComponents =
        _dbService.getAnalysisComponentsForParent(parentId);
    if (analysisComponents.isEmpty) {
      throw Exception('No analysis components found');
    }

    // Determine if parent is item or sub item
    final isItem = _dbService.getItem(parentId) != null;
    final parentName = isItem
        ? _dbService.getItem(parentId)?.name ?? 'Unknown'
        : _dbService.getSubItem(parentId)?.name ?? 'Unknown';

    final List<List<dynamic>> rows = [];

    // Add header row
    rows.add([
      'ID',
      'Name',
      'Type',
      'Unit',
      'Quantity',
      'Unit Price',
      'Total',
      'Mass (kg)',
      'Origin',
      'Manhours'
    ]);

    // Add components
    for (final component in analysisComponents) {
      rows.add([
        component.id,
        component.name,
        component.componentType,
        component.unit,
        component.quantity,
        component.unitPrice,
        component.totalCost,
        component.mass,
        component.origin,
        component.manhours
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final fileName = 'analysis_${parentName.replaceAll(' ', '_')}.csv';

    if (kIsWeb) {
      // For web, return the CSV data for browser download
      return csvData;
    } else {
      // For mobile/desktop, save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(csvData);
      return path;
    }
  }

  // Excel Export Methods
  Future<Uint8List> exportProjectToExcel(String projectId) async {
    final project = _dbService.getProject(projectId);
    if (project == null) {
      throw Exception('Project not found');
    }

    final excel = Excel.createExcel();

    // Create Project Overview sheet
    final projectSheet = excel['Project Overview'];

    // Add header
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = 'Project Details' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = 'Name' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
        .value = project.name as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = 'Description' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
        .value = project.description as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .value = 'Location' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
        .value = project.location as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
        .value = 'Client' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
        .value = project.client as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
        .value = 'Contractor' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5))
        .value = project.contractor as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 6))
        .value = 'Start Date' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 6))
        .value = project.startDate.toIso8601String() as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 7))
        .value = 'End Date' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 7))
        .value = project.endDate!.toIso8601String() as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 8))
        .value = 'Status' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 8))
        .value = project.status as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 9))
        .value = 'Total Cost' as CellValue?;
    projectSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 9))
        .value = _dbService.calculateProjectTotalCost(projectId) as CellValue?;

    // Create Buildings sheet
    final buildingsSheet = excel['Buildings'];

    // Add header
    buildingsSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = 'ID' as CellValue?;
    buildingsSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = 'Name' as CellValue?;
    buildingsSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        .value = 'Description' as CellValue?;
    buildingsSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
        .value = 'Quantity' as CellValue?;
    buildingsSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
        .value = 'Unit' as CellValue?;
    buildingsSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
        .value = 'Multiplier Rate' as CellValue?;
    buildingsSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
        .value = 'Total Cost' as CellValue?;

    // Add buildings
    final buildings = _dbService.getBuildingsForProject(projectId);
    for (int i = 0; i < buildings.length; i++) {
      final building = buildings[i];
      buildingsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = building.id as CellValue?;
      buildingsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = building.name as CellValue?;
      buildingsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = building.description as CellValue?;
      buildingsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = building.quantity as CellValue?;
      buildingsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = building.unit as CellValue?;
      buildingsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = building.multiplierRate as CellValue?;
      buildingsSheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
              .value =
          _dbService.calculateBuildingTotalCost(building.id) as CellValue?;

      // Create a sheet for each building
      _createBuildingSheet(excel, building);
    }

    // Remove default 'Sheet1'
    excel.delete('Sheet1');

    // Convert to bytes
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to encode Excel file');
    }

    return Uint8List.fromList(bytes);
  }

  void _createBuildingSheet(Excel excel, Building building) {
    final buildingSheet = excel[building.name];

    // Add header for disciplines
    buildingSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = 'Type' as CellValue?;
    buildingSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = 'ID' as CellValue?;
    buildingSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        .value = 'Name' as CellValue?;
    buildingSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
        .value = 'Description' as CellValue?;
    buildingSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
        .value = 'Quantity' as CellValue?;
    buildingSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
        .value = 'Unit' as CellValue?;
    buildingSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
        .value = 'Unit Price' as CellValue?;
    buildingSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
        .value = 'Multiplier Rate' as CellValue?;
    buildingSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0))
        .value = 'Total Cost' as CellValue?;

    int currentRow = 1;

    // Get disciplines for this building
    final disciplines = _dbService.getDisciplinesForBuilding(building.id);

    for (final discipline in disciplines) {
      // Add discipline row
      buildingSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = 'Discipline' as CellValue?;
      buildingSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          .value = discipline.id as CellValue?;
      buildingSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
          .value = discipline.name as CellValue?;
      buildingSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = discipline.description as CellValue?;
      buildingSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow))
          .value = discipline.quantity as CellValue?;
      buildingSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow))
          .value = discipline.unit as CellValue?;
      buildingSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow))
          .value = 0.0 as CellValue?; // N/A for discipline
      buildingSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: currentRow))
          .value = discipline.multiplierRate as CellValue?;
      buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 8, rowIndex: currentRow))
              .value =
          _dbService.calculateDisciplineTotalCost(discipline.id) as CellValue?;

      currentRow++;

      // Get groups for this discipline
      final groups = _dbService.getGroupsForDiscipline(discipline.id);

      for (final group in groups) {
        // Add group row
        buildingSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: currentRow))
            .value = 'Group' as CellValue?;
        buildingSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 1, rowIndex: currentRow))
            .value = group.id as CellValue?;
        buildingSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: currentRow))
            .value = group.name as CellValue?;
        buildingSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: currentRow))
            .value = group.description as CellValue?;
        buildingSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: currentRow))
            .value = group.quantity as CellValue?;
        buildingSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 5, rowIndex: currentRow))
            .value = group.unit as CellValue?;
        buildingSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: currentRow))
            .value = 0.0 as CellValue?; // N/A for group
        buildingSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 7, rowIndex: currentRow))
            .value = group.multiplierRate as CellValue?;
        buildingSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 8, rowIndex: currentRow))
            .value = _dbService.calculateGroupTotalCost(group.id) as CellValue?;

        currentRow++;

        // Get items for this group
        final items = _dbService.getItemsForGroup(group.id);

        for (final item in items) {
          // Add item row
          buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: currentRow))
              .value = 'Item' as CellValue?;
          buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: currentRow))
              .value = item.id as CellValue?;
          buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 2, rowIndex: currentRow))
              .value = item.name as CellValue?;
          buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 3, rowIndex: currentRow))
              .value = item.description as CellValue?;
          buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 4, rowIndex: currentRow))
              .value = item.quantity as CellValue?;
          buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 5, rowIndex: currentRow))
              .value = item.unit as CellValue?;
          buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 6, rowIndex: currentRow))
              .value = item.unitPrice as CellValue?;
          buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 7, rowIndex: currentRow))
              .value = item.multiplierRate as CellValue?;
          buildingSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 8, rowIndex: currentRow))
              .value = _dbService.calculateItemTotalCost(item.id) as CellValue?;

          currentRow++;

          if (item.hasSubItems) {
            // Get sub items for this item
            final subItems = _dbService.getSubItemsForItem(item.id);

            for (final subItem in subItems) {
              // Add sub item row
              buildingSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 0, rowIndex: currentRow))
                  .value = 'Sub Item' as CellValue?;
              buildingSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 1, rowIndex: currentRow))
                  .value = subItem.id as CellValue?;
              buildingSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 2, rowIndex: currentRow))
                  .value = subItem.name as CellValue?;
              buildingSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 3, rowIndex: currentRow))
                  .value = subItem.description as CellValue?;
              buildingSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 4, rowIndex: currentRow))
                  .value = subItem.quantity as CellValue?;
              buildingSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 5, rowIndex: currentRow))
                  .value = subItem.unit as CellValue?;
              buildingSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 6, rowIndex: currentRow))
                  .value = subItem.unitPrice as CellValue?;
              buildingSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 7, rowIndex: currentRow))
                  .value = subItem.multiplierRate as CellValue?;
              buildingSheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 8, rowIndex: currentRow))
                      .value =
                  _dbService.calculateSubItemTotalCost(subItem.id)
                      as CellValue?;

              currentRow++;
            }
          }
        }
      }
    }
  }

  Future<Uint8List> exportAnalysisToExcel(String parentId) async {
    final analysisComponents =
        _dbService.getAnalysisComponentsForParent(parentId);
    if (analysisComponents.isEmpty) {
      throw Exception('No analysis components found');
    }

    // Determine if parent is item or sub item
    final isItem = _dbService.getItem(parentId) != null;
    final parentName = isItem
        ? _dbService.getItem(parentId)?.name ?? 'Unknown'
        : _dbService.getSubItem(parentId)?.name ?? 'Unknown';

    final excel = Excel.createExcel();
    final sheet = excel['Analysis'];

    // Add header
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'ID' as CellValue?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'Name' as CellValue?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        'Type' as CellValue?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        'Unit' as CellValue?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        'Quantity' as CellValue?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        'Unit Price' as CellValue?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value =
        'Total Cost' as CellValue?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value =
        'Mass (kg)' as CellValue?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0)).value =
        'Origin' as CellValue?;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0)).value =
        'Manhours' as CellValue?;

    // Add components
    for (int i = 0; i < analysisComponents.length; i++) {
      final component = analysisComponents[i];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = component.id as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = component.name as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = component.componentType as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = component.unit as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = component.quantity as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = component.unitPrice as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
          .value = component.totalCost as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1))
          .value = component.mass as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1))
          .value = component.origin as CellValue?;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 1))
          .value = component.manhours as CellValue?;
    }

    // Remove default 'Sheet1'
    excel.delete('Sheet1');

    // Convert to bytes
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to encode Excel file');
    }

    return Uint8List.fromList(bytes);
  }

  // PDF Export Methods
  Future<Uint8List> exportProjectToPDF(String projectId) async {
    final project = _dbService.getProject(projectId);
    if (project == null) {
      throw Exception('Project not found');
    }

    final buildings = _dbService.getBuildingsForProject(projectId);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Header(
            level: 0,
            child: pw.Text('Project Report: ${project.name}',
                style: pw.TextStyle(fontSize: 24)),
          );
        },
        footer: (pw.Context context) {
          return pw.Footer(
            trailing:
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}'),
          );
        },
        build: (pw.Context context) => [
          // Project Details
          pw.Header(level: 1, text: 'Project Overview'),
          _buildProjectDetailsPdf(project),
          pw.SizedBox(height: 20),

          // Buildings Summary
          pw.Header(level: 1, text: 'Buildings'),
          _buildBuildingsSummaryPdf(buildings),
          pw.SizedBox(height: 20),

          // Detailed Buildings
          for (final building in buildings) ...[
            pw.Header(level: 2, text: building.name),
            _buildBuildingDetailsPdf(building),
            pw.SizedBox(height: 10),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildProjectDetailsPdf(Project project) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Property',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Value',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Name'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(project.name),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Description'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(project.description),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Location'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(project.location),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Client'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(project.client),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Contractor'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(project.contractor),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Start Date'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(project.startDate.toString().split(' ')[0]),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('End Date'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(project.endDate.toString().split(' ')[0]),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Status'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(project.status),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Total Cost'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                  '\$${_dbService.calculateProjectTotalCost(project.id).toStringAsFixed(2)}'),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildBuildingsSummaryPdf(List<Building> buildings) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Name',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Quantity',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Unit',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Cost (\$)',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        for (final building in buildings)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(building.name),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(building.quantity.toString()),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(building.unit),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(_dbService
                    .calculateBuildingTotalCost(building.id)
                    .toStringAsFixed(2)),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildBuildingDetailsPdf(Building building) {
    final disciplines = _dbService.getDisciplinesForBuilding(building.id);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Description: ${building.description}'),
        pw.SizedBox(height: 5),
        pw.Text('Quantity: ${building.quantity} ${building.unit}'),
        pw.SizedBox(height: 5),
        pw.Text('Multiplier Rate: ${building.multiplierRate}'),
        pw.SizedBox(height: 5),
        pw.Text(
            'Total Cost: \$${_dbService.calculateBuildingTotalCost(building.id).toStringAsFixed(2)}'),
        pw.SizedBox(height: 10),
        pw.Text('Disciplines',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        disciplines.isEmpty
            ? pw.Text('No disciplines found')
            : pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Name',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Multiplier',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Cost (\$)',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  for (final discipline in disciplines)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(discipline.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(discipline.multiplierRate.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(_dbService
                              .calculateDisciplineTotalCost(discipline.id)
                              .toStringAsFixed(2)),
                        ),
                      ],
                    ),
                ],
              ),
      ],
    );
  }

  Future<Uint8List> exportAnalysisToPDF(String parentId) async {
    final analysisComponents =
        _dbService.getAnalysisComponentsForParent(parentId);
    if (analysisComponents.isEmpty) {
      throw Exception('No analysis components found');
    }

    // Determine if parent is item or sub item
    final isItem = _dbService.getItem(parentId) != null;
    final parentItem = isItem ? _dbService.getItem(parentId) : null;
    final parentSubItem = !isItem ? _dbService.getSubItem(parentId) : null;

    final parentName = isItem
        ? parentItem?.name ?? 'Unknown'
        : parentSubItem?.name ?? 'Unknown';

    final parentDescription = isItem
        ? parentItem?.description ?? ''
        : parentSubItem?.description ?? '';

    final parentQuantity =
        isItem ? parentItem?.quantity ?? 0 : parentSubItem?.quantity ?? 0;

    final parentUnit =
        isItem ? parentItem?.unit ?? '' : parentSubItem?.unit ?? '';

    final parentTotalCost = isItem
        ? _dbService.calculateItemTotalCost(parentId)
        : _dbService.calculateSubItemTotalCost(parentId);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Header(
            level: 0,
            child: pw.Text('Analysis Report: $parentName',
                style: pw.TextStyle(fontSize: 24)),
          );
        },
        footer: (pw.Context context) {
          return pw.Footer(
            trailing:
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}'),
          );
        },
        build: (pw.Context context) => [
          // Parent Details
          pw.Header(level: 1, text: 'Item Overview'),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Name'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text(parentName),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Description'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text(parentDescription),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Quantity'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('$parentQuantity $parentUnit'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Total Cost'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('\$${parentTotalCost.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Analysis Components
          pw.Header(level: 1, text: 'Analysis Components'),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Name',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Type',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Quantity',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Unit',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Unit Price',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              for (final component in analysisComponents)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(component.name),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(component.componentType),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(component.quantity.toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(component.unit),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                          '\$${component.unitPrice.toStringAsFixed(2)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                          '\$${component.totalCost.toStringAsFixed(2)}'),
                    ),
                  ],
                ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Additional Details
          pw.Header(level: 1, text: 'Additional Details'),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Name',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Mass (kg)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Origin',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Manhours',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              for (final component in analysisComponents)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(component.name),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(component.mass.toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(component.origin),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(component.manhours.toString()),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/analysis_component.dart';
import '../models/sub_item.dart';
import '../models/item.dart';
import 'database_service.dart';

class ImportService {
  final DatabaseService _dbService = DatabaseService();

  // Import analysis components from Excel file
  Future<List<AnalysisComponent>> importAnalysisFromExcel(
      Uint8List bytes, String parentId) async {
    try {
      final excel = Excel.decodeBytes(bytes);

      // Expect the first sheet to contain the analysis data
      final sheet = excel.tables.values.first;

      // Check if this is a valid analysis sheet (should have headers)
      if (sheet.maxRows < 2) {
        throw Exception('Invalid Excel format: No data rows found');
      }

      // Determine column indices
      final headers = _getRowValues(sheet, 0);
      final nameIndex = headers.indexOf('Name');
      final typeIndex = headers.indexOf('Type');
      final unitIndex = headers.indexOf('Unit');
      final quantityIndex = headers.indexOf('Quantity');
      final unitPriceIndex = headers.indexOf('Unit Price');
      final massIndex = headers.indexOf('Mass (kg)');
      final originIndex = headers.indexOf('Origin');
      final manhoursIndex = headers.indexOf('Manhours');

      // Validate required columns exist
      if (nameIndex == -1 ||
          typeIndex == -1 ||
          unitIndex == -1 ||
          quantityIndex == -1 ||
          unitPriceIndex == -1) {
        throw Exception('Invalid Excel format: Missing required columns');
      }

      // Import analysis components
      final List<AnalysisComponent> components = [];

      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        final rowData = _getRowValues(sheet, rowIndex);

        // Skip empty rows
        if (rowData.isEmpty ||
            rowData[nameIndex] == null ||
            rowData[nameIndex].toString().isEmpty) {
          continue;
        }

        final component = AnalysisComponent(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_$rowIndex',
          parentId: parentId,
          name: rowData[nameIndex].toString(),
          componentType: rowData[typeIndex]?.toString() ?? 'Material',
          unit: rowData[unitIndex]?.toString() ?? 'pcs',
          quantity: _parseDouble(rowData[quantityIndex]),
          unitPrice: _parseDouble(rowData[unitPriceIndex]),
          mass: massIndex >= 0 ? _parseDouble(rowData[massIndex]) : 0.0,
          origin:
              originIndex >= 0 ? rowData[originIndex]?.toString() ?? '' : '',
          manhours:
              manhoursIndex >= 0 ? _parseDouble(rowData[manhoursIndex]) : 0.0,
        );

        components.add(component);
      }

      return components;
    } catch (e) {
      rethrow;
    }
  }

  // Import analysis components from CSV file
  Future<List<AnalysisComponent>> importAnalysisFromCSV(
      String csvData, String parentId) async {
    try {
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(csvData);

      // Check if this is a valid analysis CSV (should have headers and data)
      if (rows.length < 2) {
        throw Exception('Invalid CSV format: No data rows found');
      }

      // Determine column indices
      final headers = rows[0];
      final nameIndex = headers.indexOf('Name');
      final typeIndex = headers.indexOf('Type');
      final unitIndex = headers.indexOf('Unit');
      final quantityIndex = headers.indexOf('Quantity');
      final unitPriceIndex = headers.indexOf('Unit Price');
      final massIndex = headers.indexOf('Mass (kg)');
      final originIndex = headers.indexOf('Origin');
      final manhoursIndex = headers.indexOf('Manhours');

      // Validate required columns exist
      if (nameIndex == -1 ||
          typeIndex == -1 ||
          unitIndex == -1 ||
          quantityIndex == -1 ||
          unitPriceIndex == -1) {
        throw Exception('Invalid CSV format: Missing required columns');
      }

      // Import analysis components
      final List<AnalysisComponent> components = [];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        // Skip empty rows
        if (row.isEmpty ||
            row[nameIndex] == null ||
            row[nameIndex].toString().isEmpty) {
          continue;
        }

        final component = AnalysisComponent(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
          parentId: parentId,
          name: row[nameIndex].toString(),
          componentType: row[typeIndex]?.toString() ?? 'Material',
          unit: row[unitIndex]?.toString() ?? 'pcs',
          quantity: _parseDouble(row[quantityIndex]),
          unitPrice: _parseDouble(row[unitPriceIndex]),
          mass: massIndex >= 0 ? _parseDouble(row[massIndex]) : 0.0,
          origin: originIndex >= 0 ? row[originIndex]?.toString() ?? '' : '',
          manhours: manhoursIndex >= 0 ? _parseDouble(row[manhoursIndex]) : 0.0,
        );

        components.add(component);
      }

      return components;
    } catch (e) {
      rethrow;
    }
  }

  // Save imported components to database
  Future<void> saveImportedComponents(
      List<AnalysisComponent> components, String parentId) async {
    // Check if we're importing to an item or sub-item
    final isItem = _dbService.getItem(parentId) != null;
    final parent =
        isItem ? _dbService.getItem(parentId) : _dbService.getSubItem(parentId);

    if (parent == null) {
      throw Exception('Parent item/sub-item not found');
    }

    // Delete existing components if requested
    // This can be controlled by a parameter if needed

    // Save new components to database
    for (final component in components) {
      await _dbService.saveAnalysisComponent(component);
    }

    // Update parent with component IDs
    final componentIds = components.map((c) => c.id).toList();

    if (isItem) {
      final item = _dbService.getItem(parentId)!;
      final updatedItem = item.copyWith(
        analysisComponentIds: [...item.analysisComponentIds, ...componentIds],
      );
      await _dbService.saveItem(updatedItem);
    } else {
      final subItem = _dbService.getSubItem(parentId)!;
      final updatedSubItem = subItem.copyWith(
        analysisComponentIds: [
          ...subItem.analysisComponentIds,
          ...componentIds
        ],
      );
      await _dbService.saveSubItem(updatedSubItem);
    }
  }

  // Helper to parse cell values to double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').replaceAll('\$', '')) ??
          0.0;
    }
    return 0.0;
  }

  // Helper to extract row values from Excel sheet
  List<dynamic> _getRowValues(Sheet sheet, int rowIndex) {
    final row = <dynamic>[];
    for (int colIndex = 0; colIndex < sheet.maxColumns; colIndex++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: colIndex,
        rowIndex: rowIndex,
      ));
      row.add(cell.value);
    }
    return row;
  }

  // Pick and import Excel file
  Future<List<AnalysisComponent>> pickAndImportExcel(String parentId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        return importAnalysisFromExcel(result.files.single.bytes!, parentId);
      } else {
        throw Exception('No file selected');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Pick and import CSV file
  Future<List<AnalysisComponent>> pickAndImportCSV(String parentId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final csvData = utf8.decode(result.files.single.bytes!);
        return importAnalysisFromCSV(csvData, parentId);
      } else {
        throw Exception('No file selected');
      }
    } catch (e) {
      rethrow;
    }
  }
}

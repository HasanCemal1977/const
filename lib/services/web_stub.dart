// This is a stub file for web compatibility
// It provides mock implementations of classes needed for PostgreSQL

class Platform {
  static Map<String, String> environment = {
    'PGHOST': 'localhost',
    'PGPORT': '5432',
    'PGDATABASE': 'postgres',
    'PGUSER': 'postgres',
    'PGPASSWORD': 'postgres',
  };
}

class PostgreSQLConnection {
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;

  PostgreSQLConnection(
    this.host,
    this.port,
    this.database, {
    required this.username,
    required this.password,
  });

  Future<void> open() async {
    // Web doesn't support direct PostgreSQL connections
    print('Web platform detected - using mock PostgreSQL connection');
    return Future.value();
  }

  Future<PostgreSQLResult> query(
    String query, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    // Return empty results for web
    print('Web stub: Query executed (no actual database operations): $query');
    return PostgreSQLResult.fromResults([]);
  }

  Future<int> execute(
    String query, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    // Return success for web
    print('Web stub: Execute query (no actual database operations): $query');
    return 0;
  }

  Future<void> close() async {
    // No actual connection to close in web
    return Future.value();
  }
}

// Stub for PostgreSQLResult with improvements for web support
class PostgreSQLResult {
  final List<PostgreSQLResultRow> _rows = [];
  final List<PostgreSQLColumnDescription> columnDescriptions = [];
  final List<List<dynamic>> _rawResults = [];

  List<PostgreSQLResultRow> get toList => _rows;
  bool get isEmpty => _rows.isEmpty && _rawResults.isEmpty;

  PostgreSQLResultRow get first {
    if (_rows.isNotEmpty) {
      return _rows.first;
    }
    if (_rawResults.isNotEmpty) {
      final row = PostgreSQLResultRow();
      row._values.addAll(_rawResults.first);
      return row;
    }
    throw Exception('No results available');
  }

  operator [](int index) {
    if (index < _rows.length) {
      return _rows[index];
    }
    if (index < _rawResults.length) {
      final row = PostgreSQLResultRow();
      row._values.addAll(_rawResults[index]);
      return row;
    }
    throw Exception('Index out of range');
  }

  int get length => _rows.length > 0 ? _rows.length : _rawResults.length;

  List<dynamic> get first_raw =>
      _rawResults.isNotEmpty ? _rawResults.first : [];

  static PostgreSQLResult fromResults(List<List<dynamic>> results) {
    final pgResult = PostgreSQLResult();
    pgResult._rawResults.addAll(results);

    // Create column descriptions based on indices
    for (int i = 0; i < (results.isNotEmpty ? results.first.length : 0); i++) {
      pgResult.columnDescriptions.add(PostgreSQLColumnDescription('column_$i'));
    }

    // Create result rows
    for (final row in results) {
      final pgRow = PostgreSQLResultRow();
      pgRow._values.addAll(row);
      pgResult._rows.add(pgRow);
    }

    return pgResult;
  }

  void map(Function(PostgreSQLResultRow) fn) {
    for (final row in _rows) {
      fn(row);
    }
  }
}

// Stub for PostgreSQLResultRow with improvements
class PostgreSQLResultRow {
  final List<dynamic> _values = [];

  dynamic operator [](int index) =>
      index < _values.length ? _values[index] : null;

  Map<String, dynamic> toColumnMap() {
    final map = <String, dynamic>{};
    for (int i = 0; i < _values.length; i++) {
      map['column_$i'] = _values[i];
    }
    return map;
  }
}

// Stub for PostgreSQLColumnDescription
class PostgreSQLColumnDescription {
  final String columnName;

  PostgreSQLColumnDescription(this.columnName);
}

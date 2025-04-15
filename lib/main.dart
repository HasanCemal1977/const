import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/project_provider.dart';
import 'providers/hierarchy_provider.dart';
import 'providers/database_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => HierarchyProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
      ],
      child: const ConstructionCostApp(),
    ),
  );
}

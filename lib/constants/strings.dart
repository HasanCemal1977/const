class Strings {
  // App name
  static const String appName = 'Construction Cost Analysis';

  // General strings
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String create = 'Create';
  static const String update = 'Update';
  static const String details = 'Details';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String noData = 'No data available';

  // Error messages
  static const String fieldRequired = 'This field is required';
  static const String invalidNumber = 'Please enter a valid number';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String generalError = 'An error occurred. Please try again';
  static const String connectionError =
      'Connection error. Please check your internet';

  // Level names
  static const String project = 'Project';
  static const String buildings = 'Buildings';
  static const String disciplines = 'Disciplines';
  static const String groups = 'Groups';
  static const String items = 'Items';
  static const String subItems = 'Sub Items';
  static const String analysis = 'Analysis';

  // Field labels
  static const String name = 'Name';
  static const String description = 'Description';
  static const String quantity = 'Quantity';
  static const String unit = 'Unit';
  static const String price = 'Price';
  static const String multiplierRate = 'Multiplier Rate';
  static const String totalCost = 'Total Cost';
  static const String date = 'Date';
  static const String location = 'Location';
  static const String client = 'Client';
  static const String contractor = 'Contractor';
  static const String status = 'Status';
  static const String mass = 'Mass';
  static const String origin = 'Origin';
  static const String manhour = 'Man Hours';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String overview = 'Overview';
  static const String recentProjects = 'Recent Projects';
  static const String statistics = 'Statistics';
  static const String projectProgress = 'Project Progress';

  // Analysis Component Types
  static const String material = 'Material';
  static const String labour = 'Labour';
  static const String equipment = 'Equipment';
  static const String transportation = 'Transportation';

  // Discipline defaults
  static const List<String> defaultDisciplines = [
    'Civil Works',
    'Architectural Works',
    'Sanitary Works',
    'HVAC Works',
    'Low Current Works',
    'Electrical Works',
    'Power Supply',
    'Site Works'
  ];

  // Confirmation dialogs
  static const String confirmDelete =
      'Are you sure you want to delete this item?';
  static const String confirmDeleteMessage = 'This action cannot be undone.';
  static const String yes = 'Yes';
  static const String no = 'No';

  // Home screen
  static const String welcome = 'Welcome to Construction Cost Analysis';
  static const String startNewProject = 'Start New Project';
  static const String openExistingProject = 'Open Existing Project';

  // Tooltips
  static const String addNew = 'Add new';
  static const String viewDetails = 'View details';
  static const String backToHome = 'Back to home';
  static const String exportData = 'Export data';
  static const String importData = 'Import data';
}

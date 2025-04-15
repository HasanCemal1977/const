import 'package:flutter/material.dart';

typedef SaveCallback = void Function(
  String name,
  String description,
  double quantity,
  double multiplierRate,
);

class AddItemForm extends StatefulWidget {
  final String title;
  final String nameLabel;
  final String descriptionLabel;
  final String? initialName;
  final String? initialDescription;
  final double initialQuantity;
  final double initialMultiplierRate;
  final bool includeUnitPrice;
  final bool includeUnit;
  final String? initialUnit;
  final double? initialUnitPrice;
  final SaveCallback onSave;

  const AddItemForm({
    Key? key,
    required this.title,
    required this.nameLabel,
    required this.descriptionLabel,
    this.initialName,
    this.initialDescription,
    this.initialQuantity = 1.0,
    this.initialMultiplierRate = 1.0,
    this.includeUnitPrice = false,
    this.includeUnit = false,
    this.initialUnit,
    this.initialUnitPrice,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _multiplierRateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    _quantityController =
        TextEditingController(text: widget.initialQuantity.toString());
    _multiplierRateController =
        TextEditingController(text: widget.initialMultiplierRate.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _multiplierRateController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final quantity = double.tryParse(_quantityController.text) ?? 1.0;
      final multiplierRate =
          double.tryParse(_multiplierRateController.text) ?? 1.0;

      widget.onSave(name, description, quantity, multiplierRate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: widget.nameLabel),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'This field is required'
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: widget.descriptionLabel),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _multiplierRateController,
                decoration: const InputDecoration(labelText: 'Multiplier Rate'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
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
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

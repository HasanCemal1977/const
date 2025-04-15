import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CostSummaryCard extends StatelessWidget {
  final String title;
  final double quantity;
  final double multiplierRate;
  final double totalCost;
  final VoidCallback? onEdit;
  final List<CostBreakdownItem>? breakdownItems;

  const CostSummaryCard({
    Key? key,
    required this.title,
    required this.quantity,
    required this.multiplierRate,
    required this.totalCost,
    this.onEdit,
    this.breakdownItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  title,
                  style: AppTextStyles.heading3,
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit Cost Factors',
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Quantity and Multiplier
            Row(
              children: [
                Expanded(
                  child: _buildCostFactor(
                    label: 'Quantity',
                    value: quantity.toString(),
                    icon: Icons.straighten,
                  ),
                ),
                Expanded(
                  child: _buildCostFactor(
                    label: 'Multiplier Rate',
                    value: multiplierRate.toString(),
                    icon: Icons.percent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Breakdown items if available
            if (breakdownItems != null && breakdownItems!.isNotEmpty) ...[
              const Text(
                'Cost Breakdown',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              ...breakdownItems!.map((item) => _buildBreakdownItem(item)),
              const Divider(),
              const SizedBox(height: 8),
            ],

            // Total Cost
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Cost:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${totalCost.toStringAsFixed(2)}',
                  style: AppTextStyles.totalCost,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostFactor({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.costLabel,
            ),
            Text(
              value,
              style: AppTextStyles.costValue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(CostBreakdownItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.text,
            ),
          ),
          Text(
            '\$${item.value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: item.highlightColor ?? AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Model class to represent a cost breakdown item
class CostBreakdownItem {
  final String label;
  final double value;
  final Color? highlightColor;

  const CostBreakdownItem({
    required this.label,
    required this.value,
    this.highlightColor,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class HierarchyListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int level;
  final String? additionalInfo;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HierarchyListItem({
    Key? key,
    required this.title,
    this.subtitle,
    required this.level,
    this.additionalInfo,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color levelColor = _getLevelColor();

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: levelColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Level indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: levelColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      level.toString(),
                      style: TextStyle(
                        color: levelColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.cardTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AppTextStyles.cardSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (additionalInfo != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          additionalInfo!,
                          style: TextStyle(
                            color: levelColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow indicator
                Icon(
                  Icons.arrow_forward_ios,
                  color: levelColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor() {
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
        return AppColors.primary;
    }
  }
}

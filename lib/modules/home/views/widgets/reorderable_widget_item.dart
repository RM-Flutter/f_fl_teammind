import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_sizes.dart';
import '../../models/home_widget_type.dart';

class ReorderableWidgetItem extends StatelessWidget {
  final HomeWidgetType widgetType;
  final Widget content;
  final bool isDragging;

  const ReorderableWidgetItem({
    super.key,
    required this.widgetType,
    required this.content,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(widgetType.id),
      margin: EdgeInsets.only(
        bottom: AppSizes.s12,
        top: AppSizes.s8,
      ),
      child: Material(
        color: Colors.transparent,
        elevation: isDragging ? 8 : 0,
        borderRadius: BorderRadius.circular(AppSizes.s12),
        child: Stack(
          children: [
            content,
            // Drag handle - make it larger and more accessible
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.drag_handle,
                  color: Color(AppColors.dark),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


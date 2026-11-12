import 'package:app_test/core/widgets/app_field_shell.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../services/localization_service.dart';
import 'package:app_test/core/constants/app_design.dart';

/// دروب داون مع سيرش — يفتح bottom sheet فيه حقل بحث وقائمة.
class SearchableDropdownSheet extends StatefulWidget {
  final Map<String, dynamic>? selectedValue;
  final List<Map<String, dynamic>>? items;
  final String nameKey;
  final String? hintText;
  final TextStyle? hintStyle;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final EdgeInsets? contentPadding;
  final Widget? fieldSuffixIcon;
  final double? height;
  final void Function(Map<String, dynamic> value) onChanged;

  const SearchableDropdownSheet({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.nameKey,
    required this.onChanged,
    this.hintText,
    this.hintStyle,
    this.borderRadius,
    this.borderSide,
    this.contentPadding,
    this.fieldSuffixIcon,
    this.height,
  });

  @override
  State<SearchableDropdownSheet> createState() =>
      _SearchableDropdownSheetState();
}

class _SearchableDropdownSheetState extends State<SearchableDropdownSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isEmpty(Map<String, dynamic>? v) => v == null || v.isEmpty;

  String _displayText() {
    if (_isEmpty(widget.selectedValue)) return '';
    return widget.selectedValue![widget.nameKey]?.toString() ??
        widget.hintText ??
        "";
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSheet() {
    final list = widget.items ?? [];
    if (list.isEmpty) return;
    _searchController.clear();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                final q = _searchController.text.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? list
                    : list.where((m) {
                        final n =
                            m[widget.nameKey]?.toString().toLowerCase() ?? '';
                        return n.contains(q);
                      }).toList();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: AppSizes.s8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s8),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText: '${AppStrings.search.tr()}...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.s16,
                            vertical: AppSizes.s12,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
 padding: EdgeInsets.zero,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final title = item[widget.nameKey]?.toString() ?? '';
                          final sel = !_isEmpty(widget.selectedValue) &&
                              widget.selectedValue!['id'] == item['id'];
                          return ListTile(
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight:
                                    sel ? FontWeight.w600 : FontWeight.normal,
                                color: sel
                                    ? Color(AppColors.buttons)
                                    : Color(AppColors.overlay),
                              ),
                            ),
                            onTap: () {
                              widget.onChanged(item);
                              Navigator.of(ctx).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ).then((_) => _searchFocusNode.unfocus());
  }

  @override
  Widget build(BuildContext context) {
    final display = _displayText();
    // Same box, hint and arrow as every other field (rule 15).
    return AppFieldShell(
      onTap: _openSheet,
      height: widget.height,
      trailingIcon: display.isNotEmpty && widget.fieldSuffixIcon != null
          ? null
          : Icons.keyboard_arrow_down_rounded,
      child: Row(
        children: [
          Expanded(
            child: Text(
              display.isEmpty ? (widget.hintText ?? '') : display,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: display.isEmpty ? AppField.hintStyle : AppField.valueStyle,
            ),
          ),
          if (display.isNotEmpty && widget.fieldSuffixIcon != null) widget.fieldSuffixIcon!,
        ],
      ),
    );
  }
}

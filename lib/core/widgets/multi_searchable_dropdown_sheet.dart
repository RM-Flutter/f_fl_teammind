import 'package:app_test/core/widgets/app_field_shell.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import 'package:app_test/core/constants/app_design.dart';

/// دروب داون مع سيرش — يفتح bottom sheet فيه حقل بحث وقائمة تدعم الاختيار المتعدد (Checkboxes).
class MultiSearchableDropdownSheet extends StatefulWidget {
  final List<Map<String, dynamic>> selectedValues;
  final List<Map<String, dynamic>>? items;
  final String nameKey;
  final String? hintText;
  final TextStyle? hintStyle;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final EdgeInsets? contentPadding;
  final Widget? fieldSuffixIcon;
  final double? height;
  final void Function(List<Map<String, dynamic>> values) onChanged;

  const MultiSearchableDropdownSheet({
    super.key,
    required this.selectedValues,
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
  State<MultiSearchableDropdownSheet> createState() =>
      _MultiSearchableDropdownSheetState();
}

class _MultiSearchableDropdownSheetState extends State<MultiSearchableDropdownSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isEmpty(List<Map<String, dynamic>>? v) => v == null || v.isEmpty;

  String _displayText() {
    if (_isEmpty(widget.selectedValues)) return '';
    if (widget.selectedValues.length == 1) {
      return widget.selectedValues.first[widget.nameKey]?.toString() ?? '';
    }
    return '${widget.selectedValues.length} ${'items_selected'.tr()}';
  }

  void _showSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _MultiSelectionSheetContent(
          items: widget.items ?? [],
          nameKey: widget.nameKey,
          initialSelected: widget.selectedValues,
          onConfirm: (List<Map<String, dynamic>> newSelection) {
            widget.onChanged(newSelection);
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = !_isEmpty(widget.selectedValues);
    final displayTxt = _displayText();
    // Same box, hint and arrow as every other field (rule 15).
    return AppFieldShell(
      onTap: () => _showSelectionSheet(context),
      height: widget.height,
      trailingIcon: widget.fieldSuffixIcon == null ? Icons.keyboard_arrow_down_rounded : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              isSelected ? displayTxt : (widget.hintText ?? ''),
              style: isSelected ? AppField.valueStyle : AppField.hintStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.fieldSuffixIcon != null) widget.fieldSuffixIcon!,
        ],
      ),
    );
  }
}

class _MultiSelectionSheetContent extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String nameKey;
  final List<Map<String, dynamic>> initialSelected;
  final void Function(List<Map<String, dynamic>>) onConfirm;

  const _MultiSelectionSheetContent({
    required this.items,
    required this.nameKey,
    required this.initialSelected,
    required this.onConfirm,
  });

  @override
  State<_MultiSelectionSheetContent> createState() =>
      _MultiSelectionSheetContentState();
}

class _MultiSelectionSheetContentState
    extends State<_MultiSelectionSheetContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filtered = [];
  List<Map<String, dynamic>> _selected = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.items);
    _selected = List.from(widget.initialSelected);
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(widget.items);
      } else {
        _filtered = widget.items.where((item) {
          final val = (item[widget.nameKey]?.toString() ?? '').toLowerCase();
          return val.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleItem(Map<String, dynamic> item) {
    setState(() {
      final exists = _selected.any((e) => e['id'] == item['id']);
      if (exists) {
        _selected.removeWhere((e) => e['id'] == item['id']);
      } else {
        _selected.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Handle Bar
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: 16),
              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.search.tr(),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: BorderSide(
                        color: Color(AppColors.buttons),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Selected Chips (Preview)
              if (_selected.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selected.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = _selected[index];
                      return Chip(
                        label: Text(
                          item[widget.nameKey]?.toString() ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () => _toggleItem(item),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: Color(AppColors.buttons).withOpacity(0.1),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                      );
                    },
                  ),
                ),
              if (_selected.isNotEmpty) const SizedBox(height: 10),
              const Divider(height: 1),
              // List
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noDataFounded.tr(),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: _filtered.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          final isChecked =
                              _selected.any((e) => e['id'] == item['id']);

                          return CheckboxListTile(
                            value: isChecked,
                            onChanged: (val) => _toggleItem(item),
                            title: Text(
                              item[widget.nameKey]?.toString() ?? '',
                              style: theme.textTheme.bodyMedium,
                            ),
                            activeColor: Color(AppColors.buttons),
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                          );
                        },
                      ),
              ),
              // Confirm Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    onPressed: () => widget.onConfirm(_selected),
                    child: Text('confirm_selection'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


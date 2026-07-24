import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../services/localization_service.dart';

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.s15),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
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
    final border = OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(AppSizes.s10),
      borderSide: widget.borderSide ??
          BorderSide(color: Color(AppColors.border), width: 1.0),
    );
    final display = _displayText();
    final h = widget.height ?? 65.0;
    final isRtl = LocalizationService.isArabic(context: context);
    final verticalPadding = (h - 20) / 2;
    final contentPadding = widget.contentPadding ?? EdgeInsets.only(
      left: isRtl ? 12 : 16,
      right: isRtl ? 16 : 12,
      top: widget.height != null ? verticalPadding : 12,
      bottom: widget.height != null ? verticalPadding : 12,
    );
    final child = InkWell(
      onTap: _openSheet,
      child: InputDecorator(
        isEmpty: display.isEmpty,
        decoration: InputDecoration(
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          isDense: true,
          contentPadding: contentPadding,
          hintText: widget.hintText,
          hintStyle: widget.hintStyle,
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          suffixIcon: display.isNotEmpty && widget.fieldSuffixIcon != null
              ? widget.fieldSuffixIcon
              : Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: (widget.items == null || widget.items!.isEmpty)
                      ? Colors.grey
                      : Colors.black,
                  size: 24,
                ),
        ),
        child: display.isEmpty
            ? const SizedBox.shrink()
            : Text(
                display,
                style: widget.hintStyle?.copyWith(
                      color: Color(AppColors.overlay),
                    ) ??
                    TextStyle(
                      color: Color(AppColors.overlay),
                      fontSize: 14,
                    ),
              ),
      ),
    );
    return SizedBox(
      height: h,
      child: child,
    );
  }
}

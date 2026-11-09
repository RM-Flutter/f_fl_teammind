import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';

Widget defaultTapBarItem({
  required List<String>? items,
  Function? onTapItem,
  bool? sectInt = false,
  int? selectIndex = 0,
  String? selectName,
  bool enableScroll = false,
  double? tapBarItemsWidth,
  bool? isVertical, // 👈 متغير جديد لتحديد الاتجاه يدويًا
  /// Horizontal mode only: size each tab to its full title (longer title = wider tab) instead of
  /// a fixed width, so long titles are never cut off. Use with [enableScroll].
  bool fitToText = false,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          bool useVertical = isVertical ?? false;

          final availWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width * 0.95;
          double totalWidth = useVertical
              ? 200
              : (tapBarItemsWidth != null && tapBarItemsWidth < availWidth
                  ? tapBarItemsWidth
                  : availWidth);
          double itemWidth = useVertical ? double.infinity : (totalWidth / 3.8);
      const tabTextStyle = TextStyle(
        fontSize: 11,
        color: Colors.white,
        fontWeight: FontWeight.w900,
      );
      // Width a tab needs to show its whole title, plus the tab's horizontal padding
      double fittedWidth(String title) {
        // measure with the style the Text really renders with (theme font, e.g. the wider Arabic one,
        // and the user's text scale); a bare TextStyle would use the default font and come out too narrow
        final painter = TextPainter(
          text: TextSpan(
            text: title,
            style: DefaultTextStyle.of(context).style.merge(tabTextStyle),
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        return painter.width + 28;
      }

      final count = items?.length ?? 0;
      final innerAvailable = totalWidth - 8 - (count * 8);
      final baseWidths = (fitToText && !useVertical && items != null)
          ? items.map(fittedWidth).toList()
          : <double>[];
      final sumFitted =
          baseWidths.fold<double>(0.0, (prev, element) => prev + element);
      final extraPerTab =
          (fitToText && !useVertical && count > 0 && innerAvailable > sumFitted)
              ? (innerAvailable - sumFitted) / count
              : 0.0;
      final distributedEqualWidth =
          (!useVertical && count > 0) ? (innerAvailable / count) : itemWidth;
      final effectiveEqualWidth =
          (!useVertical && distributedEqualWidth > itemWidth)
              ? distributedEqualWidth
              : itemWidth;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        alignment: Alignment.center,
        height: !useVertical ? 50 : null,
        width: totalWidth,
        // clip to the rounded shape, so tabs scrolling past the edge follow the curve
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color:  Color(AppColors.secondaryButton),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: SizedBox(
          child: ListView.builder(
            shrinkWrap: true,
            reverse: false,
            clipBehavior: Clip.none, // the square clip of the inner list is what cut the tabs with a hard edge
            scrollDirection: useVertical ? Axis.vertical : Axis.horizontal, // 👈 الاتجاه هنا
            physics: enableScroll == false
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            itemCount: items!.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                setState(() {
                  selectIndex = index;
                  selectName = items[index];
                  if (onTapItem != null) {
                    onTapItem!(index);
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: useVertical ? 0 : 4,
                  vertical: useVertical ? 4 : 0,
                ),
                padding: EdgeInsets.symmetric(horizontal: (fitToText && !useVertical) ? 14 : 8),
                height: useVertical ? 40 : 42,
                width: (fitToText && !useVertical)
                    ? (baseWidths[index] + extraPerTab)
                    : effectiveEqualWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  color: (selectIndex == index || selectName == items[index])
                      ?  Color(AppColors.buttons)
                      : Colors.transparent,
                ),
                child: Text(
                  items[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  overflow: fitToText ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: tabTextStyle,
                ),
              ),
            ),
          ),
        ),
      );
        },
      );
    },
  );
}

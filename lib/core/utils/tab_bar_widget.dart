import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';

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
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      bool isWeb = MediaQuery.of(context).size.width > 600;
      bool useVertical = isVertical ?? isWeb; // 👈 لو محددتش، يعتمد على الويب

      double totalWidth = useVertical
          ? 200
          : (tapBarItemsWidth ?? MediaQuery.sizeOf(context).width * 0.95);
      double itemWidth = useVertical ? double.infinity : (totalWidth / 3.8);
      const tabTextStyle = TextStyle(
        fontSize: 11,
        color: Colors.white,
        fontWeight: FontWeight.w900,
      );
      // Width a tab needs to show its whole title, plus the tab's horizontal padding
      double fittedWidth(String title) {
        final painter = TextPainter(
          text: TextSpan(text: title.toUpperCase(), style: tabTextStyle),
          textDirection: Directionality.of(context),
          maxLines: 1,
        )..layout();
        return painter.width + 28;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        alignment: Alignment.center,
        height: !useVertical ? 50 : null,
        width: totalWidth,
        decoration: BoxDecoration(
          color:  Color(AppColors.secondaryButton),
          borderRadius: BorderRadius.circular(32),
        ),
        child: SizedBox(
          child: ListView.builder(
            shrinkWrap: true,
            reverse: false,
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
                    ? fittedWidth(items[index])
                    : itemWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: (selectIndex == index || selectName == items[index])
                      ?  Color(AppColors.buttons)
                      : Colors.transparent,
                ),
                child: Text(
                  items[index].toUpperCase(),
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
}

import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';

Widget defaultTapBarItem({
  required List<String>? items,
  final Function? onTapItem,
  bool? sectInt = false,
  int? selectIndex = 0,
  String? selectName,
  bool enableScroll = false,
  double? tapBarItemsWidth,
  bool? isVertical, // 👈 متغير جديد لتحديد الاتجاه يدويًا
}) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      bool isWeb = MediaQuery.of(context).size.width > 600;
      bool useVertical = isVertical ?? isWeb; // 👈 لو محددتش، يعتمد على الويب

      double totalWidth = useVertical
          ? 200
          : (tapBarItemsWidth ?? MediaQuery.sizeOf(context).width * 0.95);
      double itemWidth = useVertical ? double.infinity : (totalWidth / 3.8);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        alignment: Alignment.center,
        height: !useVertical ? 50 : null,
        width: totalWidth,
        decoration: BoxDecoration(
          color: const Color(0xff090B5F),
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: useVertical ? 40 : 42,
                width: itemWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: (selectIndex == index || selectName == items[index])
                      ? const Color(0xff2F88FF)
                      : Colors.transparent,
                ),
                child: Text(
                  items[index].toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

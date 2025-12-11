import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';

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

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7.5),
        alignment: Alignment.center,
        height: !useVertical ? 40 : null,
        width: useVertical
            ? 200
            : (tapBarItemsWidth ?? MediaQuery.sizeOf(context).width * 0.95),
        decoration: BoxDecoration(
          color: const Color(AppColors.dark),
          borderRadius: BorderRadius.circular(25),
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
                  vertical: useVertical ? 6 : 0,
                ),
                height: useVertical ? 40 : 32,
                width: useVertical ? double.infinity : 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: (selectIndex == index || selectName == items[index])
                      ? const Color(AppColors.primary)
                      : Colors.transparent,
                ),
                child: Text(
                  items[index].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xffFFFFFF),
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

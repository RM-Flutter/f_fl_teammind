import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';

Widget defaultTapBarItem(
    {required List<String>? items,
      final Function? onTapItem,
      bool? sectInt = false,
      int? selectIndex = 0,
      String? selectName,
      bool enableScroll = false,
      double? tapBarItemsWidth}) {

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      double itemWidth =
          (tapBarItemsWidth ?? MediaQuery.sizeOf(context).width * 0.95) /
              items!.length;
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7.5),
          height: 45.0,
          alignment: Alignment.center,
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(AppColors.dark),
              borderRadius: BorderRadius.circular(25)),
          child: ListView.builder(
            shrinkWrap: true,
            reverse: false,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
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
                  height: 32,
                  width: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: (selectIndex == index || selectName == items[index])
                        ? const Color(AppColors.primary)
                        : Colors.transparent,
                  ),
                  child: Text(
                    items![index].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xffFFFFFF),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )),
            itemCount: items!.length,
          ));
    },
  );
}
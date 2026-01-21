import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_test/constants/app_colors.dart';
import 'package:app_test/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Widget defaultTapBarItem({
  required List<String>? items,
  final Function? onTapItem,
  bool? sectInt = false,
  int? selectIndex = 0,
  String? selectName,
  bool enableScroll = false,
  double? tapBarItemsWidth,
}) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      const isWeb = kIsWeb; // نحدد لو ويب أو موبايل
      double itemWidth = (tapBarItemsWidth ?? MediaQuery.sizeOf(context).width * 0.95) / items!.length;

      if (isWeb) {
        // 👈 سايد بار للويب
        return Container(
          width: 220, // عرض السايد بار
          decoration: BoxDecoration(
            color: Color(AppColors.dark),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final isSelected = (selectIndex == index || selectName == items[index]);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectIndex = index;
                    selectName = items[index];
                    if (onTapItem != null) {
                      onTapItem(index);
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? Color(AppColors.primary) : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle,
                          size: 10,
                          color: isSelected ? Colors.white : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          items[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      } else {
        // 👈 تاب بار أفقي للموبايل
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7.5),
          height: 45.0,
          alignment: Alignment.center,
          width: tapBarItemsWidth ?? MediaQuery.sizeOf(context).width * 0.95,
          decoration: BoxDecoration(
            color: Color(AppColors.dark),
            borderRadius: BorderRadius.circular(25),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: enableScroll == false
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final isSelected = (selectIndex == index || selectName == items[index]);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectIndex = index;
                    selectName = items[index];
                    if (onTapItem != null) {
                      onTapItem(index);
                    }
                  });
                },
                child: Container(
                  height: 32,
                  width: itemWidth - 8,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: isSelected ? Color(AppColors.primary) : Colors.transparent,
                  ),
                  child: Text(
                    items[index].toUpperCase(),
                    style:  const TextStyle(
                      fontSize: 10,
                      color: Color(0xffFFFFFF),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    },
  );
}

Widget defaultBottomNavigationBar(
    {required List<String>? items,
      final Function? onTapItem,
      double? tapBarItemsWidth,
      int? selectIndex = 0,
    }) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      double containerWidth = tapBarItemsWidth ?? MediaQuery.sizeOf(context).width;
      double itemWidth =(items!.length > 4)? containerWidth / items.length * 0.9 :containerWidth / items.length * 0.95;
      double itemHeight = itemWidth * 1;
      double itemRadius = (items.length > 4)?itemWidth / 2 : itemHeight;
      print("SELECTED => $selectIndex");
      return Center(
        child: Container(
          alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
            height:(items.length > 4)? itemHeight + 15 : itemHeight,
            width: containerWidth,
            decoration: BoxDecoration(
                color: const Color(0xff15223D),
                borderRadius: BorderRadius.circular(50)),
            child: ListView.builder(
              shrinkWrap: true,
              reverse: false,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectIndex = index;
                      if (onTapItem != null) {
                        onTapItem(index);
                      }
                    });
                  },
                  child: Container(
                      width: (items.length > 4)? itemWidth:itemWidth - 12,
                      height: itemHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: (selectIndex == index)
                              ? const Color(0xffFFFFFF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(itemRadius)),
                      child: SvgPicture.asset(
                        items[index],
                        color: (selectIndex == index)
                            ? const Color(0xFFE93F81)
                            : const Color(0xffFFFFFF),
                      ))),
              itemCount: items.length,
            )),
      );
    },
  );
}
// Widget defaultBottomNavigationBar(
//     {required List<String>? items,
//       void Function(int? index)? onTap,
//     double? tapBarItemsWidth,
//     int? selectIndex,
//       BuildContext? context
//     }) {
//   double containerWidth = tapBarItemsWidth ?? MediaQuery.sizeOf(context!).width;
//   double itemWidth = containerWidth / items!.length * 0.9;
//   double itemHeight = itemWidth * 1;
//   double itemRadius = itemWidth / 2;
//   int? selectIndex;
//   return StatefulBuilder(
//       builder: (context),
//   )
// }

Widget defaultProductContainer(
    {Color? containerColor,
    Color? bookmarkColor,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    required String? title,
    required String? price,
     String? unit,
    String? discountPrice,
    required BuildContext? context,
    required bool? showBookMark,
    bool showUnit = true,
      max,
    required bool? showDiscountPrice,
    double? containerWidth,
    final void Function()? onPressedBookMark,
    required String? imageUrl}) {
  return Container(
    width: containerWidth ?? MediaQuery.sizeOf(context!).width * 1,
    padding: const EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      color: containerColor ?? const Color(0xffFFFFFF),
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      boxShadow: boxShadow,
    ),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            height: 104.0,
            width: 100,
            placeholder: (context, url) => const ShimmerAnimatedLoading(
                  width: 100.0,
                  height: 104.0,
                  circularRaduis: 10,
                ),
            errorWidget: (context, url, error) =>  const Icon(
                  Icons.image_not_supported_outlined,
                )),
      ),
      const SizedBox(
        width: 16,
      ),
      SizedBox(
        width: MediaQuery.sizeOf(context!).width * 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style:  const TextStyle(
                    color: Color(0xFFE93F81),
                    
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
              Row(
                children: [
                  Text(
                    price!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  const TextStyle(
                        color: Color(0xff1B1B1B),
                        
                        fontWeight: FontWeight.w500,
                        fontSize: 13),
                  ),
                  const SizedBox(
                    width: 17,
                  ),
                  if (showDiscountPrice == true)
                    Text(
                      discountPrice!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  const TextStyle(
                        color: Colors.grey,
                        
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.grey,
                        decorationThickness: 2,
                      ),
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (showUnit == true)
                    Text(
                      unit!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  const TextStyle(
                          color: Color(0xff15223D),
                          
                          fontWeight: FontWeight.w500,
                          fontSize: 13),
                    ),
                  const Spacer(),
                  if (showBookMark == true)
                    GestureDetector(
                        onTap: onPressedBookMark,
                        child: Icon(
                          Icons.bookmark,
                          color: bookmarkColor ?? const Color(0xFFE93F81),
                        ))
                ],
              ),
            ],
          ),
        ),
      )
    ]),
  );
}

Widget defaultProfileContainer({
  required String? imageUrl,
  required String? userName,
  required String? userRole,
  required BuildContext? context,
}) {
  String formatName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length < 2) {
      return fullName; // Return the full name if no last name is provided.
    }
    String firstName = nameParts[0];
    String lastInitial = nameParts[1][0].toUpperCase();
    return (CacheHelper.getString("lang") == "ar") ?'.$firstName $lastInitial' :'$firstName $lastInitial.';
  }
  return Container(
    color: Colors.transparent,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 63,
          height: 63,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFE93F81), Color(0xff15223D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(63),
              child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                  placeholder: (context, url) => const ShimmerAnimatedLoading(
                        width: 63.0,
                        height: 63,
                        circularRaduis: 63,
                      ),
                  errorWidget: (context, url, error) =>  const Icon(
                        Icons.image_not_supported_outlined,
                      )),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context!).width * 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 23,
                child: Text(
                  userName!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xffFFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              SizedBox(
                height: 15,
                child: Text(
                  userRole!.toUpperCase(),
                  style: TextStyle(
                      color: const Color(0xffFFFFFF).withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}


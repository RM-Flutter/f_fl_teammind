import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_test/constants/app_colors.dart';

class SliderHomeMenu extends StatelessWidget {
  var title;
  var description;
  var onTap;
  var src;
  SliderHomeMenu({super.key, this.description, this.title, this.onTap, this.src});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding:const EdgeInsets.symmetric(vertical: 25),
          width: 150,
          height: 170,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
                color: Color(AppColors.textC5),
                borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsetsDirectional.only(
              bottom: 30,
              start: 2,
              end: 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style:  const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff15223D)),
                ),
                const SizedBox(height: 4,),
                Text(
                  description.toUpperCase(),
                  style:  const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff231F20)),
                ),
              ],
            ),
          ),
        ),
        Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFFE93F81),
                borderRadius: BorderRadius.circular(15)),
            child: SvgPicture.asset(src ??"assets/images/svg/ref_link.svg")
        ),
      ],
    );
  }
}
class SliderHomeMenu2 extends StatelessWidget {
  final String title;
  final String description;
  final String src;

  const SliderHomeMenu2({
    super.key,
    required this.title,
    required this.description,
    required this.src,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // تحديد عرض الكارت حسب الجهاز
    final bool isWeb = screenWidth > 600; // اعتبر فوق 600 = ويب/تابلت
    final double cardWidth = isWeb
        ? 220 // عرض ثابت مناسب للويب
        : screenWidth * 0.35; // عرض نسبي للموبايل

    final double cardHeight = cardWidth * 1.1; // ارتفاع مناسب

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: EdgeInsets.only(top: cardWidth * 0.3),
          width: cardWidth,
          height: cardHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Color(AppColors.textC5),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AutoSizeText(
                  title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style:  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff15223D),
                  ),
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  description.toUpperCase(),
                  maxLines: 2,
                  minFontSize: 8,
                  textAlign: TextAlign.center,
                  style:  const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff231F20),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: cardWidth * 0.4,
          height: cardWidth * 0.4,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(AppColors.dark),
            borderRadius: BorderRadius.circular(15),
          ),
          child: SvgPicture.asset(src),
        ),
      ],
    );
  }
}

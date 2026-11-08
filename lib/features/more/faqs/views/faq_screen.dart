import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/features/more/faqs/controllers/faq_controller.dart';
import 'package:app_test/features/more/faqs/data/models/get_faq_model.dart';
import 'package:app_test/features/more/faqs/views/widgets/faq_loading_widget.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => FaqModelProvider()..getFaq(context),
    child: Consumer<FaqModelProvider>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBarWithBookmark(
            surfaceTintColor: Colors.transparent,
            title: AppStrings.faqs.tr().toUpperCase(),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: (value.faqModel != null)?ListView.builder(
            padding: const EdgeInsets.all(16.0),
            clipBehavior: Clip.none,
            itemCount: value.faqModel!.page!.questions!.length,
            itemBuilder: (context, index) {
              return FaqTile(
                item: value.faqModel!.page!.questions![index],
              );
            },
          ):ListView.builder(
            padding: const EdgeInsets.all(16.0),
            clipBehavior: Clip.none,
            itemCount: 3,
            itemBuilder: (context, index) {
              return const FaqLoadingWidget();
            },
          ),
        );
      },
    ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class FaqTile extends StatefulWidget {
  final Questions item;

  const FaqTile({super.key, required this.item});

  @override
  _FaqTileState createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: AppBorders.card,
          boxShadow: AppShadows.card,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          title: Text(
            widget.item.question??"",
            style: AppStyles.darkContent(context).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconColor: Colors.grey,
          collapsedIconColor: Colors.grey,
          childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          expandedAlignment: Alignment.centerLeft,
          collapsedBackgroundColor: Colors.transparent,
          children: [
            Text(
              widget.item.answer ?? "",
              style: AppStyles.greyContent(context).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

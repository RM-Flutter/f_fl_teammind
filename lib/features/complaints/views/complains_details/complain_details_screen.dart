import 'package:app_test/features/complaints/controller/complaints_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/comments/comments_widget.dart';
import 'package:app_test/core/widgets/comments/logic/controller.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/widgets/full_image_screen.dart';
import 'package:app_test/features/complaints/views/complains_details/widgets/request_details_appbar_widget.dart';
import 'package:app_test/features/complaints/views/complains_details/widgets/request_details_loading_screen.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';


class ComplainDetailsScreen extends StatefulWidget {
 var id;
 var type;
 ComplainDetailsScreen({super.key, required this.id, this.type});

 @override
 State<ComplainDetailsScreen> createState() => _ComplainDetailsScreenState();
}

class _ComplainDetailsScreenState extends State<ComplainDetailsScreen> {
 late ComplaintsController requestController;
 late ScrollController _scrollController;
 Set<int> _loadedPages = {}; // Keep track of loaded pages
 final PageController _controller = PageController();
 int _currentIndex = 0;
 @override
 void initState() {
  super.initState();
  _controller.addListener(() {
   int newIndex = _controller.page?.round() ?? 0;
   if (_currentIndex != newIndex) {
    setState(() => _currentIndex = newIndex);
   }
  });
  requestController = ComplaintsController();

  _scrollController = ScrollController();
 }

 @override
 void dispose() {
  _scrollController.dispose(); // Dispose of the controller
  _controller.dispose();
  super.dispose();
 }
 @override
 Widget build(BuildContext context) {
  return MultiProvider(providers: [
   ChangeNotifierProvider(create: (context) => ComplaintsController()..getOneRequest(context, widget.id, widget.type.toString()),),
   ChangeNotifierProvider(create: (context) => CommentProvider()..getComment(context, "emp-complains", widget.id),),
  ],
   child: Consumer<ComplaintsController>(
    builder: (context, value, child) {
     if(value.isAddCommentSuccess){
      print("ADDED SUCCESS");
     }
     return Consumer<CommentProvider>(
      builder: (context, values, child) {
       return Scaffold(
        backgroundColor: Color(AppColors.background),
        body: (value.getOneRequestModel != null && value.isGetRequestCommentLoading != true
          &&!value.isGetRequestCommentLoading)?RefreshIndicator.adaptive(
         onRefresh: ()async{
          await value.getOneRequest(context, widget.id, widget.type.toString());
          await values.getComment(context,"emp-complains", widget.id);
         },
         child: SingleChildScrollView(
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
            RequestDetailsAppbarWidget(
             getOneRequestModel: value.getOneRequestModel,
            ),
            SizedBox(height: 20,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 15),
             child: Center(
              child: ConstrainedBox(
               constraints: BoxConstraints(
                maxWidth: kIsWeb ? 1100 : double.infinity,
               ),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                 Html(
                   shrinkWrap: true,
                   data: value.getOneRequestModel!.complain!.details,
                   style: {
                    "h1":Style(
                     color: AppStyles.oC2Content(context).color,
                     fontSize: FontSize(26),
                     fontWeight: FontWeight.w500,
                    ),"h2":Style(
                     color: AppStyles.oC2Content(context).color,
                     fontSize: FontSize(24),
                     fontWeight: FontWeight.w500,
                    ),"h3":Style(
                     color: AppStyles.oC2Content(context).color,
                     fontSize: FontSize(22),
                     fontWeight: FontWeight.w500,
                    ),"h4":Style(
                     color: AppStyles.oC2Content(context).color,
                     fontSize: FontSize(20),
                     fontWeight: FontWeight.w500,
                    ),"h5":Style(
                     color: AppStyles.oC2Content(context).color,
                     fontSize: FontSize(18),
                     fontWeight: FontWeight.w500,
                    ),"h6":Style(
                     color: AppStyles.oC2Content(context).color,
                     fontSize: FontSize(16),
                     fontWeight: FontWeight.w500,
                    ),
                    "p": Style(
                     color: AppStyles.grey52Content(context).color,
                     lineHeight: LineHeight(1.5),
                     fontSize: FontSize(12), // Adjust font size for better visibility
                     fontWeight: FontWeight.w400,
                    ), "ul": Style(
                     color: AppStyles.bodyTextContent(context).color,
                     lineHeight: LineHeight(1.5),
                     fontSize: FontSize(18), // Adjust font size for better visibility
                     fontWeight: FontWeight.w500,
                    ),"li": Style(
                     color: AppStyles.bodyTextContent(context).color,
                     lineHeight: LineHeight(1.5),
                     fontSize: FontSize(18), // Adjust font size for better visibility
                     fontWeight: FontWeight.w500,
                    ),"ol": Style(
                     color: AppStyles.bodyTextContent(context).color,
                     lineHeight: LineHeight(1.5),
                     fontSize: FontSize(18), // Adjust font size for better visibility
                     fontWeight: FontWeight.w500,
                    ),"*": Style(
                     color: AppStyles.bodyTextContent(context).color,
                     lineHeight: LineHeight(1.5),
                     fontSize: FontSize(14), // Adjust font size for better visibility
                     fontWeight: FontWeight.w500,
                    ),
                   }),
                 SizedBox(height: 10,),
                 if(value.getOneRequestModel!.complain!.mainThumbnail != null &&value.getOneRequestModel!.complain!.mainThumbnail!.isNotEmpty)Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   if(value.getOneRequestModel!.complain!.mainThumbnail!.length > 1) Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                     SizedBox(
                      height: 300,
                      child: PageView.builder(
                       controller: _controller,
                       itemCount: value.getOneRequestModel!.complain!.mainThumbnail!.length,
                       itemBuilder: (context, index) {
                        return GestureDetector(
                         onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                             builder: (context) => FullScreenImageViewer(
                              imageUrls: value.getOneRequestModel!.complain!.mainThumbnail!,
                              file: true,
                              initialIndex: index,
                              url: true,
                              thum: false,
                             ),
                            )
                          );
                         },
                         child: CachedNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.contain,
                          imageUrl: value.getOneRequestModel!.complain!.mainThumbnail![index].file ?? "",
                          placeholder: (context, url) =>
                          const ShimmerAnimatedLoading(),
                          errorWidget: (context, url, error) => const Icon(
                           Icons.image_not_supported_outlined,
                           size: AppSizes.s32,
                           color: Colors.white,
                          ),
                         ),
                        );
                       },
                      ),
                     ),
                     Padding(
                       padding: EdgeInsets.only(bottom: 25, right: 40, left: 40),
                       child: SizedBox(
                        height: 20,
                        child: ListView.separated(
                          shrinkWrap: true,
                          reverse: false,
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) => AnimatedContainer(
                           duration: Duration(milliseconds: 300),
                           margin: EdgeInsets.symmetric(horizontal: 4),
                           width: _currentIndex == index ? 12 : 8,
                           height: _currentIndex == index ? 12 : 8,
                           decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index ? Color(AppColors.background) : Colors.grey,
                           ),
                          ), separatorBuilder: (context, index) => SizedBox(width: 5,),
                          itemCount: value.getOneRequestModel!.complain!.mainThumbnail!.length),
                       )
                     )
                    ],
                   ),
                   if(value.getOneRequestModel!.complain!.mainThumbnail!.length == 1) GestureDetector(
                    onTap: (){
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                         imageUrls: [""],
                         one: true,
                         image: value.getOneRequestModel!.complain!.mainThumbnail![0].file, initialIndex: 1, url: false,

                        ),
                       )
                     );
                    },
                    child: CachedNetworkImage(
                     fit: BoxFit.contain,
                     imageUrl: value.getOneRequestModel!.complain!.mainThumbnail![0].file ?? "",
                     placeholder: (context, url) =>
                     const ShimmerAnimatedLoading(),
                     errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: AppSizes.s32,
                      color: Colors.white,
                     ),
                    ),
                   ),
                  ],
                 ),
                 SizedBox(height: 30,),
                 Row(
                  children: [
                   Expanded(
                    child: Padding(
                     padding: EdgeInsets.symmetric(horizontal: 10),
                     child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(strokeAlign: 1, color: Color(AppColors.divider))
                      ),
                     ),
                    ),
                   ),
                   Text(AppStrings.lastedComments.tr().toUpperCase(), style: AppStyles.darkContent(context).copyWith(fontSize: 14,
                     fontWeight: FontWeight.w500)),
                   Expanded(
                    child: Padding(
                     padding: EdgeInsets.symmetric(horizontal: 10),
                     child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(strokeAlign: 1, color: Color(AppColors.divider))
                      ))),
                   ),
                  ],
                 ),
                 SizedBox(height: 10,),
                 CommentsWidget(
                   "emp-complains",
                   enable: value.getOneRequestModel!.complain!.commentStatus,
                   comments: values.comments,
                   pageNumber: values.pageNumber,
                   loading: values.isGetCommentLoading,
                   scrollController: _scrollController,
                   id : widget.id
                 ),
                 const SizedBox(height: 20,)
                ],
               ),
              ),
             ),
            )
           ],
          ),
         ),
        ): const RequestDetailsLoadingScreen(),
       );
      },
     );
    },
   ),
  );
 }
}

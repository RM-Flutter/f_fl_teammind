import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/comments/comments_widget.dart';
import 'package:app_test/core/widgets/comments/logic/controller.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/controllers/request_controller/request_controller.dart';
import 'package:app_test/modules/complain_screen/widgets/full_image_screen.dart';
import 'package:app_test/modules/complain_screen/widgets/request_details_appbar_widget.dart';
import 'package:app_test/modules/complain_screen/widgets/request_details_loading_screen.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';


  class ComplainDetailsScreen extends StatefulWidget {
    var id;
    ComplainDetailsScreen({super.key, required this.id});

  @override
  State<ComplainDetailsScreen> createState() => _ComplainDetailsScreenState();
}

class _ComplainDetailsScreenState extends State<ComplainDetailsScreen> {
  late RequestController requestController;
  late ScrollController _scrollController;
  final Set<int> _loadedPages = {}; // Keep track of loaded pages
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
    requestController = RequestController();

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
        ChangeNotifierProvider(create: (context) => RequestController()..getOneRequest(context, widget.id),),
        ChangeNotifierProvider(create: (context) => CommentProvider()..getComment(context, "csrequests", widget.id),),
      ],
      child: Consumer<RequestController>(
        builder: (context, value, child) {
          if(value.isAddCommentSuccess){
            print("ADDED SUCCESS");
          }
          return Consumer<CommentProvider>(
              builder: (context, values, child) {
                return Scaffold(
                  backgroundColor: const Color(0xffFFFFFF),
                  body: (value.getOneRequestModel != null && value.isGetRequestCommentLoading != true
                      &&!value.isGetRequestCommentLoading)?RefreshIndicator.adaptive(
                    onRefresh: ()async{
                      await value.getOneRequest(context, widget.id);
                      await values.getComment(context,"csrequests", widget.id);
                    },
                        child: GradientBgImage(
                          padding: const EdgeInsets.all(0),
                          child: SingleChildScrollView(
                                              child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RequestDetailsAppbarWidget(
                              getOneRequestModel: value.getOneRequestModel,
                              types: value.requestTypes,
                            ),
                            const SizedBox(height: 20,),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: kIsWeb ? 1100 : double.infinity,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                    Html(
                                          shrinkWrap: true,
                                          data: value.getOneRequestModel!.item!.content,
                                          style: {
                                            "h1":Style(
                                              color: const Color(AppColors.oC2Color),
                                              fontSize: FontSize(26),
                                              fontWeight: FontWeight.w500,
                                            ),"h2":Style(
                                              color: const Color(AppColors.oC2Color),
                                              fontSize: FontSize(24),
                                              fontWeight: FontWeight.w500,
                                            ),"h3":Style(
                                              color: const Color(AppColors.oC2Color),
                                              fontSize: FontSize(22),
                                              fontWeight: FontWeight.w500,
                                            ),"h4":Style(
                                              color: const Color(AppColors.oC2Color),
                                              fontSize: FontSize(20),
                                              fontWeight: FontWeight.w500,
                                            ),"h5":Style(
                                              color: const Color(AppColors.oC2Color),
                                              fontSize: FontSize(18),
                                              fontWeight: FontWeight.w500,
                                            ),"h6":Style(
                                              color: const Color(AppColors.oC2Color),
                                              fontSize: FontSize(16),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            "p": Style(
                                              color: const Color(0xff525252),
                                              lineHeight: const LineHeight(1.5),
                                              fontSize: FontSize(12), // Adjust font size for better visibility
                                              fontWeight: FontWeight.w400,
                                            ), "ul": Style(
                                              color: const Color(0xff333333),
                                              lineHeight: const LineHeight(1.5),
                                              fontSize: FontSize(18), // Adjust font size for better visibility
                                              fontWeight: FontWeight.w500,
                                            ),"li": Style(
                                              color: const Color(0xff333333),
                                              lineHeight: const LineHeight(1.5),
                                              fontSize: FontSize(18), // Adjust font size for better visibility
                                              fontWeight: FontWeight.w500,
                                            ),"ol": Style(
                                              color: const Color(0xff333333),
                                              lineHeight: const LineHeight(1.5),
                                              fontSize: FontSize(18), // Adjust font size for better visibility
                                              fontWeight: FontWeight.w500,
                                            ),"*": Style(
                                              color: const Color(0xff333333),
                                              lineHeight: const LineHeight(1.5),
                                              fontSize: FontSize(14), // Adjust font size for better visibility
                                              fontWeight: FontWeight.w500,
                                            ),
                                          }),

                                      const SizedBox(height: 10,),
                                      if(value.getOneRequestModel!.item!.mainThum != null &&value.getOneRequestModel!.item!.mainThum!.isNotEmpty)Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          if(value.getOneRequestModel!.item!.mainThum!.length > 1) Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              SizedBox(
                                                height: 300,
                                                child: PageView.builder(
                                                  controller: _controller,
                                                  itemCount: value.getOneRequestModel!.item!.mainThum!.length,
                                                  itemBuilder: (context, index) {
                                                    return  GestureDetector(
                                                      onTap: (){
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => FullScreenImageViewer(
                                                                imageUrls: value.getOneRequestModel!.item!.mainThum!,
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
                                                        imageUrl: value.getOneRequestModel!.item!.mainThum![index].file ?? "",
                                                        placeholder: (context, url) =>
                                                        const ShimmerAnimatedLoading(),
                                                        errorWidget: (context, url, error) =>  const Icon(
                                                          Icons.image_not_supported_outlined,
                                                          size: AppSizes.s32,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    );
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                  padding: const EdgeInsets.only(bottom: 25, right: 40, left: 40),
                                                  child: SizedBox(
                                                    height: 20,
                                                    child: ListView.separated(
                                                        shrinkWrap: true,
                                                        reverse: false,
                                                        physics: const ClampingScrollPhysics(),
                                                        scrollDirection: Axis.horizontal,
                                                        padding: EdgeInsets.zero,
                                                        itemBuilder: (context, index) => AnimatedContainer(
                                                          duration: const Duration(milliseconds: 300),
                                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                                          width: _currentIndex == index ? 12 : 8,
                                                          height: _currentIndex == index ? 12 : 8,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: _currentIndex == index ? const Color(0xffFFFFFF) : Colors.grey,
                                                          ),
                                                        ), separatorBuilder: (context, index) => const SizedBox(width: 5,),
                                                        itemCount: value.getOneRequestModel!.item!.mainThum!.length),
                                                  )
                                              )
                                            ],
                                          ),
                                          if(value.getOneRequestModel!.item!.mainThum!.length == 1) GestureDetector(
                                            onTap: (){
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => FullScreenImageViewer(
                                                      imageUrls: const [""],
                                                      one:  true,
                                                      image: value.getOneRequestModel!.item!.mainThum![0].file, initialIndex: 1, url: false,

                                                    ),
                                                  )
                                              );
                                            },
                                            child: CachedNetworkImage(
                                              fit: BoxFit.contain,
                                              imageUrl: value.getOneRequestModel!.item!.mainThum![0].file ?? "",
                                              placeholder: (context, url) =>
                                              const ShimmerAnimatedLoading(),
                                              errorWidget: (context, url, error) =>  const Icon(
                                                Icons.image_not_supported_outlined,
                                                size: AppSizes.s32,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 30,),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(strokeAlign: 1, color: const Color(0xffDFDFDF))
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(AppStrings.lastedComments.tr().toUpperCase(), style: TextStyle(fontSize: 14,
                                              fontWeight: FontWeight.w500, color: Color(AppColors.dark))),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(strokeAlign: 1, color: const Color(0xffDFDFDF))
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10,),
                                      CommentsWidget(
                                          "csrequests",
                                          enable: value.getOneRequestModel!.item!.commentStatus!.key,
                                          comments: values.comments,
                                          pageNumber:  values.pageNumber,
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

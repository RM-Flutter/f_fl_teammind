// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:rmemp/modules/home/view_models/home.viewmodel.dart';
// import 'package:rmemp/modules/home/views/widgets/loading/home_appbar_loading.dart';
// import 'package:rmemp/modules/home/views/widgets/loading/home_body_loading.dart';
//
// import '../../../routing/app_router.dart';
//
// class WaitingScreen extends StatefulWidget {
//   const WaitingScreen({super.key});
//
//   @override
//   State<WaitingScreen> createState() => _WaitingScreenState();
// }
//
// class _WaitingScreenState extends State<WaitingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(create: (context) => HomeViewModel()..initializeHomeScreen(context, [
//       "general_settings",
//       "user_settings",
//       "user2_settings",
//       "check_auth"
//     ]),
//     child: Consumer<HomeViewModel>(
//         builder: (context, value, child) {
//           if(value.isSuccess == true){
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               context.goNamed(AppRoutes.home.name,
//                   pathParameters: {'lang': context.locale.languageCode,});
//               setState(() {
//                 value.isSuccess = false;
//               });
//             });
//           }
//
//           return const Column(
//             children: [
//               HomeAppbarLoading(),
//               SizedBox(height: 15,),
//               HomeLoadingPage(),
//             ],
//           );
//         },
//     ),
//     );
//   }
// }

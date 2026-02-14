
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:dio/dio.dart';

class PointsController extends ChangeNotifier {
  int selectedIndex = 0;
  bool isLoading  = false;
  bool isSuccess = false;
  bool isRedeemLoading  = false;
  bool isRedeemSuccess = false;
  Map<String, TextEditingController> controllers = {};
  List<String> fields = [];
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController pointsController = TextEditingController();
  TextEditingController dataNameController = TextEditingController();
  TextEditingController dataIdController = TextEditingController();
  var type;
  var userName;
  var redeemCode;
  List prizes = [];
  bool? status;
  List newPrizes = [];
  List categories = [];
  int currentPage = 1;
  final int itemsCount = 9;
  bool hasMore = false;
  bool hasMorePrizes = false;
  final int expectedPageSize = 9;
  String? getPrizeErrorMessage;
  String? postPrizeErrorMessage;
  Set<int> prizeIds = {}; // Track unique product IDs
  Set<int> cPrizeIds = {}; // Track unique product IDs
  int? selectIndex;
  bool hasMoreData(int length) {
    if (length < expectedPageSize) {
      return false;
    } else {
      currentPage += 1;
      return true;
    }
  }
  Future<void> refreshPaints(context, id) async{
    currentPage = 1;
    hasMore = true;
    await getPrize(page : 1,context, id);
  }Future<void> refreshCategoriesPaints(context) async{
    currentPage = 1;
    hasMore = true;
    await getCategoriesPrize(page : 1,context);
  }
  Future<void> getPrize(BuildContext context,id, {int? page}) async {
    if(page != null){currentPage = page;}
    print("currentPage is --> $currentPage}");
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/prizes/entities-operations?category_id=$id",
        context: context, // Pass this explicitly only if necessary
        query: {
          "itemsCount": itemsCount,
          "page": page ?? currentPage,
        },
      );

      if(response.data['data'] != null && response.data['data'].isNotEmpty){
        hasMorePrizes = true;
        newPrizes = response.data['data'] ?? [];
        currentPage++;
      }else{
        hasMorePrizes = false;
      }
      List uniqueNotifications = newPrizes.where((p) => !prizeIds.contains(p['id'])).toList();
      if (page == 1) {
        prizes.clear(); // Clear only when loading the first page
      }
      if(response.data['status'] == false){
        Fluttertoast.showToast(
            msg:response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        if (newPrizes.isNotEmpty && response.data['data'] != null && response.data['data'].isNotEmpty) {
          isLoading = false;
          prizes.addAll(uniqueNotifications);
          print("LENGTH IS --> ${newPrizes.length}");
        } else {
          hasMorePrizes = false;
        }}
      isLoading = true;
    } catch (error) {
      getPrizeErrorMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> getCategoriesPrize(BuildContext context, {int? page, bool? isNewPage,}) async {
    if(page != null){currentPage = page;}
    print("currentPage is --> $currentPage}");
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/prize-categories/entities-operations",
        context: context, // Pass this explicitly only if necessary
        query: {
          "itemsCount": itemsCount,
          "page": page ?? currentPage,
        },
      );

      if (response.data['data'] != null && response.data['data'].isNotEmpty) {
        hasMore = true;
        print("MORE IS $hasMore");
        categories = response.data['data'];

        List cPrizeIds = response.data['data'];
        List uniqueProducts = cPrizeIds.where((p) => !cPrizeIds.contains(p['id'])).toList();
        if (isNewPage == true) {
          categories.addAll(uniqueProducts);
        } else {
          categories = uniqueProducts;
          print("PRODUCTS SUCCESS");
        }
        cPrizeIds.addAll(uniqueProducts.map((p) => p['id']));

        if (hasMore) currentPage++;
      }else{
        hasMore = false;
      }
      List cuniqueNotifications = categories.where((p) => !cPrizeIds.contains(p['id'])).toList();
      if (page == 1) {
        prizes.clear(); // Clear only when loading the first page
      }
      if(response.data['status'] == false){
        status = false;
        Fluttertoast.showToast(
            msg:response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        if (categories.isNotEmpty) {
          isLoading = false;
          status = true;
          prizes.addAll(cuniqueNotifications);
          print("LENGTH IS --> ${categories.length}");
        } else {
        }}
      isLoading = false;
      print("GOODS");
      notifyListeners();
    } catch (error) {
      getPrizeErrorMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> postRedeemPrize(context, {id, name, phone, nationalId}) async {
    isRedeemLoading = true;
    notifyListeners();
    DioHelper.postData(
      url: "/rm_pointsys/v1/prizes",
      context: context,
      data: {
        "prize_id" :id,
        if(dataNameController.text.isNotEmpty) "name" : dataNameController.text,
        if(phoneController.text.isNotEmpty) "phone" : countryCodeController.text.isNotEmpty?"${countryCodeController.text}${phoneController.text}" : '+20${phoneController.text}',
        if(dataIdController.text.isNotEmpty) "national_id" : dataIdController.text,
      },
    ).then((value){
      if(value.data["status"] == true){
        if(value.data['code'] != null){
          redeemCode = value.data['code'];
        }
        isRedeemSuccess = true;
        // Fluttertoast.showToast(
        //     msg: value.data['message'],
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 5,
        //     backgroundColor: Colors.green,
        //     textColor: Colors.white,
        //     fontSize: 16.0
        // );
      }else{
        Fluttertoast.showToast(
            msg: value.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        AlertsService.error(
            context: context,
            message: value.data['message'],
            title: AppStrings.failed.tr());
      }
      isRedeemLoading = false;
      notifyListeners();
    }).catchError((error){
      if (error is DioError) {
        postPrizeErrorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        postPrizeErrorMessage = error.toString();
      }
      print("postPrizeErrorMessage --> $postPrizeErrorMessage");
      AlertsService.error(
          context: context,
          message: postPrizeErrorMessage!,
          title: AppStrings.failed.tr());
      isRedeemLoading = false;
      notifyListeners();
    });
  }
  Future<void> postTransferPoints(context, {confirmed = false, user, amount}) async {
    isRedeemLoading = true;
    notifyListeners();
    DioHelper.postData(
      url: "/rm_pointsys/v1/transfer-points",
      context: context,
      data: {
        "user" : (user != null && user.isNotEmpty)? user : countryCodeController.text.isEmpty ? '+20${phoneController.text}' : "${countryCodeController.text}${phoneController.text}",
        "amount" : (amount != null && amount.isNotEmpty)?amount : pointsController.text,
        if(confirmed == true) "confirmed" : confirmed
      },
    ).then((value){
      if(value.data["status"] == true){
        isRedeemSuccess = true;
        if(value.data['data'] != null){ userName = value.data['data']['user_namme'];}
      }else{
        Fluttertoast.showToast(
            msg: value.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        // AlertsService.error(
        //     context: context,
        //     message: value.data['message'],
        //     title: AppStrings.failed.tr());
      }
      isRedeemLoading = false;
      notifyListeners();
    }).catchError((error){
      if (error is DioError) {
        postPrizeErrorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        postPrizeErrorMessage = error.toString();
      }
      print("postPrizeErrorMessage --> $postPrizeErrorMessage");
      Fluttertoast.showToast(
          msg: postPrizeErrorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      // AlertsService.error(
      //     context: context,
      //     message: postPrizeErrorMessage!,
      //     title: AppStrings.failed.tr());
      isRedeemLoading = false;
      notifyListeners();
    });
  }
  void changeIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

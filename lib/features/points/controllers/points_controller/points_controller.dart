
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/features/points/data/repositories/history_repository/points_repo.dart';
import 'package:dio/dio.dart';

class PointsController extends ChangeNotifier {
  int selectedIndex = 0;
  bool isLoading  = false;
  bool isSuccess = false;
  bool isAddFriendContactSuccess  = false;
  bool isRedeemLoading  = false;
  bool isAddFriendLoading  = false;
  bool isAddFriendSuccess = false;
  bool isRedeemSuccess = false;
  Map<String, TextEditingController> controllers = {};
  List<String> fields = [];
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController pointsController = TextEditingController();
  TextEditingController dataNameController = TextEditingController();
  TextEditingController dataIdController = TextEditingController();
  TextEditingController friendNameController = TextEditingController();
  String? errorHistoryMessage;
  var type;
  var userName;
  var redeemCode;
  List prizes = [];
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
  Future<void> addFriend(BuildContext context) async {
    isAddFriendLoading = true;
    if(countryCodeController.text.isEmpty){
      countryCodeController.text = "+20";
    }
    notifyListeners();
    try {
      final response = await PointsRepo.addFriend(
        context: context,
        items: [
          {
            "name": friendNameController.text,
            "country_code": countryCodeController.text,
            "phonesNumbers": [phoneController.text],
          }
        ],
      );
      if(response.data['status']== false){
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        isAddFriendSuccess = true;
        countryCodeController.clear();
        phoneController.clear();
        friendNameController.clear();
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      isAddFriendLoading = false;
      notifyListeners();
    } catch (error) {
      errorHistoryMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg:errorHistoryMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isAddFriendLoading = false;
      notifyListeners();

    }
  }
  Future<void> addFriendContact(BuildContext context, {contact}) async {
    isAddFriendLoading = true;
    if(countryCodeController.text.isEmpty){
      countryCodeController.text = "+20";
    }
    notifyListeners();
    try {
      final response = await PointsRepo.addFriend(
        context: context,
        items: List<Map<String, dynamic>>.from(contact["items"] ?? []),
      );
      if(response.data['status']== false){
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        isAddFriendContactSuccess = true;
        countryCodeController.clear();
        phoneController.clear();
        friendNameController.clear();
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      isAddFriendLoading = false;
      notifyListeners();
    } catch (error) {
      errorHistoryMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg:errorHistoryMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isAddFriendLoading = false;
      notifyListeners();

    }
  }
  Future<void> getPrize(BuildContext context,id, {int? page}) async {
    if(page != null){currentPage = page;}
    debugPrint("currentPage is --> $currentPage}");
    isLoading = true;
    notifyListeners();
    try {
      final response = await PointsRepo.getPrizesByCategory(
        context: context,
        categoryId: id.toString(),
        itemsCount: itemsCount,
        page: page ?? currentPage,
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
        debugPrint("LENGTH IS --> ${newPrizes.length}");
      } else {
        hasMorePrizes = false;
      }}
      isLoading = true;
    } catch (error) {
      getPrizeErrorMessage = error is DioException
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
    debugPrint("currentPage is --> $currentPage}");
    isLoading = true;
    notifyListeners();
    try {
      final response = await PointsRepo.getPrizeCategories(
        context: context,
        itemsCount: itemsCount,
        page: page ?? currentPage,
      );

      if (response.data['data'] != null && response.data['data'].isNotEmpty) {
        hasMore = true;
        debugPrint("MORE IS $hasMore");
        categories = response.data['data'];

        List cPrizeIds = response.data['data'];
        List uniqueProducts = cPrizeIds.where((p) => !cPrizeIds.contains(p['id'])).toList();
        if (isNewPage == true) {
          categories.addAll(uniqueProducts);
        } else {
          categories = uniqueProducts;
          debugPrint("PRODUCTS SUCCESS");
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
        prizes.addAll(cuniqueNotifications);
        debugPrint("LENGTH IS --> ${categories.length}");
      } else {
      }}
      isLoading = false;
      debugPrint("GOODS");
      notifyListeners();
    } catch (error) {
      getPrizeErrorMessage = error is DioException
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
    PointsRepo.redeemPrizeViaPointsys(
      context: context,
      prizeId: id.toString(),
      name: dataNameController.text.isNotEmpty ? dataNameController.text : null,
      phone: phoneController.text.isNotEmpty
          ? (countryCodeController.text.isNotEmpty
              ? "${countryCodeController.text}${phoneController.text}"
              : '+20${phoneController.text}')
          : null,
      nationalId: dataIdController.text.isNotEmpty ? dataIdController.text : null,
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
      if (error is DioException) {
        postPrizeErrorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        postPrizeErrorMessage = error.toString();
      }
      debugPrint("postPrizeErrorMessage --> $postPrizeErrorMessage");
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
    PointsRepo.transferPoints(
      context: context,
      user: (user != null && user.isNotEmpty)
          ? user
          : (countryCodeController.text.isEmpty
              ? '+20${phoneController.text}'
              : "${countryCodeController.text}${phoneController.text}"),
      amount: (amount != null && amount.isNotEmpty) ? amount : pointsController.text,
      confirmed: confirmed == true,
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
      if (error is DioException) {
        postPrizeErrorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        postPrizeErrorMessage = error.toString();
      }
      debugPrint("postPrizeErrorMessage --> $postPrizeErrorMessage");
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

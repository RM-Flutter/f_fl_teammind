import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/constants/app_strings.dart';
import 'package:app_test/general_services/localization.service.dart';
import 'package:provider/provider.dart';
import '../logic/history_cubit/history_provider.dart';
import 'history_drop_down_widget.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    // Step 1: Parse the date string from the API

    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.state == HistoryState.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (provider.state == HistoryState.failure) {
          return Center(
            child: Text('Error: ${provider.errorMessage}'),
          );
        } else if (provider.state == HistoryState.success) {
          return provider.historyModel!.history != null && provider.historyModel!.history!.isNotEmpty ?
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
                children: provider.historyModel!.history!.map(
              (e) {
                String apiDate = e.createdAt!;
                DateTime parsedDate =
                    DateTime.parse(apiDate); // Parses ISO 8601 format

                // Step 2: Format the parsed date
                  String formattedDate =
                      DateFormat('MMM d, yyyy',LocalizationService.isArabic(context: context)? "ar": "en").format(parsedDate);
                return GestureDetector(
                  onTap: (){
                    print("e.notes ---> ${e.notes}");
                    print("e.code ---> ${e.code}");
                    if((e.notes != null && e.notes != "") || (e.code != null && e.code != "")){
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // Allow full screen interaction
                          builder: (BuildContext context) {
                            return HistoryDropDownWidget(
                                code: e.code?.toString() ?? "", notes: e.notes?.toString() ?? "");
                          }
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: 90,
                      width: kIsWeb? 800:double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 0,
                              offset: const Offset(0, 1),
                              blurRadius: 10)
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Image(
                              image: AssetImage('assets/images/png/gift.png'),
                              height: 40,
                              width: 40,
                              fit: BoxFit.fill,
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    e.title!,
                                    maxLines: 2,
                                    style:  const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff464646),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    e.operation == "deposit"
                                        ? "+${e.points} ${AppStrings.points.tr()}"
                                        : "-${e.points} ${AppStrings.points.tr()}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: e.operation == "deposit"
                                          ? Colors.green
                                          : const Color(0xffFF0004),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList()),
          ) : const SizedBox.shrink();
        } else {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                provider.getHistory();
              },
              child: Text(AppStrings.loadHistory.tr()),
            ),
          );
        }
      },
    );
  }
}

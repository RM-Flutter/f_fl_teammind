import 'package:app_test/core/widgets/details_loading/details_loading.widget.dart';
import 'package:flutter/material.dart';

/// Loading skeleton of this details screen: the 300 high navy header, then centred text.
/// It is the shared [DetailsLoadingWidget] so every details screen loads the same way.
class NotificationDetailsLoadingScreen extends StatelessWidget {
  const NotificationDetailsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailsLoadingWidget(
      headerHeight: 300,
      showTabs: false,
      cards: 0,
      textLines: 5,
    );
  }
}

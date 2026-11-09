import 'package:app_test/core/widgets/details_loading/details_loading.widget.dart';
import 'package:flutter/material.dart';

/// Loading skeleton of this details screen: the 300 high navy header, then centred text.
/// It is the shared [DetailsLoadingWidget] so every details screen loads the same way.
class RequestDetailsLoadingScreen extends StatelessWidget {
  const RequestDetailsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailsLoadingWidget(
      headerHeight: 240,
      showTabs: false,
      cards: 0,
      textLines: 5,
    );
  }
}

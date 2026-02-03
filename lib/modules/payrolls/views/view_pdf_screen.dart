import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';


class PdfViewerScreen extends StatelessWidget {
  var localFilePath;
  PdfViewerScreen(this.localFilePath);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(
        AppStrings.pdfViewer.tr().toUpperCase(),
        style: TextStyle(color: Color(AppColors.dark), fontWeight: FontWeight.bold, fontSize: 20),
      ),),
      body: localFilePath == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        filePath: localFilePath!,
      ),
    );
  }
}

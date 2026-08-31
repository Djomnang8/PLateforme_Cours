import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../services/api_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final int courseId;
  final int documentId;
  final String documentName;
  const PdfViewerScreen({
    super.key,
    required this.courseId,
    required this.documentId,
    required this.documentName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  double _lastSentPercent = 0;
  Timer? _timer;
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onScrollChanged(PdfScrollOffsetDetails details) {
    final maxScroll = details.maxOffset;
    final currentScroll = details.offset;
    if (maxScroll.dy <= 0) return;
    final percent = (currentScroll.dy / maxScroll.dy * 50).clamp(0, 50).round();
    if ((percent - _lastSentPercent).abs() > 1) {
      _lastSentPercent = percent.toDouble();
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 500), () {
        ApiService.updateScrollProgress(widget.courseId, percent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.documentName)),
      body: SfPdfViewer.network(
        '${ApiService.baseUrl}/courses/${widget.courseId}/documents/${widget.documentId}',
        controller: _pdfViewerController,
        onPageChanged: (details) {
          _onScrollChanged(PdfScrollOffsetDetails(
            offset: _pdfViewerController.offset,
            maxOffset: _pdfViewerController.maxOffset,
            isHorizontal: false,
          ));
        },
      ),
    );
  }
}
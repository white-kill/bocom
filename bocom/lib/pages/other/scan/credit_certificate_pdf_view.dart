import 'dart:io';

import 'package:bocom/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

const _pdfPageGap = 8.0;

PdfPageLayout _layoutPdfPages(
  List<PdfPage> pages,
  PdfViewerParams _,
) {
  var width = 0.0;
  for (final page in pages) {
    if (page.width > width) width = page.width;
  }

  final pageLayouts = <Rect>[];
  var y = 0.0;
  for (var index = 0; index < pages.length; index++) {
    final page = pages[index];
    pageLayouts.add(
      Rect.fromLTWH(
        (width - page.width) / 2,
        y,
        page.width,
        page.height,
      ),
    );
    y += page.height;
    if (index < pages.length - 1) y += _pdfPageGap;
  }

  return PdfPageLayout(
    pageLayouts: pageLayouts,
    documentSize: Size(width, y),
  );
}

int? _calculateCurrentPdfPage(
  Rect visibleRect,
  List<Rect> pageLayouts,
  PdfViewerController _,
) {
  int? currentPage;
  var largestVisibleArea = 0.0;
  for (var index = 0; index < pageLayouts.length; index++) {
    final intersection = pageLayouts[index].intersect(visibleRect);
    if (intersection.isEmpty) continue;
    final visibleArea = intersection.width * intersection.height;
    if (visibleArea > largestVisibleArea) {
      largestVisibleArea = visibleArea;
      currentPage = index + 1;
    }
  }
  return currentPage;
}

class CreditCertificatePdfPage extends StatefulWidget {
  const CreditCertificatePdfPage({required this.pdfUri, super.key});

  final Uri pdfUri;

  @override
  State<CreditCertificatePdfPage> createState() =>
      _CreditCertificatePdfPageState();
}

class _CreditCertificatePdfPageState extends State<CreditCertificatePdfPage> {
  final PdfViewerController _controller = PdfViewerController();
  int _currentPage = 1;
  int _pageCount = 0;
  int _reloadVersion = 0;

  Map<String, String> get _headers => {
        HttpHeaders.authorizationHeader: token,
        'client_type': 'APP',
        'banktype': '5',
        'BANKTYPE': '5',
        'login_device': Platform.isIOS ? '1' : '2',
      };

  void _setPageCount(PdfDocument document) {
    if (!mounted) return;
    setState(() {
      _pageCount = document.pages.length;
      _currentPage = _currentPage.clamp(1, _pageCount);
    });
  }

  void _setCurrentPage(int? pageNumber) {
    if (!mounted || pageNumber == null || pageNumber == _currentPage) return;
    setState(() => _currentPage = pageNumber);
  }

  void _reload() {
    setState(() {
      _reloadVersion++;
      _currentPage = 1;
      _pageCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: const Key('credit-certificate-pdf-page'),
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _PdfNavigation(),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: PdfViewer.uri(
                        widget.pdfUri,
                        key: ValueKey(_reloadVersion),
                        controller: _controller,
                        headers: _headers,
                        params: PdfViewerParams(
                          margin: 0,
                          layoutPages: _layoutPdfPages,
                          backgroundColor: const Color(0xFF9A9A9A),
                          pageDropShadow: null,
                          onViewerReady: (document, _) =>
                              _setPageCount(document),
                          calculateCurrentPageNumber: _calculateCurrentPdfPage,
                          onPageChanged: _setCurrentPage,
                          loadingBannerBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                          errorBannerBuilder: (_, __, ___, ____) => Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '证明电子版加载失败',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _reload,
                                  child: const Text('重新加载'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_pageCount > 0)
                      Positioned(
                        left: 20,
                        top: 12,
                        child: Container(
                          key: const Key('credit-certificate-pdf-page-number'),
                          height: 30,
                          constraints: const BoxConstraints(minWidth: 48),
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xC7555555),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '$_currentPage/$_pageCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfNavigation extends StatelessWidget {
  const _PdfNavigation();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              '资信证明电子版',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Semantics(
                button: true,
                label: '返回',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: SizedBox(
                    width: 54,
                    child: Center(
                      child: Image.asset(
                        'assets/images/scan/back.png',
                        width: 9,
                        height: 17,
                        color: const Color(0xFF111111),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

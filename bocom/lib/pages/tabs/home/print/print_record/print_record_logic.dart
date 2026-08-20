import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../print_confim/print_export_repository.dart';
import 'print_record_state.dart';

class PrintRecordLogic extends GetxController {
  PrintRecordLogic({PrintRecordPageLoader? pageLoader})
      : _pageLoader = pageLoader ?? loadPrintRecordPage;

  static const _pageSize = 10;

  final PrintRecordState state = PrintRecordState();
  final PrintRecordPageLoader _pageLoader;
  final records = <PrintExportRecord>[].obs;
  final loading = true.obs;
  final loadFailed = false.obs;
  final loadingMore = false.obs;
  final pageNum = 0.obs;
  final pages = 0.obs;
  int _requestVersion = 0;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  Future<bool> loadRecords({
    bool loadMore = false,
    bool preserveContent = false,
  }) async {
    if (loadMore &&
        (loadingMore.value ||
            (pages.value > 0 && pageNum.value >= pages.value))) {
      return false;
    }
    final version = loadMore ? _requestVersion : ++_requestVersion;
    final nextPage = loadMore ? pageNum.value + 1 : 1;
    if (loadMore) {
      loadingMore.value = true;
    } else if (!preserveContent) {
      loading.value = true;
      loadFailed.value = false;
      pageNum.value = 0;
      pages.value = 0;
    }

    try {
      final result = await _pageLoader(nextPage, _pageSize);
      if (version != _requestVersion) {
        if (loadMore) loadingMore.value = false;
        return false;
      }
      records.assignAll(
        loadMore ? [...records, ...result.records] : result.records,
      );
      pageNum.value = nextPage;
      pages.value = result.pages;
      loading.value = false;
      loadingMore.value = false;
      loadFailed.value = false;
      return true;
    } catch (_) {
      if (version != _requestVersion) {
        if (loadMore) loadingMore.value = false;
        return false;
      }
      loading.value = false;
      loadingMore.value = false;
      if (!preserveContent || records.isEmpty) loadFailed.value = true;
      return false;
    }
  }

  Future<void> refreshRecords(RefreshController controller) async {
    try {
      await loadRecords(preserveContent: true);
    } finally {
      controller
        ..resetNoData()
        ..refreshCompleted();
    }
  }

  Future<void> loadMoreRecords(RefreshController controller) async {
    if (pages.value == 0 || pageNum.value >= pages.value) {
      controller.loadNoData();
      return;
    }
    final succeeded = await loadRecords(loadMore: true);
    if (!succeeded) {
      controller.loadFailed();
    } else if (pageNum.value >= pages.value) {
      controller.loadNoData();
    } else {
      controller.loadComplete();
    }
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }
}

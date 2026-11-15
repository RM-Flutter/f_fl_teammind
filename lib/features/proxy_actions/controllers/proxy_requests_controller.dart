import 'package:flutter/material.dart';

import '../data/models/proxy_request_model.dart';
import '../data/repos/proxy_repo.dart';

/// "My proxy requests": leaves this manager created on behalf of employees, page by page.
class ProxyRequestsController extends ChangeNotifier {
  static const int pageSize = 10;

  final List<ProxyRequestModel> requests = [];
  int _page = 0;
  int _total = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;

  bool get hasMore => requests.length < _total;

  Future<void> refresh(BuildContext context) async {
    _page = 0;
    _total = 0;
    requests.clear();
    error = null;
    isLoading = true;
    notifyListeners();
    await _loadNext(context);
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore(BuildContext context) async {
    if (isLoading || isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    notifyListeners();
    await _loadNext(context);
    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _loadNext(BuildContext context) async {
    final res = await ProxyRepo.myProxyRequests(context, page: _page + 1, limit: pageSize);
    if (!res.result.success) {
      error = res.result.message;
      return;
    }
    _page++;
    _total = res.total;
    requests.addAll(res.requests);
    // A server that sends no total: stop when a page comes back short.
    if (res.requests.length < pageSize) _total = requests.length;
  }
}

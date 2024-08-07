import 'package:flutter/foundation.dart';

class WebViewModel extends ChangeNotifier {
  String _currentUrl = "https://www.google.com";
  final List<String> _bookmarks = [];

  String get currentUrl => _currentUrl;
  List<String> get bookmarks => _bookmarks;

  void setUrl(String url) {
    _currentUrl = url;
    notifyListeners();
  }

  void addBookmark(String url) {
    if (!_bookmarks.contains(url)) {
      _bookmarks.add(url);
      notifyListeners();
    }
  }

  void removeBookmark(String url) {
    _bookmarks.remove(url);
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  ConnectivityResult get connectionStatus => _connectionStatus;

  ConnectivityProvider() {
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _connectionStatus = connectivityResult;
    notifyListeners();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result;
      notifyListeners();
    });
  }

  bool get isConnected =>
      _connectionStatus == ConnectivityResult.mobile ||
          _connectionStatus == ConnectivityResult.wifi;
}

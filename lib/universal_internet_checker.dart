library universal_internet_checker;

import 'dart:async';
import 'package:doh_client/doh_client.dart';
//import 'package:flutter/foundation.dart' show kIsWeb;

class UniversalInternetChecker {
  /// Static method to check if it's connected to internet
  /// lookUpAddress: String to use as lookup address to check internet connection
  static Future<bool> checkInternet() async {
    try {
      var dohResponse = await DoH(DoHProvider.google)
          .lookup('google.com', RecordType.A, dnssec: true);
      if (dohResponse != null) {
        if (dohResponse.httpStatus == 200) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Timer to check periodically the internet status
  Timer? _timer;

  /// Last status for connection
  bool? _lastStatus;

  /// String to use as look up address
  //String? _lookUpAddress;

  /// Value to indicate to timer the duration of every loop
  final Duration _duration = const Duration(milliseconds: 1500);

  /// Stream controller to emit a notifier when connection status changes
  final StreamController<bool> _streamController =
      StreamController<bool>.broadcast();

  /// Get method to return the stream from stream controller
  Stream<bool> get onConnectionChange => _streamController.stream;

  /// Constructor to return the same instance for every new initialization
  factory UniversalInternetChecker() => _instance;

  /// Private instance for current class
  static final UniversalInternetChecker _instance =
      UniversalInternetChecker._();

  /// Factory to init the class constructor
  UniversalInternetChecker._() {
    _streamController.onListen = _setupPolling;

    _streamController.onCancel = () {
      _timer?.cancel();
      _lastStatus = null;
    };
  }

  /// Method to set the lookup address
  // void setLookUpAddress(String? lookUpAddress) {
  //   _lookUpAddress = lookUpAddress;
  // }

  void _setupPolling() {
    _timer?.cancel();
    _checkAndBroadcast();
    _timer = Timer.periodic(_duration, _checkAndBroadcast);
  }

  /// Method to check the connection status according the duration
  void _checkAndBroadcast([Timer? timer]) async {
    // _timerHandler?.cancel();
    // timer?.cancel();

    bool isConnected = await UniversalInternetChecker.checkInternet();

    print('connection status: $isConnected');

    if (_lastStatus != isConnected && _streamController.hasListener)
      _streamController.add(isConnected);

    //TODO:move
    if (!_streamController.hasListener) return;

    _lastStatus = isConnected;
  }
}

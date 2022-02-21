library universal_internet_checker;

import 'dart:async';
import 'package:http/http.dart' as http;

class UniversalInternetChecker {
  static Uri doHService = DoHServices.cloudflare;

  static final Duration _intervalOffline = Duration(seconds: 5);
  static final Duration _intervalOnline = Duration(seconds: 25);
  //nice if perfect multiples

  //the number of iterations that the program should skip checking
  static final int maxSkipCount =
      _intervalOnline.inSeconds % _intervalOffline.inSeconds; //5 times

  //variable to track runcount
  late int currentSkipCount;

  //the domain to ask dns for
  static String checkAddress = 'google.com';

  /// Last status for connection
  ConnectionStatus _lastStatus = ConnectionStatus.unknown;

  /// Timer to check periodically the internet status
  late Timer _timer;

  /// Stream controller to emit a notifier when connection status changes
  /// TODO:static?
  final _streamController = StreamController<ConnectionStatus>.broadcast();

  /// Get method to return the stream from stream controller
  Stream<ConnectionStatus> get onConnectionChange => _streamController.stream;

  /// Constructor to return the same instance for every new initialization
  factory UniversalInternetChecker() => _instance;

  /// Private instance for current class
  static final UniversalInternetChecker _instance =
      UniversalInternetChecker._();

  /// Factory to init the class constructor
  UniversalInternetChecker._() {
    _streamController.onListen = _setupPolling;

    _streamController.onCancel = () {
      _timer.cancel();
      _lastStatus = ConnectionStatus.unknown;
    };
  }
  
  void dispose() {
     _streamController.close();
  }

  void _setupPolling() {
    _checkAndBroadcast();
    _timer = Timer.periodic(_intervalOffline, _checkAndBroadcast);
  }

  /// Method to check the connection status according the duration
  void _checkAndBroadcast([Timer? timer]) async {
    if (!_streamController.hasListener) return;

    ConnectionStatus _currentStatus = await checkInternet();

    if (_currentStatus == _lastStatus) return; //do nothing if nothing to update
    //if last status is online, check only if we have not checked in 10 seconds
    if (_lastStatus == ConnectionStatus.online &&
        _currentStatus == ConnectionStatus.offline) {
      //if it comes here, then at least one bradcast has happened
      //because initial status is ConnectionStatus.unknown
      if (currentSkipCount < maxSkipCount) {
        //don't update listener for 1st, 2nd, 3rd and 4th run if online
        currentSkipCount += 1;
        return;
      } //broadcast offline status if 5th count
    }
    _streamController.add(_currentStatus);
    print('connection status changed: $_currentStatus');
    _lastStatus = _currentStatus;
    currentSkipCount = 1; //reset the counter if broadcast
  }

  /// Static method to check if it's connected to internet
  /// lookUpAddress: String to use as lookup address to check internet connection
  static Future<ConnectionStatus> checkInternet() async {
    try {
      // Init request query parameters and send request
      http.Response response = await http.get(
          doHService.replace(queryParameters: {
            'name': checkAddress,
            'type': 'A',
            'dnssec': '1'
          }),
          headers: {
            'Accept': 'application/dns-json'
          }).timeout(Duration(milliseconds: 4500));

      // Close & retrive response
      if (response.statusCode == 200) {
        return ConnectionStatus.online;
      }
      return ConnectionStatus.offline;
    } catch (e) {
      return ConnectionStatus.offline;
    }
  }
}

class DoHServices {
  static final Uri google = Uri.parse('https://dns.google.com/resolve');
  static final Uri cloudflare =
      Uri.parse('https://cloudflare-dns.com/dns-query');
  static final Uri quad9 = Uri.parse('https://dns.quad9.net:5053/dns-query');
}

enum ConnectionStatus { online, offline, unknown }

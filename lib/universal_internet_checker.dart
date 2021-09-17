library universal_internet_checker;

import 'dart:async';
import 'package:http/http.dart' as http;

class UniversalInternetChecker {
  static Uri doHService = DoHServices.cloudflare;

  static Duration _interval = Duration(milliseconds: 2000);

  //the domain to ask dns for
  static String checkAddress = 'google.com';

  /// Last status for connection
  ConnectionStatus _lastStatus = ConnectionStatus.unknown;

  /// Timer to check periodically the internet status
  late Timer _timer;

  /// Stream controller to emit a notifier when connection status changes
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

  void _setupPolling() {
    _checkAndBroadcast();
    _timer = Timer.periodic(_interval, _checkAndBroadcast);
  }

  /// Method to check the connection status according the duration
  void _checkAndBroadcast([Timer? timer]) async {
    if (!_streamController.hasListener) return;

    ConnectionStatus currentStatus = await checkInternet();

    if (_lastStatus != currentStatus && _streamController.hasListener) {
      _streamController.add(currentStatus);
      print('connection status changed: $currentStatus');
      _lastStatus = currentStatus;
    }
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
          }).timeout(Duration(milliseconds: 1200));

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

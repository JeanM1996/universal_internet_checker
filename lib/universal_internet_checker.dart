library universal_internet_checker;

import 'dart:async';
import 'dart:io';

class UniversalInternetChecker {
  static final Uri google = Uri.parse('https://dns.google.com/resolve');
  static final Uri cloudflare =
      Uri.parse('https://cloudflare-dns.com/dns-query');
  static final Uri quad9 = Uri.parse('https://dns.quad9.net:5053/dns-query');

  static Duration _interval = Duration(milliseconds: 1500);

  //the domain to ask dns for
  static String _domain = 'google.com';

  /// Last status for connection
  bool? _lastStatus;

  /// Timer to check periodically the internet status
  Timer? _timer;
  //TODO: should this timer be late?

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
    _timer = Timer.periodic(_interval, _checkAndBroadcast);
  }

  /// Method to check the connection status according the duration
  void _checkAndBroadcast([Timer? timer]) async {
    if (!_streamController.hasListener) return;

    bool isConnected = await checkInternet();

    print('connection status: $isConnected');

    if (_lastStatus != isConnected && _streamController.hasListener)
      _streamController.add(isConnected);

    _lastStatus = isConnected;
  }

  /// Static method to check if it's connected to internet
  /// lookUpAddress: String to use as lookup address to check internet connection
  static Future<bool> checkInternet() async {
    try {
      var client = HttpClient();
      // Set HttpClient timeout
      client.connectionTimeout = Duration(milliseconds: 1200);
      // Init request query parameters and send request
      var request = await client.getUrl(cloudflare.replace(
          queryParameters: {'name': _domain, 'type': 'A', 'dnssec': '1'}));
      // Set request http header (need for 'cloudflare' provider)
      request.headers.add('Accept', 'application/dns-json');
      // Close & retrive response
      var response = await request.close();
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('GET Error (probably no internet)');
      return false;
    }
  }
}

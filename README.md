# Simple Connection Checker

Listenable class to check internet connectivity in Web and Mobile
(not tested on desktop yet)

## Demo


## Installation
Include `universal_internet_checker` in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  universal_internet_checker: version
```

## Usage

To use this package, just import it into your file and call the static method *isConnectedToInternet* as follows:

```dart
import 'package:universal_internet_checker/universal_internet_checker.dart';

...

bool isConnected = await SimpleConnectionChecker.isConnectedToInternet();

...

```

**Note**: You can pass an optional parameter named *lookUpAddress* to pass an especific URL to make the lookup operation and check the internet connection. By default, this value is *www.google.com*. Do not use the protocol on the URL string passed (http:// or https://).

## New 💥

Now you can listen for internet connection changes. Here is the example

```dart
import 'package:universal_internet_checker/universal_internet_checker.dart';

...
StreamSubscription? subscription;
bool? _connected;

@override
void initState() {
  super.initState();
  SimpleConnectionChecker _simpleConnectionChecker = SimpleConnectionChecker()
      ..setLookUpAddress('pub.dev'); //Optional method to pass the lookup string
  subscription = _simpleConnectionChecker.onConnectionChange.listen((connected) {
    setState(() {
      _connected = connected;
    });
  });
}

@override
void dispose() {
  subscription?.cancel();
  super.dispose();
}

...

```

**Note**: Don't forget to cancel the subscription

## Demo
<img src="https://raw.githubusercontent.com/ajomuch92/simple-connection-checker/master/assets/demo-listen.gif" width="200" height="429"/>
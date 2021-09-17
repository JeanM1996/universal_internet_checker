# Simple Connection Checker

Listenable class to check internet connectivity in Web and Mobile
(not tested on desktop yet)

You can also use this in a StreamProvider to give network awareness to your entire app.

## Installation
Include `universal_internet_checker` in your `pubspec.yaml` file
or add it from pub:

```
flutter pub add universal_internet_checker
```

## Usage

To use this package, just import it into your file and call the static method *checkInternet* as follows:

```dart
import 'package:universal_internet_checker/universal_internet_checker.dart';

...

ConnectionStatus status = await UniversalInternetChecker.checkInternet();

...

```

**Note**: You can set the static variable "checkAddress" to a specific URL to make the operation and check the internet connection. By default, this value is *www.google.com*. Do not include (http:// or https://)  or any subdirectory in your address

```dart
UniversalInternetChecker.checkAddress = 'www.example.com';
```

**Note**: You can listen for internet connection changes. Here is the example

```dart
import 'package:universal_internet_checker/universal_internet_checker.dart';

...
StreamSubscription? subscription;
ConnectionStatus? _status;

@override
void initState() {
  super.initState();
  subscription = UniversalInternetChecker.onConnectionChange.listen((status) {
    setState(() {
      _status = status;
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

**Note**: If you're using provider, use

```dart
StreamProvider<ConnectionStatus>(
  create: (context) => UniversalInternetChecker().onConnectionChange,
  initialData: ConnectionStatus.unknown)

```
import 'dart:async';
import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that notifies listeners when multiple [Stream]s emit values.
class MultiStreamRefreshNotifier extends ChangeNotifier {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  MultiStreamRefreshNotifier(List<Stream<dynamic>> streams) {
    for (final stream in streams) {
      _subscriptions.add(
        stream.listen((_) {
          notifyListeners();
        }),
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

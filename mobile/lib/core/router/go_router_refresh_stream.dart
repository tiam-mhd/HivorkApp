import 'dart:async';
import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that notifies listeners when a [Stream] emits a value.
/// This is useful for refreshing [GoRouter] when the authentication state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

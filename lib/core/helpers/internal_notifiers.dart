import 'package:flutter/material.dart';

/// Used to notify [this] class when an internal [ValueNotifier] is changed.
abstract class InternalNotifiers extends ChangeNotifier {
  InternalNotifiers() {
    _registerListeners();
  }

  List<ValueNotifier> get internalNotifiers;

  void _registerListeners() {
    for (final notifier in internalNotifiers) {
      notifier.addListener(notifyListeners);
    }
  }

  @override
  void dispose() {
    for (final notifier in internalNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }
}

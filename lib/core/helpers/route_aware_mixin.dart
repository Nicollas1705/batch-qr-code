import 'package:flutter/material.dart';

/// A wrapper to [RouteAware].
mixin RouteAwareMixin<T extends StatefulWidget> on State<T> implements RouteAware {
  RouteObserver routeObserver();

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver().unsubscribe(this);
    routeObserver().subscribe(this, ModalRoute.of(context)!);
  }

  @override
  @mustCallSuper
  void dispose() {
    routeObserver().unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {}

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}
}

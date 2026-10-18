import 'package:flutter/widgets.dart';

import 'ads_service.dart';
import 'audio_service.dart';
import 'auth_service.dart';
import 'user_data_service.dart';

/// Per-launch state that shouldn't survive an app restart.
class AppSession {
  /// Set once the user taps "continue as guest", so we don't re-show the
  /// sign-in screen every time they start a new quiz in the same session.
  bool guestChosen = false;
}

/// Hands the app's services to any screen via `AppServices.of(context)`.
///
/// Screens depend on the abstract [AuthService] / [UserDataService] /
/// [AudioService] only, which is what lets the widget tests run the whole
/// app against in-memory fakes with no Firebase at all.
class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required this.auth,
    required this.data,
    required this.audio,
    required this.session,
    required this.ads,
    required super.child,
  });

  final AuthService auth;
  final UserDataService data;
  final AudioService audio;
  final AppSession session;
  final AdsService ads;

  static AppServices of(BuildContext context) {
    final services =
        context.dependOnInheritedWidgetOfExactType<AppServices>();
    assert(services != null, 'AppServices missing above this widget');
    return services!;
  }

  @override
  bool updateShouldNotify(AppServices oldWidget) =>
      auth != oldWidget.auth ||
      data != oldWidget.data ||
      audio != oldWidget.audio ||
      ads != oldWidget.ads;
}

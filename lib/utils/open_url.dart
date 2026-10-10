import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the phone's browser, with a friendly snackbar if nothing
/// can handle it (e.g. no browser installed or the device is locked down).
Future<void> openUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger?.showSnackBar(
        const SnackBar(content: Text("Couldn't open that link. Try again in a browser?")),
      );
    }
  } catch (_) {
    messenger?.showSnackBar(
      const SnackBar(content: Text("Couldn't open that link. Try again in a browser?")),
    );
  }
}

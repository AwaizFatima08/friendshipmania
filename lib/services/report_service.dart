import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// The Play Store listing URL, used in the invite text sent alongside a
/// shared report. Update this once the app is actually live — until then
/// the placeholder still shares fine, it just won't resolve to a store page.
const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.homilabs.friendshipmania';

/// The outcome of trying to save the report image somewhere the user can
/// find it again. [message] is written to be shown directly in a SnackBar.
class ReportSaveResult {
  final bool success;
  final String message;

  const ReportSaveResult({required this.success, required this.message});
}

/// Strips characters that don't belong in a share-sheet text payload
/// (newlines, control characters) and caps length, so a pasted-in weird
/// name can't break the invite message or blow past platform share limits.
String sanitizeForShareText(String input) {
  final cleaned = input
      .replaceAll(RegExp(r'[\r\n\t]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return cleaned.length > 60 ? cleaned.substring(0, 60) : cleaned;
}

/// Renders whatever is attached to [boundaryKey] (a RepaintBoundary) into
/// PNG bytes. [pixelRatio] above 1 keeps the exported image crisp on
/// high-density phone screens instead of looking blurry when shared.
Future<Uint8List> captureBoundaryAsPng(
  GlobalKey boundaryKey, {
  double pixelRatio = 3,
}) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('Nothing to capture yet — the report card has no render object.');
  }

  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Could not encode the report card as an image.');
  }
  return byteData.buffer.asUint8List();
}

/// Writes [bytes] to a fresh temp file so it can be handed to the share
/// sheet as an actual file (some apps, like WhatsApp, ignore share intents
/// that only carry raw bytes without a file path).
Future<File> _writeTempPng(Uint8List bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName.png');
  return file.writeAsBytes(bytes, flush: true);
}

/// Saves the report PNG into the device's own Gallery/Photos app under a
/// "friendshipmania" album — this is what the "Download" button does. Asks
/// for photo-library access first if it hasn't been granted yet.
Future<ReportSaveResult> saveReportToGallery(Uint8List bytes) async {
  try {
    var hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      hasAccess = await Gal.requestAccess();
    }
    if (!hasAccess) {
      return const ReportSaveResult(
        success: false,
        message: "Couldn't save — photo/gallery permission was denied.",
      );
    }

    await Gal.putImageBytes(
      bytes,
      album: 'friendshipmania',
      name: 'friendshipmania_report_${DateTime.now().millisecondsSinceEpoch}',
    );
    return const ReportSaveResult(
      success: true,
      message: 'Saved to your gallery in the "friendshipmania" album.',
    );
  } on GalException catch (e) {
    return ReportSaveResult(success: false, message: 'Save failed: ${e.type.message}');
  } catch (_) {
    return const ReportSaveResult(
      success: false,
      message: "Couldn't save the report — something went wrong.",
    );
  }
}

/// Opens the native share sheet with the report image attached plus an
/// invite message pointing the friend back at the app, so they can install
/// it and generate their own reciprocal report about the same friendship.
Future<void> shareReport({
  required Uint8List bytes,
  required String yourName,
  required String friendName,
  required int percent,
  required String verdictTitle,
}) async {
  final you = sanitizeForShareText(yourName);
  final friend = sanitizeForShareText(friendName);
  final title = sanitizeForShareText(verdictTitle);

  final text =
      '🕵️ $you just put the friendship with $friend through the '
      'friendshipmania polygraph and scored $percent% — "$title"!\n\n'
      "Think $friend would score it differently? Get friendshipmania and "
      'drop your own verdict on this friendship 👉 $playStoreUrl';

  final file = await _writeTempPng(bytes, 'friendshipmania_report');

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: text,
      subject: 'Our friendshipmania report',
    ),
  );
}

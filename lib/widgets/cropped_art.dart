import 'package:flutter/material.dart';

/// The visible-artwork rectangle inside a 1024x1024 cutout, as fractions.
class ArtCrop {
  final double left;
  final double top;
  final double width;
  final double height;

  const ArtCrop(this.left, this.top, this.width, this.height);

  static const full = ArtCrop(0, 0, 1, 1);
}

/// Measured with `convert <file> -trim -format '%w x %h at %O'` and padded
/// ~1% each side. The homidev cutouts keep wide transparent margins (and the
/// art isn't always centred), so showing the whole canvas made them tiny.
/// When swapping in new art, re-measure and add it here.
const Map<String, ArtCrop> artCrops = {
  // Mascot (detective bean)
  'assets/images/20261010-1125-friendshipmania-icon-01_cutout.png':
      ArtCrop(0.240, 0.206, 0.520, 0.628),
  // Verdict stickers
  'assets/images/20261010-1125-friendshipmania-icon-02_cutout.png':
      ArtCrop(0.241, 0.227, 0.525, 0.561),
  'assets/images/20261010-1125-friendshipmania-icon-03_cutout.png':
      ArtCrop(0.233, 0.243, 0.531, 0.506),
  'assets/images/20261010-1126-friendshipmania-icon-01_cutout.png':
      ArtCrop(0.300, 0.268, 0.395, 0.534),
  'assets/images/20261010-1127-friendshipmania-icon-01_cutout.png':
      ArtCrop(0.067, 0.288, 0.892, 0.477),
  'assets/images/20261010-1127-friendshipmania-icon-02_cutout.png':
      ArtCrop(0.175, 0.116, 0.652, 0.330),
};

/// Shows only the artwork part of an approved cutout, scaled to [height].
/// The source file is used as-is (no re-cropped copies to keep in sync).
class CroppedArt extends StatelessWidget {
  const CroppedArt({
    super.key,
    required this.asset,
    required this.height,
    this.semanticLabel,
    this.fallback,
  });

  final String asset;
  final double height;
  final String? semanticLabel;

  /// Shown if the image can't be decoded.
  final Widget? fallback;

  /// Alignment that places the crop's top-left at the parent's top-left
  /// when `Align` shows only `factor` of the child.
  static double _align(double start, double factor) =>
      factor >= 1 ? 0 : 2 * start / (1 - factor) - 1;

  @override
  Widget build(BuildContext context) {
    final crop = artCrops[asset] ?? ArtCrop.full;
    return SizedBox(
      height: height,
      width: height * crop.width / crop.height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: ClipRect(
          child: Align(
            alignment: Alignment(
              _align(crop.left, crop.width),
              _align(crop.top, crop.height),
            ),
            widthFactor: crop.width,
            heightFactor: crop.height,
            child: Image.asset(
              asset,
              width: 1024,
              height: 1024,
              // Decode smaller to save memory, but stretch back to the full
              // 1024 box: without `fit`, a 640 px decode would be drawn at its
              // natural size in the middle and everything would shrink.
              cacheWidth: 640,
              fit: BoxFit.fill,
              semanticLabel: semanticLabel,
              errorBuilder: (_, _, _) =>
                  fallback ?? const SizedBox(width: 1024, height: 1024),
            ),
          ),
        ),
      ),
    );
  }
}

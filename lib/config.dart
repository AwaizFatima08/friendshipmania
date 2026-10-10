/// Where the app's public documents live. These pages are hosted on the
/// HomiLabs Hostinger site (see `site/friendshipmania/`), and the same URLs
/// are entered in the Play Console listing.
const String siteBase = 'https://friendshipmania.homilabs.org';
const String privacyUrl = '$siteBase/privacy.html';
const String termsUrl = '$siteBase/terms.html';
const String deleteAccountUrl = '$siteBase/delete-account.html';

/// Public support address — the same one already shown on homilabs.org.
const String supportEmail = 'homilabs.smc@gmail.com';

/// Credits shown on the About screen. Must include every line in
/// assets/ATTRIBUTION.md (release-check.sh fails the build otherwise).
const List<String> attributionLines = [
  'Sound effects: Powered by Stability AI',
  'Mascot and sticker art made with AI tools and reviewed by HomiLabs',
];

/// The detective-bean mascot (approved homidev asset, see ASSET-REGISTER.md).
const String mascotAsset =
    'assets/images/20261010-1125-friendshipmania-icon-01_cutout.png';

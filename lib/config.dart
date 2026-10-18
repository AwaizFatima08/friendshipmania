/// Where the app's public documents live. These pages are hosted on the
/// HomiLabs Hostinger site (see `site/friendshipmania/`), and the same URLs
/// are entered in the Play Console listing.
const String siteBase = 'https://friendshipmania.homilabs.org';
const String privacyUrl = '$siteBase/privacy.html';
const String termsUrl = '$siteBase/terms.html';
const String deleteAccountUrl = '$siteBase/delete-account.html';

/// AdMob banner units for release builds (AdMob → Apps → friendshipmania →
/// Ad units). Not secrets — they ship inside every APK. Leave empty and the
/// release build simply shows no ads; debug builds always use Google's test
/// unit. The AdMob *app* ID lives in android/app/build.gradle.kts.
/// tool/check_release_ad_ids.sh refuses a release while these are unset.
const String admobBannerResultUnitId = 'ca-app-pub-2087846699268567/7073121834';
const String admobBannerHistoryUnitId = 'ca-app-pub-2087846699268567/7974220099';

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

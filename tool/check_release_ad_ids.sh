#!/bin/bash
# Run before every release build: refuses AdMob IDs that are unset or are
# Google's sample IDs (sample ads earn nothing and look broken to reviewers).
#   tool/check_release_ad_ids.sh
set -u
cd "$(dirname "$0")/.."
fail=0
check() { # name value
  if [[ -z "$2" ]]; then echo "FAIL  $1 is empty"; fail=1
  elif [[ "$2" == *3940256099942544* ]]; then echo "FAIL  $1 is Google's sample ID"; fail=1
  elif [[ "$2" != ca-app-pub-* ]]; then echo "FAIL  $1 doesn't look like an AdMob ID: $2"; fail=1
  else echo "PASS  $1 = $2"; fi
}
dart_id() { sed -nE "s/^const String $1 = '([^']*)';/\1/p" lib/config.dart; }
app_id=$(sed -nE 's/^val admobReleaseAppId = "([^"]*)"/\1/p' android/app/build.gradle.kts)
check admobReleaseAppId "$app_id"
check admobBannerResultUnitId "$(dart_id admobBannerResultUnitId)"
check admobBannerHistoryUnitId "$(dart_id admobBannerHistoryUnitId)"
if [[ -n "$app_id" ]]; then
  pub="${app_id%%~*}"; pub="${pub#ca-app-}"   # ca-app-pub-123~456 -> pub-123
  grep -q "$pub" site/friendshipmania/app-ads.txt 2>/dev/null ||
    echo "WARN  site/friendshipmania/app-ads.txt doesn't list $pub yet"
fi
[[ $fail == 0 ]] && echo "RESULT: PASS" || { echo "RESULT: FAIL - fix the IDs above before a release build"; exit 1; }

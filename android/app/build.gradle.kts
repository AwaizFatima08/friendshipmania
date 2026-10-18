import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// AdMob app ID for release builds (AdMob → Apps → friendshipmania → App settings).
// Not a secret: it ships in every APK. Debug/profile builds use Google's sample
// app ID so test ads never touch the real account.
val admobReleaseAppId = ""
val admobSampleAppId = "ca-app-pub-3940256099942544~3347511713"

android {
    namespace = "com.homilabs.friendshipmania"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.homilabs.friendshipmania"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code/name from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["admobAppId"] = admobSampleAppId
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Falls back to debug signing until key.properties exists (created by
            // scripts/generate_release_keystore.sh), so `flutter run --release`
            // keeps working before that step is done.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            manifestPlaceholders["admobAppId"] =
                admobReleaseAppId.ifEmpty { admobSampleAppId }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

// A release without the real AdMob app ID would ship Google's sample ID.
// Fail loudly instead (the Dart unit IDs are checked by tool/check_release_ad_ids.sh).
tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    doFirst {
        check(admobReleaseAppId.startsWith("ca-app-pub-") && !admobReleaseAppId.contains("3940256099942544")) {
            "Set admobReleaseAppId in android/app/build.gradle.kts before building a release."
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}

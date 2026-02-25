plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services – required by Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.user_app"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.user_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
<<<<<<< HEAD
        minSdk = flutter.minSdkVersion // Firebase requires minimum SDK 23
=======
        minSdk = flutter.minSdkVersion // firebase_core requires >= 23
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Firebase BoM – ensures all Firebase libraries use compatible versions.
    // Flutter pub packages (firebase_core, cloud_firestore, etc.) pull in
    // their own Android dependencies, but the BoM keeps everything in sync.
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
}

flutter {
    source = "../.."
}

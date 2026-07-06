plugins {
    id("com.android.application")
    id("kotlin-android")
    // 1. Flutter plugin MUST come third
    id("dev.flutter.flutter-gradle-plugin")
    // 2. Google services must come AFTER the flutter gradle plugin loader line
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.jascare"
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
        // 🔄 CHANGED FROM: "com.example.jascare"
        applicationId = "com.uitm.jascare" 
        
        minSdk = flutter.minSdkVersion
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

flutter {
    source = "../.."
}

project.layout.buildDirectory.set(file("${project.projectDir}/../../build/app"))

plugins {
   id("com.android.application")
   id("kotlin-android")
   id("dev.flutter.flutter-gradle-plugin")
   id("com.google.gms.google-services")
}

android {
    namespace = "com.example.royal_tint"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.royal_tint"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("debug") {
            // This ensures the APK is built in the standard way
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
        
        release {
            isMinifyEnabled = true
            isShrinkResources = true
        
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation(platform("com.google.firebase:firebase-bom:32.3.0"))
    implementation("com.google.firebase:firebase-analytics")
}
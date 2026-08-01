import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing. CI passes the credentials as environment variables (never
// through a properties file: the shell would expand a `$` in a password and
// java.util.Properties would eat a backslash). Locally they come from the
// gitignored android/key.properties. With neither, release builds fall back to
// the debug key so `flutter run --release` keeps working.
val keystoreProperties = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { load(it) }
    }
}

fun signingValue(environmentVariable: String, property: String): String? =
    (System.getenv(environmentVariable) ?: keystoreProperties.getProperty(property))
        // A secret set with `echo` carries a trailing newline that would
        // otherwise be read as part of the password.
        ?.trim()
        ?.takeIf { it.isNotEmpty() }

val keystorePath = signingValue("JUNO_KEYSTORE_PATH", "storeFile")
val hasReleaseKeystore = keystorePath != null

android {
    namespace = "io.juno.juno"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.juno.juno"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk 23: floor required by flutter_secure_storage's cipher/biometric APIs.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystorePath!!)
                storePassword = signingValue("JUNO_KEYSTORE_PASSWORD", "storePassword")
                keyAlias = signingValue("JUNO_KEY_ALIAS", "keyAlias")
                keyPassword = signingValue("JUNO_KEY_PASSWORD", "keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Every published APK must carry the same signature or Android
            // refuses to install it over the previous one.
            signingConfig = signingConfigs.getByName(
                if (hasReleaseKeystore) "release" else "debug"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

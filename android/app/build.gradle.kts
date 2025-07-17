import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadEnvFile(flavorName: String): Properties {
    val envFile = file("../../.env.$flavorName").takeIf { it.exists() } ?: file("../../.env")
    val props = Properties()
    if (envFile.exists()) {
        envFile.inputStream().use { props.load(it) }
    }
    return props
}

android {
    namespace = "com.example.base_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

      buildFeatures {
        buildConfig = true 
    }

    defaultConfig {
        applicationId = "com.example.base_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            val props = loadEnvFile("dev")

            val appName = props.getProperty("APP_NAME", "Paw Dev")
            val baseUrl = props.getProperty("BASE_URL", "/")
            val enableLogging = props.getProperty("ENABLE_LOGGING", "true")

            resValue("string", "app_name", appName)
            buildConfigField("String", "API_BASE_URL", "\"$baseUrl\"")
            buildConfigField("boolean", "ENABLE_LOGGING", enableLogging)
        }

        create("staging") {
            dimension = "environment"
            val props = loadEnvFile("staging")

            val appName = props.getProperty("APP_NAME", "Paw Staging")
            val baseUrl = props.getProperty("BASE_URL", "")
            val enableLogging = props.getProperty("ENABLE_LOGGING", "true")

            resValue("string", "app_name", appName)
            buildConfigField("String", "API_BASE_URL", "\"$baseUrl\"")
            buildConfigField("boolean", "ENABLE_LOGGING", enableLogging)
        }

        create("prod") {
            dimension = "environment"
            val props = loadEnvFile("prod")

            val appName = props.getProperty("APP_NAME", "Base App")
            val baseUrl = props.getProperty("BASE_URL", "")
            val enableLogging = props.getProperty("ENABLE_LOGGING", "false")

            resValue("string", "app_name", appName)
            buildConfigField("String", "API_BASE_URL", "\"$baseUrl\"")
            buildConfigField("boolean", "ENABLE_LOGGING", enableLogging)
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

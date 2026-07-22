import java.util.Properties
import org.gradle.api.tasks.Exec

// Contournement Windows : "Unable to determine engine version..."
// Force la version moteur lue depuis le SDK (évite l'échec de update_engine_version.ps1).
val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val flutterSdk = localProps.getProperty("flutter.sdk")?.replace("\\\\", "\\")
val engineVersion = flutterSdk?.let { sdk ->
    rootProject.file("$sdk/bin/internal/engine.version").takeIf { it.exists() }?.readText()?.trim()
} ?: "d3d45dcf251823c1769909cd43698d126db38deb"

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    tasks.withType<Exec>().configureEach {
        environment("FLUTTER_PREBUILT_ENGINE_VERSION", engineVersion)
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

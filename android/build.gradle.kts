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

// Contournement AGP : certains plugins Flutter plus anciens (ex. isar_flutter_libs
// 3.1.0+1) ne déclarent pas encore la propriété `namespace` exigée par les
// versions récentes d'Android Gradle Plugin — ils ne fournissaient que
// l'attribut `package` dans leur AndroidManifest.xml (ancienne convention).
// On lit cet attribut et on l'utilise comme namespace si absent, plutôt que
// de modifier le package tiers (qui serait écrasé au prochain `pub get`).
// DOIT être enregistré avant `evaluationDependsOn` ci-dessous : cette
// directive force l'évaluation anticipée de certains sous-projets, et un
// `afterEvaluate` déclaré après coup arrive alors trop tard (le projet est
// déjà évalué).
subprojects {
    afterEvaluate {
        val androidExtension = extensions.findByName("android")
        if (androidExtension is com.android.build.gradle.BaseExtension && androidExtension.namespace == null) {
            val manifestFile = androidExtension.sourceSets.getByName("main").manifest.srcFile
            if (manifestFile.exists()) {
                val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestFile.readText())
                if (packageMatch != null) {
                    androidExtension.namespace = packageMatch.groupValues[1]
                }
            }
        }
    }
}

// Contournement AGP/AAPT2 : isar_flutter_libs 3.1.0+1 déclare en dur
// `compileSdkVersion 30` dans son propre build.gradle, indépendamment du
// compileSdk de l'app — mais des dépendances transitives (androidx.core
// récent) référencent l'attribut `android:attr/lStar` (introduit en API 31),
// absent du android.jar de l'API 30. Le linking des ressources de ce module
// échoue alors même si le compileSdk de l'app elle-même est correct.
// Même raison que le bloc namespace ci-dessus pour l'ordre d'enregistrement.
subprojects {
    afterEvaluate {
        val androidExtension = extensions.findByName("android")
        if (androidExtension is com.android.build.gradle.BaseExtension) {
            val current = androidExtension.compileSdkVersion
                ?.removePrefix("android-")?.toIntOrNull()
            if (current != null && current < 31) {
                androidExtension.compileSdkVersion(35)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

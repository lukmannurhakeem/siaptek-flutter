import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Change root build output directory
val newBuildDir: Directory = layout.buildDirectory.dir("../../build").get()
layout.buildDirectory.set(newBuildDir)

subprojects {
    layout.buildDirectory.set(newBuildDir.dir(name))
    evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}

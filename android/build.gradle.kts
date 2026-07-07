// ✅ 1. The plugins block MUST sit at the absolute top of the file
plugins {
    id("com.google.gms.google-services") version "4.4.1" apply false
}

// ✅ 2. Shared repositories array definition
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ 3. Single declaration mapping for custom build output directories
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
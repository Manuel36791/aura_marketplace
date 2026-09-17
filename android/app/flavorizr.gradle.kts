import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.aura.store.dev"
            resValue(type = "string", name = "app_name", value = "(DEV) Aura")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.aura.store.stg"
            resValue(type = "string", name = "app_name", value = "(STG) Aura")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.aura.store"
            resValue(type = "string", name = "app_name", value = "Aura")
        }
    }

    buildFeatures.resValues = true
}
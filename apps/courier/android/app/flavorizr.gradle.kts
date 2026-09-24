import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.aura.courier.dev"
            resValue(type = "string", name = "app_name", value = "(DEV) Aura Courier")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.aura.courier.stg"
            resValue(type = "string", name = "app_name", value = "(STG) Aura Courier")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.aura.courier"
            resValue(type = "string", name = "app_name", value = "Aura Courier")
        }
    }

    buildFeatures.resValues = true
}
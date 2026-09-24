import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.aura.partner.dev"
            resValue(type = "string", name = "app_name", value = "(DEV) Aura Partner")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.aura.partner.stg"
            resValue(type = "string", name = "app_name", value = "(STG) Aura Partner")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.aura.partner"
            resValue(type = "string", name = "app_name", value = "Aura Partner")
        }
    }

    buildFeatures.resValues = true
}
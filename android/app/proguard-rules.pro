# =========================================================================
# REGLAS DE PROTECCIÓN Y MINIFICACIÓN NATIVA - TRUEKE v4
# =========================================================================

# Preservar anotaciones esenciales del sistema y configuraciones reflectivas
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Exclusiones de ofuscación para evitar roturas en los plugins de Flutter nativos
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mantener los modelos de serialización de datos de Supabase y Firebase a salvo
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Suprimir advertencias menores de librerías de terceros que detienen R8
-dontwarn javax.annotation.**
-dontwarn charset.det.**

# =========================================================================
# EXCLUSIÓN DE CLASES HUÉRFANAS DE GOOGLE PLAY CORE - TRUEKE v4
# =========================================================================

# Indicar al optimizador R8 que omita y tolere las clases diferidas ausentes de Google Play
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

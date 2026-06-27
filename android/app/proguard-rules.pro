# Flutter optimization
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Razorpay
-keep class com.razorpay.** {*;}
-keepattributes *Annotation*
-dontwarn com.razorpay.**

# Supabase / Dart-related
-keep class com.supabase.** { *; }

# Google Play Core (Fixes R8 missing class errors)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**



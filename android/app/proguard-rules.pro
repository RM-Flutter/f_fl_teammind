## Keep BouncyCastle classes
#-keep class org.bouncycastle.jsse.** { *; }
#-keep class org.conscrypt.** { *; }
#-keep class org.openjsse.** { *; }
# Keep BouncyCastle classes
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Keep Conscrypt classes
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# Keep OpenJSSE classes
-keep class org.openjsse.** { *; }
-dontwarn org.openjsse.**

# Keep OkHttp internal classes
-keep class okhttp3.internal.** { *; }
-dontwarn okhttp3.internal.**

# Keep TensorFlow Lite (and GPU delegate) classes
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class com.google.android.filament.** { *; }

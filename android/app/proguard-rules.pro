# Flutter / Dio — release (R8)
-keep class io.flutter.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Flutter référence les classes Play Core (deferred components) même quand
# l'app n'utilise pas cette fonctionnalité ni la dépendance play-core —
# sans cette règle, R8 échoue en "Missing class" au lieu d'un simple warning.
-dontwarn com.google.android.play.core.**

# Le plugin smart_auth (SMS autofill) référence l'ancienne API SmartLock
# for Passwords (com.google.android.gms.auth.api.credentials.*), retirée
# des versions récentes de play-services-auth mais toujours appelée en
# fallback dans le plugin — même traitement que Play Core ci-dessus.
-dontwarn com.google.android.gms.auth.api.credentials.**

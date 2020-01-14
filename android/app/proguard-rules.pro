-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontskipnonpubliclibraryclassmembers
-dontpreverify
-verbose
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

-dontnote com.google.vending.licensing.ILicensingService
-dontnote com.android.vending.licensing.ILicensingService

## Native wrapper
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep class android.support.** { *; }
-keep public class * extends android.support.**
-keep public class * extends android.app.Fragment
-keep class com.google.android.material.** {*;}
-keep class androidx.** {*;}
-keep interface androidx.** {*;}
-keep public class * extends androidx.**
-dontwarn com.google.android.material.**
-dontnote com.google.android.material.**
-dontwarn androidx.**

## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

## Packages wrapper
-keep class com.dexterous.** { *; }
-keep class com.pichillilorenzo.** { *; }
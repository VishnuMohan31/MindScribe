## Android App Publishing Guide (Google Play Console)

This document explains, in simple and detailed steps, how to publish and update an Android app to Google Play using **Google Play App Signing** and **Flutter** (or any Android app bundle).

---

## 1. Prerequisites

Before you start:

1. **Google Play Developer account**
   - You must have an active Google Play Developer account.

2. **App created in Play Console**
   - App ID / package name (e.g. `com.mindscribe.diary`) is already registered.
   - Basic store listing, content rating, privacy policy, and app details are completed.

3. **Release build environment**
   - Flutter SDK (or Android Studio) installed.
   - Android SDK and platform tools installed.
   - A computer where you can build signed release bundles (AAB files).

4. **Upload keystore**
   - A secure keystore file (e.g. `upload-keystore.jks`) with:
     - `storePassword`
     - `keyPassword`
     - `keyAlias`
   - These values are stored in `android/key.properties`:
     ```properties
     storePassword=YOUR_STORE_PASSWORD
     keyPassword=YOUR_KEY_PASSWORD
     keyAlias=upload
     storeFile=../app/upload-keystore.jks
     ```
   - Keep this file and these passwords safe; they are required for all future updates.

---

## 2. Configure App Signing by Google Play

Google Play App Signing is the **recommended best practice**. Google manages the **app signing key**, and you use your keystore as the **upload key**.

1. Open **Google Play Console** and select your app.
2. In the left sidebar, go to:
   - **Test and release → App integrity** (or **Setup → App integrity**, depending on UI).
3. Under **Services → App signing**, ensure it shows:
   - **“Signing by Google Play”** (or similar wording).
4. If you see an option like **“Let Google manage and protect your app signing key (recommended)”**:
   - Select it and **Save**.
5. If prompted to choose a key:
   - Keep **“Let Google manage and protect your app signing key”** selected.
   - Register your **upload keystore** (e.g. `upload-keystore.jks`).

Once this is set:

- Google keeps the **app signing key** safe.
- Your local keystore is only used as the **upload key** to sign bundles you upload.

---

## 3. Build a Signed Release App Bundle (AAB)

Google Play now requires an **Android App Bundle (.aab)** for new apps and most updates.

### 3.1 Ensure `key.properties` is configured

In `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

In `android/app/build.gradle`, check:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    defaultConfig {
        applicationId = "com.mindscribe.diary"
        minSdkVersion = flutter.minSdkVersion
        targetSdk = 35
        versionCode = 8      // increase for every release
        versionName = "2.2.5"
    }

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists() && keystoreProperties['storeFile'] != null) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            // Use release signing if configured; Google Play will re-sign with app signing key
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3.2 Update version

Every time you publish an update:

- **Increase `versionCode`** (integer) in `android/app/build.gradle`.
- Optionally adjust **`versionName`** (string shown to users).
- In `pubspec.yaml`, keep `version:` consistent (e.g. `2.2.5+8`).

### 3.3 Build the bundle

In a terminal at the project root:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

The output bundle will be at:

```text
build/app/outputs/bundle/release/app-release.aab
```

This is the file you upload to Google Play.

---

## 4. Upload to Closed Testing (Alpha / Beta)

Closed testing lets a small group (e.g. 10–100 testers) use the app before production.

1. Open **Google Play Console** → select your app.
2. Left sidebar: **Test and release → Testing → Closed testing**.
3. Click your closed testing track (e.g. **alpha**), then **Create new release**.
4. In the **App integrity** section:
   - Ensure it says **“Releases signed by Google Play”**.
5. Under **App bundles**:
   - Click **Upload**.
   - Select `app-release.aab` from `build/app/outputs/bundle/release/`.
6. Wait for processing to complete (a few minutes).
7. Add **Release notes** (short summary of changes).
8. Click **Next / Review release**.
9. Start the rollout to testers (closed track).

Google may run an automated review; status may show **In review** before becoming **Active**.

---

## 5. Invite Testers

1. In your closed testing track page, look for **“How testers join your test”**.
2. Copy the **Opt‑in URL**.
3. Share this URL with your testers (email, chat, etc.).
4. Testers must:
   - Open the link,
   - Tap **“Become a tester”**,
   - Then go to **Google Play Store → MindScribe → Install/Update**.

Ask testers to:

- Install or update the app.
- Use all key features (onboarding, home, calendar, notifications, reminders, voice input, etc.).
- Report any crashes or issues.

---

## 6. Promote to Production (Go Live)

After successful testing:

1. In Play Console, go to **Test and release → Production**.
2. Click **Create new release**.
3. Upload the **same AAB** that passed testing (or a newer one with a higher `versionCode`).
4. Add **production release notes** (user-friendly).
5. Choose rollout strategy:
   - **Full rollout**: 100% of users immediately.
   - **Staged rollout** (recommended):
     - Start at e.g. 20%.
     - Monitor for crashes/ANRs.
     - Increase to 50%, then 100%.
6. Click **Review release → Start rollout to production**.

Google will review the release; once approved, it becomes available on the Play Store.

---

## 7. Future Updates

For each new version:

1. Update app code and assets.
2. Increase **`versionCode`** and adjust **`versionName`**.
3. Build new AAB:
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```
4. Upload to **Closed testing** first (best practice).
5. Test with your testers.
6. Promote to **Production** once stable.

Because **Google Play App Signing** is enabled and you consistently use the same **upload keystore**, users will be able to update smoothly without reinstalling.

---

## 8. Key Management Best Practices

1. **Backup your upload keystore**
   - Store `upload-keystore.jks` in at least two secure locations (e.g. encrypted drive + secure cloud).

2. **Protect passwords**
   - Keep `storePassword` and `keyPassword` in a password manager.
   - Never commit them to Git or share them in code repositories.

3. **Never delete or change keystore accidentally**
   - Changing the upload key without Google’s approval can break future updates.
   - If you ever lose the upload key, use **“Request upload key reset”** in App Integrity (only when App Signing is enabled).

4. **Document everything**
   - Record:
     - Keystore file path.
     - Alias.
     - Passwords (in password manager).
     - Any changes with dates.

By following these steps and practices, you have a **clean, repeatable process** for building, testing, and publishing Android releases to Google Play using the safest and most modern setup.


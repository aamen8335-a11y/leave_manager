# Build APK from Mobile (Codemagic)

1. Create a GitHub repo and upload this folder's contents.
2. Go to https://codemagic.io and sign in with GitHub. Grant access to the repo.
3. Create a new Workflow (Flutter):
   - Flutter version: stable
   - Build for Android: APK
4. In Firebase Console:
   - Create a project, add Android app with package name `com.company.leave` (or whatever you prefer).
   - Download `google-services.json`.
5. In Codemagic:
   - Go to **Environment > Secure files** and upload `google-services.json`.
   - Set **Install location**: `android/app/google-services.json`.
6. Start build. After it finishes, download the APK to your phone.

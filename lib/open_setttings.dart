import 'dart:io';

void openPrivacySettings() async {
  if (Platform.isMacOS) {
    await Process.run('open', [
      'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles',
    ]);
  }
}

void showPermissionInstructions() {
  print('''
🔒 macOS Security Permissions Required

To allow Flutter Bunny CLI to function correctly, please do the following:

1. 🧑‍💻 Go to **System Settings → Privacy & Security → Full Disk Access**
2. 🔍 Scroll down and **enable Full Disk Access** for your Terminal app (e.g. Terminal, iTerm, Warp).
3. 🛠 Also go to **Developer Tools** (in the same Privacy tab)
4. ✅ Allow your terminal to control other apps.

📦 Then close and reopen your terminal window, and try again.

Opening settings for you now...
''');
}

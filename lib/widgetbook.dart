// main.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Flutter Bunny GUI',
      home: BunnyHomePage(),
    ),
  );
}

class BunnyHomePage extends StatefulWidget {
  const BunnyHomePage({Key? key}) : super(key: key);

  @override
  State<BunnyHomePage> createState() => _BunnyHomePageState();
}

class _BunnyHomePageState extends State<BunnyHomePage> {
  String output = '';
  bool isLoading = false;
  bool showFixInstructions = false;

  // Tracks if we've checked permissions on startup
  bool hasCheckedPermissions = false;

  @override
  void initState() {
    super.initState();
    // Check permissions when app starts
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (hasCheckedPermissions) return;
    
    hasCheckedPermissions = true;
    
    if (!Platform.isMacOS) return;
    
    setState(() {
      isLoading = true;
      output = 'Checking Dart executable permissions...';
    });
    
    try {
      // Try to run a simple dart command
      final result = await Process.run(
        'dart',
        ['--version'],
        runInShell: true,
      );
      
      if (result.stderr.toString().contains('Operation not permitted')) {
        await _showPermissionInstructions();
      } else {
        setState(() {
          output = 'Permissions check passed ✓\n\n${result.stdout}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        output = 'Error checking permissions: $e';
        showFixInstructions = true;
        isLoading = false;
      });
    }
  }

  void _runBunnyCommand() async {
    setState(() {
      isLoading = true;
      output = 'Running Bunny command...\n';
      showFixInstructions = false;
    });

    try {
      final result = await Process.run(
        'dart',
        [
          'run',
          'bin/flutter_bunny.dart',
          'generate',
          'screen',
          '--name',
          'HomeScreen',
        ],
        runInShell: true,
      );

      String stdOut = result.stdout.toString();
      String stdErr = result.stderr.toString();

      // Check for permission errors
      if (stdErr.contains('Operation not permitted')) {
        await _showPermissionInstructions();
      } else if (stdErr.contains('command not found') || stdErr.contains('No such file')) {
        _showInstallationInstructions();
      } else {
        setState(() {
          output += stdOut;
          if (stdErr.isNotEmpty) {
            output += '\nErrors:\n$stdErr';
          }
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        output += '\nError: $e';
        isLoading = false;
        showFixInstructions = true;
      });
    }
  }

  Future<void> _fixPermissions() async {
    setState(() {
      isLoading = true;
      output = 'Attempting to fix permissions...\n';
    });

    try {
      // Create a temporary shell script to fix permissions
      final tempDir = await getTemporaryDirectory();
      final scriptFile = File('${tempDir.path}/fix_permissions.sh');
      
      await scriptFile.writeAsString('''
#!/bin/bash
# Fix permissions for Dart and Flutter
xattr -d com.apple.quarantine /opt/homebrew/bin/dart 2>/dev/null || true
chmod +x /opt/homebrew/bin/dart
xattr -d com.apple.quarantine /opt/homebrew/bin/flutter 2>/dev/null || true
chmod +x /opt/homebrew/bin/flutter
echo "Permissions updated. Please restart your terminal and this application."
''');
      
      await Process.run('chmod', ['+x', scriptFile.path]);
      
      // Run the script with admin privileges
      final process = await Process.start(
        'osascript',
        ['-e', 'do shell script "sh ${scriptFile.path}" with administrator privileges'],
        mode: ProcessStartMode.inheritStdio,
      );
      
      final exitCode = await process.exitCode;
      
      if (exitCode == 0) {
        setState(() {
          output += '\nPermissions fixed successfully! Please restart the application.';
          isLoading = false;
        });
      } else {
        setState(() {
          output += '\nFailed to fix permissions. Please try manual steps.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        output += '\nError fixing permissions: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _openPrivacySettings() async {
    if (Platform.isMacOS) {
      await Process.run('open', [
        'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles',
      ]);
    }
  }

  Future<void> _showPermissionInstructions() async {
    setState(() {
      output = ''' 
🔒 macOS Security Permissions Required

Please follow these steps to allow the Bunny CLI to work:

1. 🧑‍💻 Go to **System Settings → Privacy & Security → Full Disk Access**
2. ✅ Enable access for your terminal app (e.g. Terminal, iTerm, Warp)
3. 🛠 Also check the **Developer Tools** section
4. ✅ Grant control to your terminal app

⚠️ If still having issues, you may need to remove quarantine attributes:
   - Open Terminal and run:
   - sudo xattr -d com.apple.quarantine /opt/homebrew/bin/dart
   - chmod +x /opt/homebrew/bin/dart

🚀 After updating settings, restart your terminal and try again.

📂 Opening settings now...''';
      showFixInstructions = true;
      isLoading = false;
    });
    
    await _openPrivacySettings();
  }

  void _showInstallationInstructions() {
    setState(() {
      output = '''
🔍 Flutter Bunny CLI Not Found

Please follow these steps to install Flutter Bunny:

1. 📦 Install Flutter Bunny CLI:
   ```
   dart pub global activate flutter_bunny
   ```

2. 🔄 Update your PATH to include Dart's global bin directory:
   ```
   echo 'export PATH="\$PATH:\$HOME/.pub-cache/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. ✅ Verify installation:
   ```
   flutter_bunny --version
   ```

📚 For more information, visit the Flutter Bunny documentation.
''';
      isLoading = false;
    });
  }

  Future<void> _checkDartInstallation() async {
    setState(() {
      isLoading = true;
      output = 'Checking Dart installation...\n';
    });

    try {
      final whichDart = await Process.run('which', ['dart'], runInShell: true);
      final dartVersion = await Process.run('dart', ['--version'], runInShell: true);
      
      setState(() {
        output += 'Dart path: ${whichDart.stdout}\n';
        output += 'Dart version: ${dartVersion.stdout}\n';
        
        if (whichDart.stderr.isNotEmpty) {
          output += 'Error finding Dart: ${whichDart.stderr}\n';
        }
        
        if (dartVersion.stderr.isNotEmpty && !dartVersion.stderr.toString().contains('Dart SDK')) {
          output += 'Error checking Dart version: ${dartVersion.stderr}\n';
        }
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        output += 'Error checking Dart installation: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bunny GUI'),
        backgroundColor: Colors.amber[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPermissions,
            tooltip: 'Check Permissions',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button row
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _runBunnyCommand,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Generate Home Screen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _checkDartInstallation,
                  icon: const Icon(Icons.search),
                  label: const Text('Check Dart Installation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            
            // Show fix permissions button if needed
            if (showFixInstructions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _fixPermissions,
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Attempt Auto-Fix Permissions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _openPrivacySettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Open Privacy Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Progress indicator when loading
            if (isLoading) 
              const LinearProgressIndicator(),
              
            const SizedBox(height: 12),
            
            // Output header
            const Text(
              'Output:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            
            // Output text area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    output,
                    style: const TextStyle(
                      color: Colors.lightGreenAccent,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/backup/backup_service.dart';
import '../../../../core/utils/biometrics_helper.dart';
import '../../../../core/storage/hive_storage.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'DATA MANAGEMENT',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.white),
            title: const Text('Backup Data', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Export encrypted backup file', style: TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () => _showPasswordDialog(context, isExport: true),
          ),
          ListTile(
            leading: const Icon(Icons.upload, color: Colors.white),
            title: const Text('Restore Data', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Import from backup file', style: TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () => _showPasswordDialog(context, isExport: false),
          ),
          
          const Divider(color: Colors.white10),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'SECURITY',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              final isEnabled = HiveStorage.settingsBox.get('app_lock_enabled', defaultValue: false);
              return SwitchListTile(
                secondary: const Icon(Icons.fingerprint, color: Colors.white),
                title: const Text('App Lock', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Secure with biometrics/device lock', style: TextStyle(color: Colors.white54)),
                value: isEnabled,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) async {
                  if (value) {
                    // Enable: Check availability first
                    final available = await BiometricsHelper.isAvailable();
                    if (!available) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Biometrics not available on this device'), backgroundColor: Colors.red),
                        );
                      }
                      return;
                    }

                    // Authenticate
                    final success = await BiometricsHelper.authenticate();
                    if (success) {
                      await HiveStorage.settingsBox.put('app_lock_enabled', true);
                      setState(() {});
                    } else {
                       if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Authentication failed. Cannot enable App Lock.'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  } else {
                    // Disable: Authenticate first
                     final success = await BiometricsHelper.authenticate();
                     if (success) {
                       await HiveStorage.settingsBox.put('app_lock_enabled', false);
                       setState(() {});
                     }
                  }
                },
              );
            }
          ),

          const Divider(color: Colors.white10),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'ABOUT',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('Version', style: TextStyle(color: Colors.white)),
            subtitle: const Text('1.0.0', style: TextStyle(color: Colors.white54)),
          ),
          ListTile(
            leading: const Icon(Icons.code, color: Colors.orangeAccent),
            title: const Text(
              'Crafted by Nitin',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Made with ❤️ in India',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, {required bool isExport}) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(isExport ? 'Encrypt Backup' : 'Decrypt Backup', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              isExport 
                ? 'Enter a password to encrypt your backup file. You will need this password to restore it.' 
                : 'Enter the password used to encrypt this backup file.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(dialogContext);
                if (isExport) {
                  BackupService.exportData(context, passwordController.text);
                } else {
                  BackupService.importData(context, passwordController.text);
                }
              }
            },
            child: Text(isExport ? 'Export' : 'Restore'),
          ),
        ],
      ),
    );
  }
}

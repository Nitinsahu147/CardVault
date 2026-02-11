import 'package:flutter/material.dart';
import '../storage/hive_storage.dart';
import '../utils/biometrics_helper.dart';
import '../theme/app_theme.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isEnabled = false;

  DateTime? _lastPausedTime;
  final Duration _timeoutLimit = const Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkLockStatus() {
    _isEnabled = HiveStorage.settingsBox.get('app_lock_enabled', defaultValue: false);
    if (_isEnabled) {
      // Cold start: Always lock if enabled
      setState(() {
        _isLocked = true;
      });
      _authenticate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App went to background
      _isEnabled = HiveStorage.settingsBox.get('app_lock_enabled', defaultValue: false);
      if (_isEnabled) {
        // Record time, don't lock immediately
        _lastPausedTime = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground
      if (_isEnabled) {
        if (_isLocked) {
          // Already locked (e.g. from cold start or previous timeout), auth required
          _authenticate();
        } else if (_lastPausedTime != null) {
          // Check timeout
          final difference = DateTime.now().difference(_lastPausedTime!);
          if (difference > _timeoutLimit) {
            setState(() {
              _isLocked = true;
            });
            _authenticate();
          }
           // Reset timer
          _lastPausedTime = null;
        }
      }
    }
  }

  Future<void> _authenticate() async {
    final authenticated = await BiometricsHelper.authenticate();
    if (authenticated && mounted) {
      setState(() {
        _isLocked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLocked)
          Scaffold(
            backgroundColor: AppTheme.scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'App Locked',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Authenticate to continue',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: _authenticate,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Unlock'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

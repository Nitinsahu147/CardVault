import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/hive_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/biometrics_helper.dart';
import 'core/widgets/app_lock_wrapper.dart';
import 'features/cards/presentation/card_stack_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorage.init();
  
  runApp(const ProviderScope(child: CardVaultApp()));
}

class CardVaultApp extends StatelessWidget {
  const CardVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Default to dark theme for premium feel
      builder: (context, child) => AppLockWrapper(child: child!),
      home: const CardStackScreen(),
    );
  }
}

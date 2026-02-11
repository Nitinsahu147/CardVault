import 'package:local_auth/local_auth.dart';

class BiometricsHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return canCheck || isDeviceSupported;
  }

  static Future<bool> authenticate() async {
    try {
      if (!await isAvailable()) return false;
      
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access CardVault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Pattern as backup
        ),
      );
    } catch (e) {
      return false;
    }
  }
}

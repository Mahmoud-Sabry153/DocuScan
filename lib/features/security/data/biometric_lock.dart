import 'package:local_auth/local_auth.dart';
class BiometricLock {
  final LocalAuthentication _auth = LocalAuthentication();
  Future<bool> isAvailable() async => await _auth.isDeviceSupported() || await _auth.canCheckBiometrics;
  Future<bool> unlock() => _auth.authenticate(localizedReason: 'Unlock DocuScan', biometricOnly: false, persistAcrossBackgrounding: true);
}

import 'package:local_auth/local_auth.dart';

class FaceUtil {

 static Future localAuth() {
    final localAuth = LocalAuthentication();
     return localAuth.authenticate(
      localizedReason: 'Please authenticate',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }
}
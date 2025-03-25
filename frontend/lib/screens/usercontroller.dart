//usercontroller.dart
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';

final Logger logger = Logger();

class UserController {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
        kIsWeb
            ? '628073575006-tvd7n6j6tjc85ulalcpdcbjc0jqkba85.apps.googleusercontent.com'
            : null,
  );

  static Future<fb_auth.User?> loginWithGoogle() async {
    try {
      // Try silent sign-in first
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      googleUser ??= await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final fb_auth.OAuthCredential credential = fb_auth
          .GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb_auth.UserCredential userCredential = await fb_auth
          .FirebaseAuth
          .instance
          .signInWithCredential(credential);

      logger.i("Google Sign-In successful: ${userCredential.user?.email}");
      return userCredential.user;
    } catch (e) {
      logger.e('Google Sign-In Error', error: e);
      rethrow;
    }
  }
}

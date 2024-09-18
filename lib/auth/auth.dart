import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';

class Auth {
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-.';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  Future<UserCredential?> signInWithFacebook() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    final result = await FacebookAuth.instance.login(
      loginTracking: LoginTracking.limited,
      nonce: nonce,
    );

    switch (result.status) {
      case LoginStatus.success:
        return await _onFacebookAuthSucceded(result, rawNonce);
      case LoginStatus.cancelled:
        Lgr.errorLog("Facebook Auth cancelled");
      case LoginStatus.failed:
        Lgr.errorLog("Facebook Auth Failed");
      case LoginStatus.operationInProgress:
        Lgr.errorLog("Facebook Auth ongoing....");
    }
    return null;
  }

  Future<UserCredential> _onFacebookAuthSucceded(
      LoginResult result, String rawNonce) async {
    final token = result.accessToken as LimitedToken;
    OAuthCredential credential = OAuthCredential(
      providerId: 'facebook.com',
      signInMethod: 'oauth',
      idToken: token.tokenString,
      rawNonce: rawNonce,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {

    final appleProvider = AppleAuthProvider()
      ..addScope(AppleIDAuthorizationScopes.email.name);

    final UserCredential dupa = await FirebaseAuth.instance.signInWithProvider(appleProvider);
    return dupa;
  }

  Future<UserCredential>  signInWithAnonymously() {
    return FirebaseAuth.instance.signInAnonymously();
  }
}

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    // Continuously monitor for authStateChanges
    // per: https://firebase.google.com/docs/auth/flutter/start#authstatechanges
    _subscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          // if user != null there is a user logged in, however
          // we can just monitor for auth state change and notify

          notifyListeners();
        });
  } // End AuthNotifier constructor

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

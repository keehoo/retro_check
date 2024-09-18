import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/auth/auth.dart';
import 'package:untitled/ext/context_ext.dart';
import 'package:untitled/firebase/firestor_handler.dart';
import 'package:untitled/utils/colors/app_palette.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirestoreHandler _firestoreHandler = FirestoreHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            Text(
              "Game Swap Hub",
              style: context.textStyle.labelLarge,
            ),
            const Spacer(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: "email",
                    hintText: "example@gmail.com",
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppPalette.imperialRed, width: 4)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2)),
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 4)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blueAccent, width: 5)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2))),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (psw) {
                  _loginWithEmailAndPassword(context);
                },
                decoration: const InputDecoration(
                    // floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "password",
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppPalette.imperialRed, width: 4)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2)),
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 4)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blueAccent, width: 4)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2))),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Spacer(),
                FlutterSocialButton(
                  mini: true,
                  onTap: () {
                    Auth()
                        .signInWithApple()
                        .then((UserCredential? userCredentials) {
                      _onUserCredentialsAvailable(userCredentials, context);
                    });
                  },
                  buttonType: ButtonType.apple,
                ),
                const Spacer(),
                FlutterSocialButton(
                  mini: true,
                  onTap: () {
                    Auth()
                        .signInWithFacebook()
                        .then((UserCredential? userCredentials) {
                      _onUserCredentialsAvailable(userCredentials, context);
                    });
                  },
                  buttonType: ButtonType.facebook,
                ),
                const Spacer(),
                FlutterSocialButton(
                  mini: true,
                  onTap: () {
                    Auth()
                        .signInWithGoogle()
                        .then((UserCredential? userCredentials) {
                      _onUserCredentialsAvailable(userCredentials, context);
                    });
                  },
                  buttonType: ButtonType.google,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance
                        .signInAnonymously()
                        .then((UserCredential? userCredentials) {
                      _onUserCredentialsAvailable(userCredentials, context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: appleColor,
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(
                    Icons.face_5_outlined,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _onUserCredentialsAvailable(
      UserCredential? userCredentials, BuildContext context) {
    if (userCredentials != null && userCredentials.user?.uid != null) {
      _firestoreHandler.setupUserAccount(
          userCredentials.user!.uid, userCredentials.user?.email);
      context.go("/");
    }
  }

  Future<void> _loginWithEmailAndPassword(BuildContext context) async {
    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      Lgr.log("Email and passsord user ${user.user?.displayName}");
    } catch (e, s) {
      Lgr.errorLog("Login error: ", exception: e, st: s);
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case "invalid-credential":
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
            break;
          default:
            Lgr.errorLog(
                "Got Firebase auth exception, which I don't know what to do with.");
            ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                content: Container(
                  color: Colors.amberAccent,
                  child: Text(
                    "Unable to login or create an account. This has been noted and somebody should contact you shortly at ${_emailController.text}.",
                    style: context.textStyle.bodyMedium
                        ?.copyWith(color: AppPalette.imperialRed),
                  ),
                ),
                actions: const [SizedBox.shrink()]));
        }
      }
    } finally {
      context.go("/");
    }
  }
}

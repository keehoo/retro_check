import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/screens/user_profile/user_profile_cubit.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          TextButton(
              onPressed: () {
                Lgr.log("Unathentication");
                FirebaseAuth.instance.signOut();
                context.go("/");
              },
              child: const Text("Log out")),
          BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (context, state) {
              return Text("User Points : ${state.userPoints ?? 0}");
            },
          )
        ],
      )),
    );
  }
}

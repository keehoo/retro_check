import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';

const _userCollection = "users";

class FirestoreHandler {
  static final FirestoreHandler _singleton = FirestoreHandler._internal();

  final _firestore = FirebaseFirestore.instance;

  factory FirestoreHandler() {
    return _singleton;
  }

  FirestoreHandler._internal();

  Future<int> getUserPoints() async {
    final CollectionReference<Map<String, dynamic>> userCollectionRef =
        _firestore.collection(_userCollection);

    final QuerySnapshot<Map<String, dynamic>> user = await userCollectionRef
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    return user.docs.first.data()["points"] ?? 0;
  }

  Future<void> userAddedAGameOrImage() async {
    final CollectionReference<Map<String, dynamic>> userCollectionRef =
        _firestore.collection(_userCollection);

    final QuerySnapshot<Map<String, dynamic>> user = await userCollectionRef
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    final docs = user.docs;

    if (docs.isEmpty) {
      Lgr.errorLog("Couldn't find the user, is he/she logged in ?");
    } else if (docs.length > 1) {
      Lgr.errorLog("Found more users with the same id. Weird.");
    } else {
      final currentPoints = docs.first.data()["points"] as int;

      final currentData = docs.first.data();

      currentData["points"] = currentPoints + 1;

      Lgr.log("Adding +1 point $currentPoints");
      docs.first.reference.update(currentData);
    }
  }

  Future<void> setupUserAccount(String userId, String? userEmail) async {
    final CollectionReference<Map<String, dynamic>> userCollectionRef =
        _firestore.collection(_userCollection);

    final userWithTheSameIdAndEmail = await userCollectionRef
        .where("userId", isEqualTo: userId)
        .where("email", isEqualTo: userEmail)
        .get();

    if (userWithTheSameIdAndEmail.size == 0) {
      Lgr.log("Adding user as there's no users with the same id and email");
      _firestore.collection(_userCollection).add(
          <String, dynamic>{"userId": userId, "email": userEmail, "points": 0});
    }
  }
}

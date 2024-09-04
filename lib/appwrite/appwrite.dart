import 'dart:io' as io;

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:uuid/v4.dart';

var appWriteAddress = 'https://cloud.appwrite.io/v1';
var appWriteImagesBucketId = 'game_images';

class AppWriteHandler {
  static final AppWriteHandler _singleton = AppWriteHandler._internal();

  Client? client;

  factory AppWriteHandler() {
    return _singleton;
  }

  AppWriteHandler._internal();

  Future<void> init() async {
    client = Client();

    client
            ?.setEndpoint(appWriteAddress) // Your Appwrite Endpoint
            .setProject('66ab491c0037a48bd7d7') //// Your project ID
            .setSession("1")
            .setSelfSigned() // Use only on dev mode with a self-signed SSL cert
        ;

    // final account = Account(client!);
    // final Session session = await account.getSession(sessionId: "1");


    // await account.deleteSessions();
    // final user = await account.createAnonymousSession();
    // final User user = await account.create(
    //     userId: ID.custom("123"),
    //     email: "email@example.com",
    //     password: "password",
    //     name: "Walter O'Brien");
    //

    // print(user);
  }

  Future<List<Document>> getAllVideoGames() async {
    if (client != null) {
      Databases databases = Databases(client!);

      DocumentList result = await databases.listDocuments(
        databaseId: '66d083280030d4a5b869',
        collectionId: 'video_games',
        queries: [], // optional
      );
      return result.documents;
    } else {
      await init();
      return getAllVideoGames();
    }
  }

  Future<bool> isGameInRemoteDb(VideoGameModel game) async {
    Databases databases = Databases(client!);

    final eanDocuments = await databases.listDocuments(
        databaseId: '66d083280030d4a5b869',
        collectionId: "video_games",
        queries: [
          Query.equal('ean', game.ean),
        ]);

    /// if documents of above query is empty, that means the game of such ean is not yet in the db.
    return eanDocuments.documents.isEmpty;
  }

  Future<Map<String, dynamic>?> saveGameInDatabase(VideoGameModel game) async {
    Databases databases = Databases(client!);

    final isGameAlreadyAdded = await isGameInRemoteDb(game);

    if (isGameAlreadyAdded == false) {
      return game.toJson();
    }

    final d = Role.any();
    try {
      Document result = await databases.createDocument(
        databaseId: '66d083280030d4a5b869',
        collectionId: 'video_games',
        documentId: game.uuid ?? const UuidV4().generate(),

        data: game.toJson(),
        permissions: [
          Permission.write(d),
        ], // optional
      );

      return result.data;
    } catch (e, s) {
      print("Error Appwrite");
      return null;
    }
  }

  Future<String> storeGameImage(io.File file, String gameUuid) async {
    final storage = Storage(client!);

    await storage.createFile(
        bucketId: appWriteImagesBucketId,
        fileId: gameUuid,
        file: InputFile.fromPath(path: file.path, filename: '$gameUuid.jpg'),
        permissions: [Permission.write(Role.any())]);

    final downloadFile =
        '$appWriteAddress/storage/buckets/$appWriteImagesBucketId/files/$gameUuid/preview';
    return downloadFile;
  }

  Future<void> updatePictureOf(
      io.File file, String gameBase64String, VideoGameModel game) async {
    final String d = await storeGameImage(file, game.uuid!);
    print("Updated image for game $d");
    final updatedGame =
        game.copyWithBase64Image(imageBase64: gameBase64String, imageUrl: d);
    await updateGameInDatabase(updatedGame);
  }

  Future<Map<String, dynamic>?> updateGameInDatabase(
      VideoGameModel game) async {
    Databases databases = Databases(client!);
    final d = Role.any();
    try {
      Document result = await databases.updateDocument(
        databaseId: '66d083280030d4a5b869',
        collectionId: 'video_games',
        documentId: game.uuid!,
        data: game.toJson(),
        permissions: [
          Permission.write(d),
        ], // optional
      );
      return result.data;
    } catch (e, s) {
      print("Error Appwrite");
      return null;
    }
  }
}

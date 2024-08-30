import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:uuid/v4.dart';
import 'dart:io' as io;

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
            ?.setEndpoint(
                appWriteAddress) // Your Appwrite Endpoint
            .setProject('66ab491c0037a48bd7d7') //// Your project ID
            .setSession("1")
        .setSelfSigned() // Use only on dev mode with a self-signed SSL cert
        ;

    final account = Account(client!);

    await account.deleteSessions();
    final user = await account.createAnonymousSession();
    // final User user = await account.create(
    //     userId: ID.custom("123"),
    //     email: "email@example.com",
    //     password: "password",
    //     name: "Walter O'Brien");
    //

    print(user);
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

  Future<Map<String, dynamic>?> saveGameInDatabase(VideoGameModel game) async {
    Databases databases = Databases(client!);
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

    final f = await storage.createFile(
      bucketId: appWriteImagesBucketId,
      fileId: gameUuid,
      file: InputFile.fromPath(path: file.path, filename: '$gameUuid.jpg'),
      permissions: [
        Permission.write(Role.any())
      ]
    );

    final downloadFile = '$appWriteAddress/storage/buckets/$appWriteImagesBucketId/files/$gameUuid/preview';
    return downloadFile;

  }
}

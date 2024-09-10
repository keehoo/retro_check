import 'dart:io' as io;
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:dio/dio.dart';
import 'package:untitled/generic_video_game_model.dart';
import 'package:untitled/local_storage/local_database_service.dart';
import 'package:untitled/utils/logger/KeehooLogger.dart';

var appWriteAddress = 'https://cloud.appwrite.io/v1';
var appWriteImagesBucketId = 'game_images';
const appWriteProject = "66ab491c0037a48bd7d7";

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
            .setSession("2")
            .setSelfSigned() // Use only on dev mode with a self-signed SSL cert
        ;

  }

  Future<List<Document>> getAllVideoGames() async {
    if (client != null) {
      Databases databases = Databases(client!);

      DocumentList result = await databases.listDocuments(
        databaseId: dataBaseId,
        collectionId: collectionId,
        // queries: [/**/], // optional
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
        databaseId: dataBaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('ean', game.ean),
        ]);

    /// if documents of above query is empty, that means the game of such ean is not yet in the db.
    return eanDocuments.documents.isEmpty;
  }

  static const String dataBaseId = "retro";
  static const String collectionId = "66e074bb00343d4921cc";

  Future<Map<String, dynamic>?> saveGameInDatabase(VideoGameModel game) async {
    assert(game.ean != null);
    Databases databases = Databases(client!);

    final isGameAlreadyAdded = await isGameInRemoteDb(game);

    if (isGameAlreadyAdded == false) {
      return game.toAppWriteJson();
    }

    final d = Role.any();
    try {
      Document result = await databases.createDocument(
        databaseId: dataBaseId,
        collectionId: collectionId,
        documentId: game.ean!,
        data: game.toAppWriteJson(),
        permissions: [
          Permission.write(d),
        ], // optional
      );

      return result.data;
    } catch (e, s) {
      Lgr.errorLog("Error Appwrite $e", exception: e, st: s);
      return null;
    }
  }

  Future<Uint8List> storeGameImage(io.File file, String gameEan) async {
    final storage = Storage(client!);

    try {
      await storage.createFile(
          bucketId: appWriteImagesBucketId,
          fileId: gameEan,
          file: InputFile.fromPath(path: file.path, filename: '$gameEan.jpg'),
          onProgress: (UploadProgress a) {
            Lgr.log("Upload progress ${a.chunksUploaded} / ${a.chunksTotal} ");
          },
          permissions: [Permission.write(Role.any())]);
    } catch (e, _) {
      await storage.deleteFile(
        bucketId: appWriteImagesBucketId,
        fileId: gameEan,
      );
      await storage.createFile(
          bucketId: appWriteImagesBucketId,
          fileId: gameEan,
          file: InputFile.fromPath(path: file.path, filename: '$gameEan.jpg'),
          onProgress: (UploadProgress a) {
            Lgr.log("Upload progress ${a.chunksUploaded} / ${a.chunksTotal} ");
          },
          permissions: [Permission.write(Role.any())]);
    }

    final Uint8List downloadFile = await storage.getFilePreview(
        bucketId: appWriteImagesBucketId, fileId: gameEan);

    return downloadFile;
  }

  Future<void> updatePictureOf(
      io.File file, String gameBase64String, VideoGameModel game) async {
    final gameImageUrl = await storeGameImage(file, game.ean!);

    await updateGameInDatabase(game.copyWithBase64Image(
        imageBase64: gameBase64String,
        imageUrl: gameImageUrl.lengthInBytes.toString()));
  }

  Future<Map<String, dynamic>?> updateGameInDatabase(
      VideoGameModel game) async {
    Databases databases = Databases(client!);
    final d = Role.any();
    try {
      Document result = await databases.updateDocument(
        databaseId: dataBaseId,
        collectionId: collectionId,
        documentId: game.ean!,
        data: game.toAppWriteJson(),
        permissions: [
          Permission.write(d),
        ], // optional
      );
      LocalDatabaseService().updateLocalDbGame(game);
      return result.data;


    } catch (e, _) {
      Lgr.errorLog("Error Appwrite $e", exception: e);
      return null;
    }
  }

  Future<Uint8List> getFileDownload(VideoGameModel game) async {
    final dio = Dio();
    if (game.imageUrl?.startsWith("http") ?? false) {
      final httpResult = await dio.get(game.imageUrl ?? "",
          options: Options(responseType: ResponseType.bytes));
      final bytes = Uint8List.fromList(httpResult.data as List<int>);
      return bytes;
    }
    // https://cloud.appwrite.io/v1/storage/buckets/game_images/files/c10d3c3c-b8e7-4476-9f81-b2399f596ad3/view?project=66ab491c0037a48bd7d7&project=66ab491c0037a48bd7d7&mode=admin
    final storage = Storage(client!);
    return storage.getFileView(
        bucketId: appWriteImagesBucketId, fileId: game.ean!);
  }
}

const imageUrlTemplate =
    "https://cloud.appwrite.io/v1/storage/buckets/game_images/files/c10d3c3c-b8e7-4476-9f81-b2399f596ad3/view?project=66ab491c0037a48bd7d7&project=66ab491c0037a48bd7d7";

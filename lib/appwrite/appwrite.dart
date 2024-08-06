import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AppWriteHandler {
  Future<void> init() async {
    Client client = Client();

    client
            .setEndpoint(
                'https://cloud.appwrite.io/v1') // Your Appwrite Endpoint
            .setProject('66ab491c0037a48bd7d7') //// Your project ID
            .setSelfSigned() // Use only on dev mode with a self-signed SSL cert
        ;

    // Register User
    Account account = Account(client);
    User usrt = await account.get();

    final User user = await account.create(
        userId: ID.custom("123"),
        email: "email@example.com",
        password: "password",
        name: "Walter O'Brien");

    print(user);
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'api_keys_firebase_config.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    return FirebaseOptions(
      appId: "1:66754744895:android:5e9736b7306a1e8949de8a",
      apiKey: API_KEY_PART_1 + API_KEY_PART_2 + API_KEY_PART_3 + API_KEY_PART_4,
      projectId: "maligali-5bac7",
      androidClientId:
          "66754744895-heal9ua95u7dtsru9vje8ejhnsdufs7i.apps.googleusercontent.com",
      messagingSenderId: "66754744895",
      authDomain: "maligali-5bac7.firebaseapp.com",
    );
  }
}

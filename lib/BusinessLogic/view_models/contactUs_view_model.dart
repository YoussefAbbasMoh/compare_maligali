import 'package:cloud_firestore/cloud_firestore.dart';

class ContactUsViewModel {
  Future<Map<String, String>> getContactDataFromFirebase() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('appController')
        .doc("contactUsInfo")
        .get();
    Map<String, dynamic> data = docSnapshot.data()!;
    Map<String, String> ContactUsData = {};

    ContactUsData = {
      "email": data["email"],
      "phoneNo1": data["phoneNo"],
      "phoneNo2": data["phoneNo2"],
      "whatsapp": data["whatsapp"],
    };
    return ContactUsData;
  }
}

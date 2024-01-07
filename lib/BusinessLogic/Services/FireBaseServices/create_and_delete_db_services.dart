import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Models/store_owner_model.dart';

class CreateAndDeleteDBServices {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  DocumentReference userDBReference() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(StoreOwner().getUid());
  }

  DocumentReference customersDBReference(String customerUid){
    return _fireStore.collection("Mhalatko_users").doc(customerUid);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_and_delete_db_services.dart';

class UserCustomersServices {
  CollectionReference userCustomersReference =
      CreateAndDeleteDBServices().userDBReference().collection('userCustomers');

  addNewReceiptToCustomer(String customerNumber, String receiptNumber) async {
    List<dynamic> previousReceipts;
    await userCustomersReference.doc(customerNumber).get().then((value) {
      if (value.exists) {
        previousReceipts = value.get("receipts");
        previousReceipts.add(receiptNumber);
        userCustomersReference
            .doc(customerNumber)
            .update({"receipts": previousReceipts});
      } else {
        previousReceipts = [];
        previousReceipts.add(receiptNumber);
        userCustomersReference
            .doc(customerNumber)
            .set({"receipts": previousReceipts});
      }
    });
  }
}

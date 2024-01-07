import 'authentication_view_models/authentication_view_model.dart';
import '../Models/store_owner_model.dart';
import 'package:flutter/cupertino.dart';

class UpdateUserInfoViewModel extends ChangeNotifier {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopDeliveryCountController =
  TextEditingController();
  final TextEditingController _shopLocationController = TextEditingController();

  String _shopTypeController = "";
  String _shopSizeController = "";
  String uid = "";
  bool _legalStatement = false;

  UpdateUserInfoViewModel() {
    _initControllers();
  }

  _initControllers() {
    Map<String, dynamic> userData = StoreOwner().getStoreOwnerData();
    uid = userData['uid']!;
    _nameController.text = userData['storeOwnerName']!;
    _numberController.text = userData['storeOwnerNumber']!;
    _shopNameController.text = userData['storeName']!;
    _shopDeliveryCountController.text = userData['deliveryManCount']!;
    _shopTypeController = userData['storeType']!;
    _shopSizeController = userData['storeSize']!;
    _shopLocationController.text = userData['shopGPSLocation']!;
    _legalStatement = userData['legalStatement']!;
  }

  TextEditingController get nameController => _nameController;
  TextEditingController get numberController => _numberController;
  TextEditingController get shopNameController => _shopNameController;
  TextEditingController get deliveryManCountController =>
      _shopDeliveryCountController;
  TextEditingController get shopLocationController => _shopLocationController;
  String get shopTypeController => _shopTypeController;
  String get shopSizeController => _shopSizeController;

  shopSizeControllerSetter(String? controller) {
    _shopSizeController = controller!;
  }

  final _auth = AuthenticationServices().auth();
  final _fireStore = AuthenticationServices().fireStore();

  updateUserInfo() async {
    await _fireStore
        .collection('users')
        .doc(uid)
        .update({
      'ownerName': _nameController.text.trim(),
      'ownerNumber': _numberController.text.trim(),
      'shopName': _shopNameController.text.trim(),
      'shopType': _shopTypeController,
      'deliveryManCount': _shopDeliveryCountController.text.trim(),
      "shopGPSLocation": _shopLocationController.text.trim(),
      'shopSize': _shopSizeController,
    })
        .then((value) async => {
      await StoreOwner().updateOwnerData(
          uidUpdated: _auth.currentUser!.uid,
          storeNameUpdated: _shopNameController.value.text,
          shopGPSLocationUpdated: _shopLocationController.value.text,
          storeTypeUpdated: _shopTypeController,
          storeSizeUpdated: _shopSizeController,
          storeOwnerNameUpdated: _nameController.value.text,
          storeOwnerNumberUpdated: _numberController.value.text,
          deliveryManCountUpdated:
          _shopDeliveryCountController.value.text,
          legalStatementUpdated: _legalStatement),
    })
        .catchError((onError) => {
      debugPrint('Error saving user to db.' + onError.toString()),
      notifyListeners()
    });
  }
}
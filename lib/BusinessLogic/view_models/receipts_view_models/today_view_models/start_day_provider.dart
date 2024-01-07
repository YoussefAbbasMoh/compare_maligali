import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StartDayProvider {
  static const _storage = FlutterSecureStorage();
  static bool dayStarted = false;

  //bool getDayStarted() => dayStarted;

  static setDayStarted(bool newState) async {
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    print("inside setDayStarted");
    print(newState);
    if (dayStarted != newState) {
      dayStarted = newState;
      print(dayStarted);
      print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
      // if(newState == true){
      //   //TodayPageHourCollectionsVMNew.setDayJustStartedToTrue();
      // }
      // if (newState == true) {
      //   //TodayPageHourCollectionsVMNew.setDayJustStartedToTrue();
      // }

      await updateDayStateInStorage();
    }
  }

  static Future<void> updateDayStateInStorage() async {
    await _storage.write(key: "dayState", value: dayStarted.toString());
    //await storeDayStartHour();
  }

  static Future<bool> getCurrentDayState() async {
    String? stringRes = await _storage.read(key: "dayState");
    if (stringRes != null) {
      dayStarted = (stringRes.toLowerCase() == 'true') ? true : false;
      return dayStarted;
    }
    return false;
  }
}

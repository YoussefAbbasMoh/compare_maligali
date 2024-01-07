import 'package:maligali/BusinessLogic/view_models/receipts_view_models/common_receipt_view_models/hour_view_model.dart';
import 'package:maligali/BusinessLogic/view_models/receipts_view_models/today_view_models/start_day_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../Models/hourly_collection_model.dart';
import '../../../utils/time_and_date_utils.dart';
import 'package:flutter/material.dart';

class PreviousDayPageViewModel extends ChangeNotifier {
  BuildContext? pageCtx;

  String _startHour = "-";
  String _endHour = "-";
  String date = "-";
  String day = "0";
  String month = "0";
  String year = "0";
  String totalHoursWorked = "0";
  String selectedHour = "-";

  HourlyReceiptCollection? selectedHourCollection;
  Map<String,HourlyReceiptCollection> dayHourCollections = {};

  previousDayPageVMDateInitializer(DateTime dateSelected){
    day = dateSelected.day.toString();
    month = dateSelected.month.toString();
    year = dateSelected.year.toString();
    date = reformatDateSplittedToCombined(day, month, year);
  }

  Future<String> previousDayPageVMHoursInitializer() async {

    dayHourCollections = await getHourCollectionsInList();
    totalHoursWorked = dayHourCollections.length.toString();


    if(dayHourCollections.isEmpty){
      _startHour = "00";
      _endHour = "00";
    }else{
      List<String> keys = dayHourCollections.keys.toList(growable: false);

      _startHour = dayHourCollections[keys[0]]!.time;
      _endHour = dayHourCollections[keys[dayHourCollections.length-1]]!.time;

    }
    return "done";
  }

  Future<Map<String,HourlyReceiptCollection>> getHourCollectionsInList() async {
    Map<String,HourlyReceiptCollection> hourCollections = {};
    for (int i = 0; i <= 24; i++) {
      print(i);
      String hourCollectionID = reformatHourSplitted(i.toString());
      HourlyReceiptCollection? collection = await HourReceiptViewModel()
          .fetchWorkedHourSummaryOnlyFromDB(date: date, collHour: hourCollectionID);
      if (collection != null) {
        hourCollections[collection.time] = collection;
      }
    }
    return hourCollections;
  }




  // functions handling dayState : ---------------------------------------------

  dayReloadedInitializer(DateTime previousDate) async {
    date = reformatDateSplittedToCombined(previousDate.day.toString(),
        previousDate.month.toString(), previousDate.year.toString());
  }

  updateHourDataINVM(String containerHour) async {
    String hourCollectionID = reformatHourSplitted(containerHour);
    HourlyReceiptCollection? collection = await HourReceiptViewModel()
        .fetchWorkedHourSummaryOnlyFromDB(date: date, collHour: hourCollectionID);

    if (collection != null) {
      dayHourCollections[collection.time] = collection;
      notifyListeners();
    }
  }
}
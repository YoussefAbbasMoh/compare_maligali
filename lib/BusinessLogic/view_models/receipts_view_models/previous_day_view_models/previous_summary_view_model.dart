import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../Models/barChartModel.dart';
import '../../../Services/FireBaseServices/coll_receipt_services.dart';
import '../../../Services/local_inventory_services/user_inventory_services.dart';
import '../../../utils/time_and_date_utils.dart';
import 'package:flutter/foundation.dart';
import '../../../../constants.dart';
import 'dart:math';

class PreviousSummaryViewModel {
  ReceiptCollectionServices receiptDBServicesObj = ReceiptCollectionServices();
  UserInventoryServices userInv = UserInventoryServices();

  // week starts from 1 as monday so:
  // {monday:1, tuesday:2, Wednesday:3, thursday:4, friday:5, Saturday:6, sunday:7}
  // our egyptian days start at saturday so:
  // {Saturday:6, sunday:7, monday:1, tuesday:2, Wednesday:3, thursday:4, friday:5}

  String todayDate = getNowDate();

  List<DateTime> getDays({required DateTime start, required DateTime end}) {
    final days = end.difference(start).inDays;
    List<DateTime> daysWithDates = [
      for (int i = 0; i <= days; i++) start.add(Duration(days: i))
    ];
    return daysWithDates;
  }

  Future<Map<String, dynamic>> getWeekSummary(
      DateTime startDate, DateTime endDate) async {
    List<DateTime> days = getDays(
      start: startDate,
      end: endDate,
    );

    Map<String, dynamic> productsSumResults = await getProductsSum(days);

    var extremesMap = get5ExtremeProducts(
        leastSoldProductsMapDuringMonth:
            productsSumResults["leastSoldProductsMapDuringMonth"],
        topSoldProductsMapDuringMonth:
            productsSumResults["topSoldProductsMapDuringMonth"]);

    return {
      "totalRevenueMadeForDay": productsSumResults["totalRevenueMadeForDay"],
      "totalProfitMadeForDay": productsSumResults["totalProfitMadeForDay"],
      "totalItemsSoldInDay": productsSumResults["totalItemsSoldInDay"],
      "highestNumberOfProducts": productsSumResults["highestNumberOfProducts"],
      "highestDayHavingSales": productsSumResults["highestDayHavingSales"],
      "topFiveSoldItems": extremesMap["topFiveSoldItems"],
      "leastFiveSoldItems": extremesMap["leastFiveSoldItems"],
    };
  }

  Future<Map<String, dynamic>> getProductsSum(
      List<DateTime> remainingDaysForWeek) async {
    double totalRevenueMadeForDay = 0;
    double totalProfitMadeForDay = 0;
    double totalItemsSoldInDay = 0;
    double highestNumberOfProducts =
        0; // in the day having most sales, what was the number of products sold in that day
    String highestDayHavingSales = "";
    Map<String, double> topSoldProductsMapDuringMonth = {};
    Map<String, double> leastSoldProductsMapDuringMonth = {};

    //Map<String, int> productsMapCollected = {};

    for (DateTime day in remainingDaysForWeek) {
      String date = reformatDateSplittedToCombined(
          day.day.toString(), day.month.toString(), day.year.toString());
      DocumentReference<Object?> summaryRef;
      try {
        summaryRef =
            receiptDBServicesObj.userReceiptsCollectionReference.doc(date);
        DocumentSnapshot<Object?>? snapshot = null;
        try {
          snapshot =
              await summaryRef.get(const GetOptions(source: Source.cache));
        } on Exception catch (e) {
          if (await InternetConnectionChecker().hasConnection) {
            snapshot =
                await summaryRef.get(const GetOptions(source: Source.server));
          }
        }
        if (snapshot != null) {
          totalRevenueMadeForDay += snapshot.get("totalDayRevenue");
          totalProfitMadeForDay += snapshot.get("totalDayProfit");
          double items = snapshot.get("numberOfProductsSold");

          totalItemsSoldInDay += items;

          if (highestNumberOfProducts < items) {
            highestNumberOfProducts = items;
            highestDayHavingSales = date;
          }

          String barCodeProductMostBoughtInDay =
              snapshot.get("topSoldProductBarCode");

          if (barCodeProductMostBoughtInDay != "") {
            double countProductMostBoughtInDay =
                snapshot.get("topSoldProductCount");
            if (topSoldProductsMapDuringMonth
                .containsKey(barCodeProductMostBoughtInDay)) {
              double oldCount =
                  topSoldProductsMapDuringMonth[barCodeProductMostBoughtInDay]!;
              topSoldProductsMapDuringMonth[barCodeProductMostBoughtInDay] =
                  oldCount + countProductMostBoughtInDay;
            } else {
              topSoldProductsMapDuringMonth[barCodeProductMostBoughtInDay] =
                  countProductMostBoughtInDay;
            }
          }

          String barCodeProductLeastBoughtInDay =
              snapshot.get("leastProductSoldBarCode");

          if (barCodeProductLeastBoughtInDay != "") {
            double countProductLeastBoughtInDay =
                snapshot.get("leastSoldProductCount");
            if (leastSoldProductsMapDuringMonth
                .containsKey(barCodeProductLeastBoughtInDay)) {
              double oldCount = leastSoldProductsMapDuringMonth[
                  barCodeProductLeastBoughtInDay]!;
              leastSoldProductsMapDuringMonth[barCodeProductLeastBoughtInDay] =
                  oldCount + countProductLeastBoughtInDay;
            } else {
              leastSoldProductsMapDuringMonth[barCodeProductLeastBoughtInDay] =
                  countProductLeastBoughtInDay;
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("error from inside getProductsSum: ");
          print(e);
        }
      }
    }

    return {
      "totalRevenueMadeForDay": totalRevenueMadeForDay,
      "totalProfitMadeForDay": totalProfitMadeForDay,
      "totalItemsSoldInDay": totalItemsSoldInDay,
      "highestNumberOfProducts": highestNumberOfProducts,
      "highestDayHavingSales": highestDayHavingSales,
      "leastSoldProductsMapDuringMonth": leastSoldProductsMapDuringMonth,
      "topSoldProductsMapDuringMonth": topSoldProductsMapDuringMonth,
      //"topProductsList": topProductsList,
      //"leastProductsList": leastProductsList,
//      "productsMapCollected": productsMapCollected,
    };
  }

  Map<String, dynamic> get5ExtremeProducts(
      {required Map<String, double> topSoldProductsMapDuringMonth,
      required Map<String, double> leastSoldProductsMapDuringMonth}) {

    List<Map<String, String>> leastFiveSoldItems = [];
    List<Map<String, String>> topFiveSoldItems = [];

    double maxProductCount = 0;
    if (topSoldProductsMapDuringMonth.isNotEmpty) {

      if (topSoldProductsMapDuringMonth.length > 5) {
        for (int i = 0; i < 5; i++) {
          List<double> counts = topSoldProductsMapDuringMonth.values.toList();
          maxProductCount = counts.reduce(max);
          int maxIndex =
              counts.indexWhere((element) => element == maxProductCount);
          String item = topSoldProductsMapDuringMonth.keys.elementAt(maxIndex);
          String productName = userInv
              .searchUserInventoryByProductNameOrBarCode(item)
              .first
              .productName;
          topFiveSoldItems.add({
            "productName": productName,
            "productCount": maxProductCount.toString()
          });
          topSoldProductsMapDuringMonth
              .remove(topSoldProductsMapDuringMonth.keys.elementAt(maxIndex));
        }
      } else {
        for (String barcode in topSoldProductsMapDuringMonth.keys.toList()) {
          var res = userInv.searchUserInventoryByProductNameOrBarCode(barcode);
          if(res.length>0) {
            var res2 = res.first;
            String productName = res2.productName;
            topFiveSoldItems.add({
              "productName": productName,
              "productCount": topSoldProductsMapDuringMonth[barcode].toString()
            });
          }
        }
      }
    }
    double minProductCount = 0;

    if (leastSoldProductsMapDuringMonth.isNotEmpty) {

      if (leastSoldProductsMapDuringMonth.length > 5) {
        for (int i = 0; i < 5; i++) {
          List<double> counts = leastSoldProductsMapDuringMonth.values.toList();
          minProductCount = counts.reduce(max);

          int minIndex =
              counts.indexWhere((element) => element == minProductCount);
          String item =
              leastSoldProductsMapDuringMonth.keys.elementAt(minIndex);
          String productName = userInv
              .searchUserInventoryByProductNameOrBarCode(item)
              .first
              .productName;
          leastFiveSoldItems.add({
            "productName": productName,
            "productCount": minProductCount.toString()
          });
          leastSoldProductsMapDuringMonth
              .remove(leastSoldProductsMapDuringMonth.keys.elementAt(minIndex));
        }
      } else {
        for (String barcode in leastSoldProductsMapDuringMonth.keys.toList()) {
          String productName = userInv
              .searchUserInventoryByProductNameOrBarCode(barcode)
              .first
              .productName;
          leastFiveSoldItems.add({
            "productName": productName,
            "productCount": leastSoldProductsMapDuringMonth[barcode].toString()
          });
        }
      }
    }
    return {
      "leastFiveSoldItems": leastFiveSoldItems,
      "topFiveSoldItems": topFiveSoldItems
    };
  }

  Future<Map<String, dynamic>> getBiWeekSummary(
      DateTime startDate, DateTime endDate) async {
    List<DateTime> days = getDays(
      start: startDate,
      end: endDate,
    );

    Map<String, dynamic> productsSumResults = await getProductsSum(days);

    var extremesMap = get5ExtremeProducts(
        leastSoldProductsMapDuringMonth:
            productsSumResults["leastSoldProductsMapDuringMonth"],
        topSoldProductsMapDuringMonth:
            productsSumResults["topSoldProductsMapDuringMonth"]);

    return {
      "totalRevenueMadeForDay": productsSumResults["totalRevenueMadeForDay"],
      "totalProfitMadeForDay": productsSumResults["totalProfitMadeForDay"],
      "totalItemsSoldInDay": productsSumResults["totalItemsSoldInDay"],
      "highestNumberOfProducts": productsSumResults["highestNumberOfProducts"],
      "highestDayHavingSales": productsSumResults["highestDayHavingSales"],
      "topFiveSoldItems": extremesMap["topFiveSoldItems"],
      "leastFiveSoldItems": extremesMap["leastFiveSoldItems"],
    };
  }

  Future<Map<String, dynamic>> getMonthSummary(
      DateTime startDate, DateTime endDate) async {
    List<DateTime> days = getDays(
      start: startDate,
      end: endDate,
    );

    Map<String, dynamic> productsSumResults = await getProductsSum(days);

    var extremesMap = get5ExtremeProducts(
        leastSoldProductsMapDuringMonth:
            productsSumResults["leastSoldProductsMapDuringMonth"],
        topSoldProductsMapDuringMonth:
            productsSumResults["topSoldProductsMapDuringMonth"]);

    return {
      "totalRevenueMadeForDay": productsSumResults["totalRevenueMadeForDay"],
      "totalProfitMadeForDay": productsSumResults["totalProfitMadeForDay"],
      "totalItemsSoldInDay": productsSumResults["totalItemsSoldInDay"],
      "highestNumberOfProducts": productsSumResults["highestNumberOfProducts"],
      "highestDayHavingSales": productsSumResults["highestDayHavingSales"],
      "topFiveSoldItems": extremesMap["topFiveSoldItems"],
      "leastFiveSoldItems": extremesMap["leastFiveSoldItems"],
    };
  }

  Future<List<BarChartModel>> getGraphData(
      DateTime startDate,
      DateTime endDate,
      Future<Map<String, dynamic>> Function(DateTime, DateTime)
          dataFetchingFunction,
      String format) async {
    Map<String, int> subtractedDaysFromFormat = {
      "الشهر": 30,
      "الاسبوعين": 14,
      "الاسبوع": 7
    };

    Map<String, List<String>> chartLabelFromFormat = {
      "الشهر": getPastThreeMonthsInArabic(startDate),
      "الاسبوعين": [
        "نص الشهر\n الحالي",
        "نص الشهر\n الثاني",
        "نص الشهر\n الثالث"
      ],
      "الاسبوع": ["الاسبوع\n ده", "الاسبوع\n الثاني", "الاسبوع\n الثالث"]
    };

    DateTime summaryEndDate2 = startDate.subtract(const Duration(days: 1));
    DateTime summaryStartDate2 = summaryEndDate2
        .subtract(Duration(days: subtractedDaysFromFormat[format] ?? 29));
    DateTime summaryEndDate3 =
        summaryStartDate2.subtract(const Duration(days: 1));
    DateTime summaryStartDate3 = summaryEndDate3
        .subtract(Duration(days: subtractedDaysFromFormat[format] ?? 29));

    List<int> rows = [];

    rows = await Future.wait([
      dataFetchingFunction(startDate, endDate),
      dataFetchingFunction(summaryStartDate2, summaryEndDate2),
      dataFetchingFunction(summaryStartDate3, summaryEndDate3)
    ]).then((List<Map<String, dynamic>> rows) {
      Map<String, dynamic> row1summary = rows[0];
      Map<String, dynamic> row2summary = rows[1];
      Map<String, dynamic> row3summary = rows[2];

      return [
        row1summary["totalProfitMadeForDay"].round(),
        row2summary["totalProfitMadeForDay"].round(),
        row3summary["totalProfitMadeForDay"].round()
      ];
    });

    return [
      BarChartModel(
        day: chartLabelFromFormat[format]![2],
        profit: rows[2],
        color: charts.ColorUtil.fromDartColor(textYellow),
      ),
      BarChartModel(
        day: chartLabelFromFormat[format]![1],
        profit: rows[1],
        color: charts.ColorUtil.fromDartColor(textYellow),
      ),
      BarChartModel(
        day: chartLabelFromFormat[format]![0],
        profit: rows[0],
        color: charts.ColorUtil.fromDartColor(textYellow),
      ),
    ];
  }
}

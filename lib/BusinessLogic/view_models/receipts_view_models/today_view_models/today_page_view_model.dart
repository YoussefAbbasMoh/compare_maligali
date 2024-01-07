import 'package:maligali/BusinessLogic/Services/local_inventory_services/hive_services.dart';
import 'package:maligali/BusinessLogic/Services/local_inventory_services/user_inventory_services.dart';
import 'package:maligali/BusinessLogic/view_models/receipts_view_models/today_view_models/start_day_provider.dart';
import '../../../utils/flutter_secure_storage_functions.dart';
import '../../../Models/product_in_receipt_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Models/hourly_collection_model.dart';
import '../../../Services/FireBaseServices/coll_receipt_services.dart';
import '../../../utils/time_and_date_utils.dart';
import 'package:flutter/foundation.dart';
import '../../../utils/globalSnackBar.dart';
import '../common_receipt_view_models/hour_view_model.dart';
import 'dart:math';

class TodayPageViewModel extends ChangeNotifier {
  String _date = "";
  String _day = "";
  String _month = "";
  String _year = "";
  String _hour = "";
  String _startHour = "-1";

  String case1 = "dayFreshStart";
  String case2 = "dayRestartedAfterEnd";
  String case3 = "refreshedPage";
  String case4 = "returnedToApp";
  bool _changedWidgetDependency = false;
  String _hourToUpdate = "-";
  setHourToUpdate(String hourToUpdate){
    _hourToUpdate = hourToUpdate;
  }

  UserInventoryServices userInvServices = UserInventoryServices();

  setChangedWidgetDependency() {
    // setter for the _changedWidgetDependency variable
    _changedWidgetDependency = true;
  }

  Map<String, HourlyReceiptCollection> overallCollectionsMap = {};
  HourlyReceiptCollection? currentCollection;
  static bool allowReceiptCreation = true;

  // --- START OF CLASS FUNCTIONS ----------------------------------------------

  Future<String> checkForStartHourInDB() async {
    print(
        "NOTE CODE 1: FROM INSIDE 'checkForStartHourInDB' function: start...");

    //check for the existence of the startHour attribute in the firebase document of the day

    DocumentReference<Object?> dayRef;
    ReceiptCollectionServices receiptDBServicesObj =
    ReceiptCollectionServices();

    String startHour = "-1";
    DocumentSnapshot<Object?> dayDoc;

    dayRef = receiptDBServicesObj.userReceiptsCollectionReference.doc(_date);

    try {
      dayDoc = await dayRef.get(const GetOptions(
          source: Source.cache)); // check for the document snapshot in cache

      if (!dayDoc.exists) {
        dayDoc = await dayRef
            .get(); // if cache snapshot is empty get the dayDocument data from server
      }

      startHour =
          await dayDoc.get("startHour"); // get the startHour attribute if exists

    } catch (e) {
      print(
          "ERROR CODE 1: FROM 'checkForStartHourInDB()': StartHour was not found in cache: $e");
      try {
        dayDoc = await dayRef.get();
        startHour = dayDoc.get("startHour");
      } catch (e) {
        print(
            "ERROR CODE 2: FROM 'checkForStartHourInDB()': StartHour was not found in Firebase: $e");
        print(
            "reason for ERROR CODE 2: Day Have not been started or due to previous error while saving the starthour in firebase collections");
      }
    }

    print("NOTE CODE 2: FROM INSIDE 'checkForStartHourInDB' function: end...");
    return startHour; // if startHour returned == "-1" then day not started
  }

  Future<String> defineDayCase() async {
    print("NOTE CODE 1: FROM INSIDE 'defineDayCase' function: start...");

    // fetching the start hour stored in storage help identify whether the day is opened or not
    _startHour = (await fetchStartHour()) ?? "-1";

    if (_startHour == "-1") {
      // if no start hour is stored in the storage, we have two cases:
      // case 1: the app is started freshly
      // case 2: the app is started again after being ended
      String returnedStartHourFromDB = await checkForStartHourInDB();

      if (returnedStartHourFromDB == "-1") {
        // initialize the startHour With current Hour and save it to storage. Also store other important attributes.
        await storeDayStartHour_toStorageAndDB();
        return case1; // dayFreshStart
      } else {
        // re-initialize the startHour With StartHour fetched from DB and save it to storage. Also store the current working hour.
        await storeDayStartHourFetchedFromDB_toStorage(
            startHourFromDB: returnedStartHourFromDB);
        return case2; // dayRestartedAfterEnd
      }
    } else {
      // _changedWidgetDependency : detects if widget dependency is changed meaning the page needs to be refreshed
      if (_changedWidgetDependency == true && _hour != "") {
        _changedWidgetDependency =
        false; // return back to initial state after knowing the case
        // todo check if still in same day
        // todo check if still in same hour
        return case3; // refreshedPage
      } else {
        _changedWidgetDependency =
        false; // _changedWidgetDependency is, by default, changed to true when building the widgets tree for the first time
        // this is the only case where we need to reinitialize the VM Vars:
        // in cases 1 and 2, initializeVMVars is called in the startDay function
        // in case 3, the app is already in use and the variables are already set as required
        initializeVMVars();
        return case4; // returnedToApp
      }
    }
    print("NOTE CODE 2: FROM INSIDE 'defineDayCase' function: done...");
  }

  Future<bool> mainOperations() async {
    // this function is responsible for running the expected operation on
    // entering/ re-entering the TodayReceiptsScreen page based on case
    // returned from the defineDayCase function
    String dayCase =
    await defineDayCase(); // get the VM loading case according to certain conditions
    print(
        "NOTE CODE 1: FROM INSIDE 'mainOperations': the day case result is: $dayCase");

    if (dayCase == case1) {
      //dayFreshStart
      print(
          "NOTE CODE 2: FROM INSIDE 'mainOperations': Entered in case 1: $case1");
      await runCase1Operation();
    } else if (dayCase == case2) {
      // dayRestartedAfterEnd
      print(
          "NOTE CODE 2: FROM INSIDE 'mainOperations': Entered in case 2: $case2");
      await runCase2Operation();
    } else if (dayCase == case3) {
      // refreshedPage
      print(
          "NOTE CODE 2: FROM INSIDE 'mainOperations': Entered in case 3: $case3");
      await runCase3Operation();
    } else if (dayCase == case4) {
      //returnedToApp
      print(
          "NOTE CODE 2: FROM INSIDE 'mainOperations': Entered in case 4: $case4");
      return await runCase4Operation();
    } else {
      print(
          "ERROR CODE 1: FROM INSIDE 'mainOperations': No case was returned Check for the cases/ process");
      return false;
    }
    print("NOTE CODE 3: FROM INSIDE 'mainOperations': done ...");
    return true;
  }

  runCase1Operation() async {
    // dayFreshStart
    await createNewCollection();
    // this function does:
    // 1- create empty hourSummary
    // 2- store it to database
    // 3- store it to currentHour attribute

    // note: startHour is already saved in DB and storage before passing the case detected
  }

  runCase2Operation() async {
    // dayRestartedAfterEnd
    // note: startHour is already saved from DB to storage before passing the case detected
    print("NOTE CODE 1: FROM INSIDE 'runCase2Operation' function: start... ");

    await reloadPreviousHoursSummariesFromDBorCache(); // we have fetched all summaries created for all previous hours through out the day except for the current hour
    currentCollection = await HourReceiptViewModel().fetchOrGenerateHourSummaryFromDB(
        date: _date,
        collHour:
        _hour); // current hour must be only get from the db server not cached version to ensure up to date operation
    addOrUpdateHourCollectionInMap(_hour,
        currentCollection); // adding the current collection to map for presentation in UI
    int noOfReceipts = currentCollection!.hourReceiptsCount;
    if (noOfReceipts > 0) {
      await storeReceiptsCountOnRestartingDay(
          noOfReceipts); // store the number of receipts made during the last hour to increment over it and generate the next receipt ID if a new receipt is created
    }
    print(
        "NOTE CODE 2: FROM INSIDE 'runCase2Operation' function: end before snackbar... ");

    displaySnackBar(text:
        "تنبيه: تم اعادة فتح اليوم و تحميل كل الفواتير"); // todo: most probably this snackbar will cause problem because it is called in the build
    print(
        "NOTE CODE 3: FROM INSIDE 'runCase2Operation' function: end after snackbar... end");
  }

  runCase3Operation() async {
    // refreshedPage
    print("NOTE CODE 1: FROM INSIDE 'runCase3Operation' function: start... ");

    // 1 - check if still in same day
    bool isInSameDay = checkIfStillInSameDay();

    if (isInSameDay == false) {
      // a new day has started
      print(
          "NOTE CODE 2: FROM INSIDE 'runCase3Operation' function: state is: New day - New Hour: 00 >> action is: change working day to new day");
      await changeWorkingDayToNewDay();
    } else {
      bool isInSameHour = checkIfStillInSameHour();

      if (isInSameHour == false) {
        // a new hour has started
        print(
            "NOTE CODE 3: FROM INSIDE 'runCase3Operation' function: state is: same day - new Hour >> action is: change working hour to new hour");
        await changeWorkingHourToNewHour();
      } else {
        // same day and same hour only need to add the new receipt created to the summary and refresh the screen
        print(
            "NOTE CODE 2: FROM INSIDE 'runCase3Operation' function: state is: same day - same Hour >> action is: update on current hour summary");
        await updateCurrentWorkingHourSummary();
      }
    }if(_hourToUpdate != "-"){
      await updateCurrentWorkingHourSummary(hourInFormat: _hourToUpdate);
      _hourToUpdate = "-";
    }
    print("NOTE CODE 4: FROM INSIDE 'runCase3Operation' function: end... ");
  }

  runCase4Operation() async {
    // returnedToApp
    bool isStillInTheSameDay = await onReEnteringApp();
    return isStillInTheSameDay;
  }

  // * functions serving runCase1Operation() *************

  saveHourCollectionInDB(
      {required String date,
        required String hour,
        required HourlyReceiptCollection hourCollection}) async {
    print(
        "NOTE CODE 1: FROM INSIDE 'saveHourCollectionInDB' function: start... \n date is: $date, hour is: $hour, hourCollection in ${hourCollection.toString()}");

    // this function is used for saving an hour collection at specific date and time
    CollectionReference receiptDBServicesObj =
        ReceiptCollectionServices().userReceiptsCollectionReference;
    Map<String, dynamic>? collSummary;
    try {
      // toMap function is used to convert HourlyReceiptCollection object's data into a Map of String, dynamic (according to the attributes data type)
      collSummary = HourlyReceiptCollection.toMap(hourCollection);
      await receiptDBServicesObj
          .doc(date) // pass date
          .collection(hour) // pass hour
          .doc("Summary")
          .set(collSummary);
    } catch (e) {
      print(
          "ERROR CODE 1: FROM INSIDE 'saveHourCollectionInDB': couldn't save hour collection summary of data \n ${collSummary.toString()} \n for date: $date and hour: $hour in database: \n$e");
    }

    print(
        "NOTE CODE 2: FROM INSIDE 'saveHourCollectionInDB' function: done... ");
  }

  initializeCurrentHourCollectionInMap() {
    print(
        "NOTE CODE 1: FROM INSIDE 'initializeCurrentHourCollectionInMap' function: start... ");

    if (currentCollection != null) {
      overallCollectionsMap[_hour] = currentCollection!;
    } else {
      print(
          "Error CODE 1: FROM INSIDE 'initializeCurrentHourCollectionInMap' function: CURRENT COLLECTION VARIABLE IS EMPTY ! ");
    }
    print(
        "NOTE CODE 1: FROM INSIDE 'initializeCurrentHourCollectionInMap' function: end... ");
  }

  createNewCollection() async {
    print("NOTE CODE 1: FROM INSIDE 'createNewCollection' function: start... ");

    // this function is responsible for initializing new empty current hour summary
    // it is used in cases when we need to create an initial, empty summary
    // for the current hour and store it in the collectionsMap and in the database
    currentCollection = HourReceiptViewModel().initializeEmptyHourCollection(_hour,
        _date); // generate the empty initial summary data and update the currentCollection variable with the generated data
    initializeCurrentHourCollectionInMap(); // put the new hourCollection in the overallCollectionsMap variable for ui presentation
    await saveHourCollectionInDB(
        date: _date,
        hour: _hour,
        hourCollection:
        currentCollection!); // save the new hourCollection in firebase

    print("NOTE CODE 2: FROM INSIDE 'createNewCollection' function: end... ");
  }

  // * end of : functions serving runCase1Operation() **********

  //////////////////////////////////////////////////////////////////////////////////

  // * functions serving runCase2Operation() *************

  Future<void> reloadPreviousHoursSummariesFromDBorCache() async {
    print(
        "NOTE CODE 1: FROM INSIDE 'reloadPreviousHoursSummariesFromCache' function: start... ");

    CollectionReference firebaseFirestore =
        ReceiptCollectionServices().userReceiptsCollectionReference;
    String
    hourInFormat; // to store hour as 01 string after being converted to int during looping

    print(
        "NOTE CODE 2: FROM INSIDE 'reloadPreviousHoursSummariesFromCache' function: Looping is started ");
    for (int h = int.parse(_startHour); h < (int.parse(_hour)); h++) {
      hourInFormat = reformatHourSplitted(h.toString());
      DocumentSnapshot<Map<String, dynamic>>? summaryJSON;

      DocumentReference<Map<String, dynamic>> summaryDoc = firebaseFirestore
          .doc(_date)
          .collection(hourInFormat)
          .doc("Summary"); // reach till the summary document

      try {
        summaryJSON = await summaryDoc.get(const GetOptions(
            source: Source
                .cache)); // get the summary json data from Firebase cached version

        print(
            "NOTE CODE 3: FROM INSIDE 'reloadPreviousHoursSummariesFromCache' function: loop for hour: $hourInFormat: was able to get summary from cache ! ");
      } catch (e) {
        print(
            "ERROR CODE 1: FROM INSIDE 'reloadPreviousHoursSummariesFromCache' function: \n"
                "loop for hour: $hourInFormat: was not able to get summary from cache!... trying to get summary from server (db): \n $e ");
        try {
          summaryJSON = await summaryDoc
              .get(); // get the summary json data from Firebase cloud servers

          print(
              "NOTE CODE 4: FROM INSIDE 'reloadPreviousHoursSummariesFromCache' function: loop for hour: $hourInFormat: was able to get summary from server ! ");
        } catch (e) {
          print(
              "ERROR CODE 1: FROM INSIDE 'reloadPreviousHoursSummariesFromCache' function: \n"
                  "loop for hour: $hourInFormat: was not able to get summary from server! ... creating new summary based on receipts saved in server\n $e ");
        }
      }
      HourlyReceiptCollection summaryCollection;

      // if was able to get the summary collection from cache or db server convert the summaryJson fetched into the correct format (object of HourlyReceiptCollection)
      if (summaryJSON!.data() != null) {
        summaryCollection =
            HourlyReceiptCollection.fromJson(_date, summaryJSON.data()!);
      } else {
        // if was not able to get the summary collection from db, create a new summary according to the receipts existing in the db and save the hour summary in the database
        summaryCollection = await createOrUpdateCurrentHourSummaryInDB(
            hourInFormat: hourInFormat, date: _date);
      }
      // add the hour summary to the overAllCollectionsMap variable for UI display
      addOrUpdateHourCollectionInMap(hourInFormat, summaryCollection);
    }
    print(
        "NOTE CODE 5: FROM INSIDE 'reloadPreviousHoursSummariesFromCache' function: end... ");
  }

  Future<HourlyReceiptCollection> createOrUpdateCurrentHourSummaryInDB(
      {String? hourInFormat, String? date}) async {
    print(
        "NOTE CODE 1: FROM INSIDE 'createOrUpdateCurrentHourSummaryInDB' function: start... ");

    // this function is responsible for creating a new summary according to the receipts existing in the db and save the hour summary in the database
    HourlyReceiptCollection hourCollection = await generateFullHourSummaryData(
        collHour: hourInFormat ?? _hour, date: date ?? _date);
    await saveHourCollectionInDB(
        date: date ?? _date,
        hour: hourInFormat ?? _hour,
        hourCollection: hourCollection);
    print(
        "NOTE CODE 2: FROM INSIDE 'createOrUpdateCurrentHourSummaryInDB' function: end... ");

    return hourCollection;
  }

  Future<Map<String, double>?> getTopAndLeastSoldProductsInHour(
      List<
          QueryDocumentSnapshot<
              Map<String, dynamic>>> // todo : needs to be commented
      receiptsSnapshot) async {
    ReceiptCollectionServices receiptDBServicesObj =
    ReceiptCollectionServices();
    Map<String, double> productsCount = {};
    double minProductCount = 0;
    double maxProductCount = 0;
    String minProductBarCode = "";
    String maxProductBarCode = "";

    if (receiptsSnapshot.isNotEmpty) {
      for (QueryDocumentSnapshot snapshot in receiptsSnapshot) {
        if (snapshot.id != "Summary") {
          List<ProductInReceipt> items = [];
          try {
            items = await receiptDBServicesObj
                .getProductsListFromReceipt(snapshot.get("itemsList"));
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
          for (ProductInReceipt item in items) {
            if (productsCount.containsKey(item.productName)) {
              productsCount[item.productName] =
              (productsCount[item.productName]! + item.productBoughtCount);
            } else {
              productsCount[item.productName] = item.productBoughtCount;
            }
          }
        }
      }

      if (productsCount.isNotEmpty) {
        List<double> counts = productsCount.values.toList();
        minProductCount = counts.reduce(min);
        maxProductCount = counts.reduce(max);

        int minIndex =
        counts.indexWhere((element) => element == minProductCount);
        int maxIndex =
        counts.indexWhere((element) => element == maxProductCount);

        minProductBarCode = productsCount.keys.elementAt(minIndex);
        maxProductBarCode = productsCount.keys.elementAt(maxIndex);
      }
    }
    return {
      minProductBarCode: maxProductCount,
      maxProductBarCode: minProductCount,
    };
  }

  Future<HourlyReceiptCollection> generateFullHourSummaryData(
      {required String collHour, String? date}) async {
    print(
        "NOTE CODE 1: FROM INSIDE 'createOrUpdateCurrentHourSummaryInDB' function: start... ");

    HourlyReceiptCollection hourCollection;

    CollectionReference firebaseFirestore =
        ReceiptCollectionServices().userReceiptsCollectionReference;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> receiptsSnapshots = [];

    double hourTotalProfit = 0.0;
    double hourTotalRevenue = 0.0;
    int hourItemsSoldCount = 0;
    int hourReceiptsCount = 0;
    String topSoldProductBarCode = "";
    String leastProductSoldBarCode = "";
    List<String> productsFinishedFromInventory = [];
    double topSoldProductCount = 0;
    double leastProductSoldCount = 0;

    try {
      receiptsSnapshots = (await firebaseFirestore
          .doc(date ?? _date)
          .collection(collHour)
          .get())
          .docs;

      print(
          "NOTE CODE 2: FROM INSIDE 'generateFullHourSummaryData' function: was able to get receipts from firebase server: \n receipts length/ count is : ${receiptsSnapshots.length}");

      if (receiptsSnapshots.isNotEmpty) {
        Map<String, double>? result = await getTopAndLeastSoldProductsInHour(
            receiptsSnapshots); // this function is responsible for getting the most and least bough items during hour
        if (result != null) {
          topSoldProductBarCode = result.keys.first;
          leastProductSoldBarCode = result.keys.last;
          topSoldProductCount = result.values.first;
          leastProductSoldCount = result.values.last;
        }

        // todo: get products finished from inventory
        // todo: productsFinishedFromInventory = getProductsFinishedFromInventoryDuringHour(collHour);

        for (QueryDocumentSnapshot snapshot in receiptsSnapshots) {
          // looping over receipts to calculate total profit, revenue, items sold count ... etc.
          if (snapshot.id != "Summary") {
            // check if this collection is the summary collection to prevent any unnecessary disturbance/ bugs
            String snapshotProfit = snapshot.get("receiptAfterSaleProfit") == ""
                ? snapshot.get("receiptBeforeSaleProfit")
                : snapshot.get("receiptAfterSaleProfit");
            hourTotalProfit += double.parse(snapshotProfit);
            hourTotalRevenue += double.parse(snapshot.get("receiptRevenue"));
            hourItemsSoldCount += int.parse(snapshot.get("totalProductsSold"));
            hourReceiptsCount += 1;
          }
        }
      }
    } catch (e) {
      print(
          "ERROR CODE 1: FROM INSIDE 'generateFullHourSummaryData' function: could not get receipts from firebase server: \n $e");
    }

    hourCollection = HourlyReceiptCollection(
        amPm: amPmFrom24HrFormat(collHour),
        date: _date,
        time: displayTime12HrFormat(collHour),
        hourItemsSoldCount: hourItemsSoldCount,
        hourReceiptsCount: hourReceiptsCount,
        hourTotalProfit: hourTotalProfit,
        hourTotalRevenue: hourTotalRevenue,
        topSoldProductBarCode: topSoldProductBarCode,
        leastProductSoldBarCode: leastProductSoldBarCode,
        productsFinishedFromInventory: productsFinishedFromInventory,
        topSoldProductCount: topSoldProductCount,
        leastProductSoldCount: leastProductSoldCount);

    print(
        "NOTE CODE 3: FROM INSIDE 'generateFullHourSummaryData' function: done... \n hour collection data is: ${hourCollection.toString()}");

    return hourCollection;
  }

  // * end of : functions serving runCase2Operation() **********

  //////////////////////////////////////////////////////////////////////////////////

  // * functions serving runCase3Operation() *************

  updateCurrentWorkingHourSummary({String? hourInFormat}) async {
    print(
        "NOTE CODE 1: FROM INSIDE 'updateCurrentWorkingHourSummary' function: start... ");

    // tis function is responsible for updating the current working hour summary in database after a new receipt is added
    currentCollection = await createOrUpdateCurrentHourSummaryInDB(
        hourInFormat: hourInFormat?? _hour,
        date:
        _date); // re-calculate the hour summary after adding the new receipt
    addOrUpdateHourCollectionInMap(hourInFormat?? _hour, currentCollection);

    print(
        "NOTE CODE 2: FROM INSIDE 'updateCurrentWorkingHourSummary' function: end... ");
  }
  changeWorkingHourToNewHour() async {
    print(
        "NOTE CODE 1: FROM INSIDE 'changeWorkingHourToNewHour' function: start... ");

    // this function is responsible for changing the working hour if the time
    // changes. It could be called in case 3 or 4, and in either cases there
    // could be time gap of 1 or more hours that must be filled with empty hour
    // summaries or could be a collection that was not updated when the receipt
    // was created.

    String currentHour = reformatHourSplitted(DateTime.now().hour.toString());
    _hour = currentHour;
    await createEmptySummariesForInBetweenHours(); // this only creates the in-between summaries but doesn't load them into the collections map because it might add the collections in wrong order
    await reloadPreviousHoursSummariesFromDBorCache(); // loads hour summaries into the collections map (most probably be from cache)
    await updateCurrentWorkingHourSummary();
    print(
        "NOTE CODE 2: FROM INSIDE 'changeWorkingHourToNewHour' function: end... ");
  }

  changeWorkingDayToNewDay() async {
    print(
        "NOTE CODE 1: FROM INSIDE 'changeWorkingDayToNewDay' function: start... ");

    // this function is used in cases where the hour goes past 12 am and a new day is started.
    // the old day must be ended correctly first, update the vm variables,
    // store the start hour correctly in both the firebase and storage,
    // then create the new hour summary after saving the created receipt and display it in the UI.

    await endDay(); // ensures the day summary is created and all hour summaries are created
    await HiveDatabaseManager
        .backUpUserInventoryProducts(); // backup the user inventory
    await startDay(); // reset/ initialize the VM variables
    await storeDayStartHour_toStorageAndDB(); // store the startHour
    await updateCurrentWorkingHourSummary(); // create the first hour summary and add it to the collections map for display

    print(
        "NOTE CODE 2: FROM INSIDE 'changeWorkingDayToNewDay' function: end... ");
  }

  createEmptySummariesForInBetweenHours() async {
    print(
        "NOTE CODE 1: FROM INSIDE 'createEmptySummariesForInBetweenHours' function: start... ");
    // this function is responsible for creating the summaries for in between hours and  storing them in the database, if there is a gap between the currentWorkingHour stored in storage and the DateTime.now().hour

    String previouslyWorkingHour = (await fetchCurrentWorkingHour()) ??
        _hour; // fetch stored workingHour from storage

    print(
        "NOTE CODE 2: FROM INSIDE 'createEmptySummariesForInBetweenHours' function: Important Data:  ");
    print("previous Working Hour from storage: $previouslyWorkingHour");
    print("previous hour is: $previouslyWorkingHour");
    print("current hour is: $_hour");

    if (_hour != previouslyWorkingHour) {
      print("now is not the same hour");

      if (int.parse(previouslyWorkingHour) + 1 == int.parse(_hour)) {
        // this is the direct next hour: storedHour is 00, currentHour is 01
        await createOrUpdateCurrentHourSummaryInDB(
            hourInFormat: previouslyWorkingHour, date: _date);

        await setCurrentWorkingHour(_hour);
      } else if (int.parse(_hour) > int.parse(previouslyWorkingHour) + 1) {
        // this is not the direct next hour but another further hour: storedHour is 00, currentHour is 02 or 05 ..
        for (int h = int.parse(previouslyWorkingHour);
        h < int.parse(_hour);
        h++) {
          String hourInFormat = reformatHourSplitted(h.toString());
          print("hour in loop is: $hourInFormat");
          await createOrUpdateCurrentHourSummaryInDB(
              hourInFormat: hourInFormat);
        }

        await setCurrentWorkingHour(_hour);
      }
    }
    print(
        "NOTE CODE 3: FROM INSIDE 'createEmptySummariesForInBetweenHours' function: end... ");
  } // also serving case 4

  bool checkIfStillInSameDay() {
    bool isInSameDay = true;

    int nowDay = DateTime.now().day;
    int vmDay = int.parse(_day);

    if (nowDay != vmDay) {
      isInSameDay = false;
    }
    return isInSameDay; // returns false if day is changed, returns true if the day didn't change
  }

  bool checkIfStillInSameHour() {
    bool isInSameHour = true;

    int nowHour = DateTime.now().hour;
    int vmHour = int.parse(_hour);

    if (nowHour != vmHour) {
      isInSameHour = false;
    }
    return isInSameHour; // returns false if day is changed, returns true if the day didn't change
  }

  endDay() async {
    print("NOTE CODE 1: FROM INSIDE 'endDay' function: start... ");

    // this function is responsible for ending the day, ensuring all hour
    // summaries during the day are created and the full
    // day summary is created as well

    await ensureAllSummariesExistBeforeDayEnd(); // this includes all hours summaries and the day summary it self
    print(
        "NOTE CODE 2: FROM INSIDE 'endDay' function: .done creating day summary ");

    clearVMVars(); // reset all todayVM variables

    // 4- clear _startHour and currentWorkingHour and receiptsCount from memory
    await resetStartDayHour();
    await resetCurrentWorkingHour();
    await clearReceiptsCount();
    print(
        "NOTE CODE 3: FROM INSIDE 'endDay' function: .done clearing storage: _startHour and currentWorkingHour and receiptsCount ");

    StartDayProvider.setDayStarted(false);
    print(
        "NOTE CODE 4: FROM INSIDE 'endDay' function: .done converting dayStartTrigger to false ");

    print("NOTE CODE 5: FROM INSIDE 'endDay' function: end... ");
  }

  // * end of : functions serving runCase3Operation() **********

  //////////////////////////////////////////////////////////////////////////////////

  // * functions serving runCase4Operation() *************

  Future<bool> onReEnteringApp() async {
    print("NOTE CODE 1: FROM INSIDE 'onReEnteringApp' function: start... ");

    bool isStillInTheSameDay =
    await checkIfStillInSameDayThroughFBStartHourVariable();

    if (isStillInTheSameDay == true) {
      await createEmptySummariesForInBetweenHours();

      await reloadPreviousHoursSummariesFromDBorCache();
      currentCollection = await HourReceiptViewModel()
          .fetchOrGenerateHourSummaryFromDB(date: _date, collHour: _hour);

      addOrUpdateHourCollectionInMap(_hour, currentCollection);
    } else {
      await HiveDatabaseManager.backUpUserInventoryProducts();
      await setVMVarsAsYesterday();
      await endDay();
      await startDay();
      await storeDayStartHour_toStorageAndDB();
      await createNewCollection();
      await saveHourCollectionInDB(
          date: _date, hour: _hour, hourCollection: currentCollection!);
    }

    print("NOTE CODE 1: FROM INSIDE 'onReEnteringApp' function: end... ");
    return isStillInTheSameDay;
  }

  // General Common Functions -----------------------------------------------

  addOrUpdateHourCollectionInMap(
      String collHour, HourlyReceiptCollection? updatedHourColl) {
    // called if any old receipt in previous hour is updated
    // or if added new receipt
    if (updatedHourColl != null) {
      overallCollectionsMap[collHour] = updatedHourColl;
    } else {
      print(
          "BY HAND ERROR: HOUR=$collHour COLLECTION VARIABLE IS EMPTY !!!!!!!");
    }
  }

  // Creating New Collection ---------------------------------------------------

  updateHourCollectionSummaryInDB({String? hour}) async {
    // updates only specific fields in the hour//Summary document in the database based on the receipt created
    // fields to be updated are:
    //--------------------------
    // hourItemsSoldCount
    // hourReceiptsCount
    // hourTotalProfit
    // hourTotalRevenue
    // todo
  } // todo

  updateWholeHourCollectionSummaryInDB({String? hour}) async {
    // updates products and sale process related fields in the hour//Summary document in the database after the hour ends or the day is ended

    // fields to be updated are:
    //--------------------------
    // hourItemsSoldCount
    // hourReceiptsCount
    // hourTotalProfit
    // hourTotalRevenue
    // leastProductSoldBarCode
    // leastProductSoldCount
    // productsFinishedFromInventory
    // topSoldProductBarCode
    // topSoldProductCount

    // todo
  } // todo

  TEMP_createSummariesForAllHoursDuringDay() async {
    for (int h = int.parse(_startHour); h <= (int.parse(_hour)); h++) {
      print("hour in loop is: $h");
      String hourInFormat = reformatHourSplitted(h.toString());
      await createOrUpdateCurrentHourSummaryInDB(hourInFormat: hourInFormat);
    }
  }

  createWholeDaySummaryInDB() async {
    print("inside storeDaySummaryInDB");
    CollectionReference firebaseFirestore =
        ReceiptCollectionServices().userReceiptsCollectionReference;

    Map<String, dynamic> daySummaryMap =
    await prepareDaySummaryData(_date, _startHour, _hour);

    try {
      await firebaseFirestore
          .doc(_date)
          .set(daySummaryMap)
          .then((value) => displaySnackBar(text:"تم حفظ عمليات اليوم بنجاح"));
    } catch (e) {
      print("Day summary was not saved in database: $e");
    }
  }

  Future<Map<String, dynamic>> prepareDaySummaryData(
      String date, String startHour, String endHour) async {
    CollectionReference firebaseFirestore =
        ReceiptCollectionServices().userReceiptsCollectionReference;

    double numberOfProductsSold = 0;
    int numberOfReceiptsMade = 0;
    double totalDayProfit = 0.0;
    double totalDayRevenue = 0.0;
    String topSoldProductBarCode = "";
    List<String> productsFinishedFromInventory = [];
    String leastProductSoldBarCode = "";
    double topSoldProductCount = 0;
    double leastSoldProductCount = 0;

    Map<String, double> topSoldProducts = {};
    Map<String, double> leastSoldProducts = {};

    for (int h = int.parse(startHour); h <= int.parse(endHour); h++) {
      await firebaseFirestore
          .doc(date)
          .collection(reformatHourSplitted(h.toString()))
          .doc("Summary")
          .get()
      // .get(const GetOptions(source: Source.cache))
          .then((value) {
        totalDayProfit += value.get("hourTotalProfit");
        totalDayRevenue += value.get("hourTotalRevenue");
        numberOfProductsSold +=
            int.parse(value.get("hourItemsSoldCount").toString());
        numberOfReceiptsMade +=
            int.parse(value.get("hourReceiptsCount").toString());
        print("****");
        print("****");
        print(
            "Number Of Receipts Made after hour ${reformatHourSplitted(h.toString())} is $numberOfReceiptsMade");
        print("****");
        print("****");

        List<String> result = List.castFrom<dynamic, String>(
            value.get("productsFinishedFromInventory"));
        productsFinishedFromInventory.addAll(result);

        String hourTopProd = value.get("topSoldProductBarCode");
        print(value.get("topSoldProductCount"));
        double hourTopProdCount = value.get("topSoldProductCount");
        if (topSoldProducts.containsKey(hourTopProd)) {
          topSoldProducts[hourTopProd] =
              topSoldProducts[hourTopProd]! + hourTopProdCount;
        } else {
          topSoldProducts[hourTopProd] = hourTopProdCount;
        }

        String hourLeastProd = value.get("leastProductSoldBarCode");
        double hourLeastProdCount = value.get("leastProductSoldCount");
        if (leastSoldProducts.containsKey(hourLeastProd)) {
          leastSoldProducts[hourLeastProd] =
              leastSoldProducts[hourLeastProd]! + hourLeastProdCount;
        } else {
          leastSoldProducts[hourLeastProd] = hourLeastProdCount;
        }

        //totalDayProfit += value.get("hourTotalProfit");
      });
    }

    if (leastSoldProducts.isNotEmpty) {
      leastSoldProductCount = leastSoldProducts.values.reduce(min);

      int leastIndex = leastSoldProducts.values
          .toList()
          .indexWhere((element) => element == leastSoldProductCount);
      //.firstWhere((element) => element == leastSoldProductCount);
      print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
      print(leastSoldProducts.values);
      print(leastIndex);
      print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
      leastProductSoldBarCode = leastSoldProducts.keys.elementAt(leastIndex);
    }

    if (topSoldProducts.isNotEmpty) {
      topSoldProductCount = topSoldProducts.values.reduce(max);

      int mostIndex = topSoldProducts.values
          .toList()
          .indexWhere((element) => element == topSoldProductCount);
      //.firstWhere((element) => element == topSoldProductCount);

      topSoldProductBarCode = topSoldProducts.keys.elementAt(mostIndex);
    }

    String topBarCode;
    if (topSoldProductBarCode != "") {
      topBarCode = (await userInvServices
          .searchUserInventoryByProductNameOrBarCode(topSoldProductBarCode))
          .first
          .barCode;
    } else {
      topBarCode = topSoldProductBarCode;
    }

    String leastBarCode;
    if (leastProductSoldBarCode != "") {
      leastBarCode =
          (await userInvServices.searchUserInventoryByProductNameOrBarCode(
              leastProductSoldBarCode))
              .first
              .barCode;
    } else {
      leastBarCode = leastProductSoldBarCode;
    }

    print("day start hour before saving is: $_startHour");
    Map<String, dynamic> daySummaryMap = {
      "startHour": _startHour,
      "numberOfProductsSold": numberOfProductsSold,
      "numberOfReceiptsMade": numberOfReceiptsMade,
      "totalDayProfit": totalDayProfit,
      "totalDayRevenue": totalDayRevenue,
      "topSoldProductBarCode": topBarCode, //topSoldProductBarCode,
      "leastProductSoldBarCode": leastBarCode, //leastProductSoldBarCode,
      "topSoldProductCount": topSoldProductCount,
      "leastSoldProductCount": leastSoldProductCount,
      "productsFinishedFromInventory": productsFinishedFromInventory,
    };

    return daySummaryMap;
  }

  Future<bool> checkIfStillInSameDayThroughFBStartHourVariable() async {
    String hourFetchedFromDB = await checkForStartHourInDB();

    if (hourFetchedFromDB == "-1") {
      return false;
    } else {
      return true;
    }
  }

  clearVMVars() {
    _date = "";
    _day = "";
    _month = "";
    _year = "";
    _hour = "";
    _startHour = "-1";

    overallCollectionsMap.clear();
    currentCollection = null;
    allowReceiptCreation = false;
    print("after clearing all vm info");
  }

  ensureAllSummariesExistBeforeDayEnd() async {
    print("inside end day");
    // 1- create lastHour Summary
    print("started creating hour summaries");
    await TEMP_createSummariesForAllHoursDuringDay();
    print("finished creating hour summaries");

    //await storeHourSummaryInDB();
    print("started creating day summary");
    await createWholeDaySummaryInDB();
  }

  storeStartHourInDB() async {
    CollectionReference firebaseFirestore =
        ReceiptCollectionServices().userReceiptsCollectionReference;

    try {
      await firebaseFirestore.doc(_date).set({"startHour": _hour});
    } catch (e) {
      print("problem getting startHour: $e");
    }
  }

  startDay() async {
    // Called Alone when "ابتدي اليوم" button is pressed
    // 1- set dayStarted Trigger to true
    await StartDayProvider.setDayStarted(true);
    // 2- initialize the timer

    initializeVMVars();
    print("before initializing timer");
    // todo await initializeBackgroundTimer();
    print("after initializing timer");
  }

  storeDayStartHour_toStorageAndDB() async {
    _startHour =
        _hour; // since we are just starting the day, currentHour is tthe same as the startHour
    await setStartDayHour(_startHour); // storing startHour to storage
    await setCurrentWorkingHour(_hour); // storing currentWorkingHour to storage
    await storeStartHourInDB(); // store startHour to database
  }

  storeDayStartHourFetchedFromDB_toStorage(
      {required String startHourFromDB}) async {
    _startHour = startHourFromDB;
    await setStartDayHour(_startHour); // storing startHour to storage
    await setCurrentWorkingHour(_hour); // storing currentWorkingHour to storage
  }

  initializeVMVars() {
    DateTime now = DateTime.now();
    _day = now.day.toString();
    _month = now.month.toString();
    _year = now.year.toString();
    _hour = reformatHourSplitted(now.hour.toString());
    _date = reformatDateSplittedToCombined(_day, _month, _year);
  }

  setVMVarsAsYesterday() async {
    print("inside setVM");
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    _day = yesterday.day.toString();
    _month = yesterday.month.toString();
    _year = yesterday.year.toString();
    String? fetchedHour = (await fetchCurrentWorkingHour());
    _hour = (fetchedHour == null || fetchedHour == "" || fetchedHour == " ")
        ? "23"
        : fetchedHour;
    _date = reformatDateSplittedToCombined(_day, _month, _year);
    print("the hour is:");
    print(_hour);
    CollectionReference firebaseFirestore =
        ReceiptCollectionServices().userReceiptsCollectionReference;

    try {
      _startHour = await firebaseFirestore
          .doc(_date)
          .get()
      //.get(const GetOptions(source: Source.cache))
          .then((value) => value.get("startHour"));
      print("the start hour is: ");
      print(_startHour);
    } catch (e) {
      print("couldn't fetch start hour of yesterday from cache: $e");
      try {
        _startHour = await firebaseFirestore
            .doc(_date)
            .get()
            .then((value) => value.get("startHour"));
      } catch (e) {
        print("couldn't fetch start hour of yesterday from database: $e");
        _startHour = "00";
      }
    }
    print("end");
  }
}
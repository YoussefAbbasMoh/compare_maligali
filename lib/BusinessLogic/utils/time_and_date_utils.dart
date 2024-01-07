import 'enums.dart';

String convertTimeStringTo24Hr(String time, String amPm) {
  int hour = int.parse(time.split(":")[0]);
  bool after12pm = amPm == "م";
  String time24;
  if (hour == 12) {
    if ((after12pm)) {
      time24 = hour.toString();
    } else {
      time24 = (hour - 12).toString();
    }
  } else {
    time24 =
        (int.parse(time.split(":")[0]) + ((amPm == "م") ? 12 : 0)).toString();
  }

  if (time24.length == 1) {
    time24 = "0" + time24;
  }

  return time24;
}

String reformatToAcceptableDateTimeFormat(String date) {
  final dateSplit = date.split("-");
  return dateSplit[2] + "-" + dateSplit[1] + "-" + dateSplit[0];
}

String getNowDate() {
  DateTime now = DateTime.now();
  return reformatDateSplittedToCombined(
      now.day.toString(), now.month.toString(), now.year.toString());
}

String getNowTime(){
  DateTime now = DateTime.now();
  return now.hour.toString()+":"+now.minute.toString();
}

String getNowHour() {
  DateTime now = DateTime.now();
  return now.hour.toString();
}

String reformatDateSplittedToCombined(String day, String month, String year) {
  if (day.length == 1) {
    day = "0" + day;
  }
  if (month.length == 1) {
    month = "0" + month;
  }
  return day + "-" + month + "-" + year;
}

String reformatTimeSplittedToCombined(String hour, String min) {
  if (hour.length == 1) {
    hour = "0" + hour;
  }
  if (min.length == 1) {
    min = "0" + min;
  }
  return hour + ":" + min;
}

String reformatHourSplitted(String hour) {
  // convert from 1 to 01
  if (hour.length == 1) {
    hour = "0" + hour;
  }
  return hour;
}

String amPmFrom24HrFormat(String hour) {
  if (int.parse(hour) < 12) {
    return "ص";
  } else {
    return "م";
  }
}

String displayTime12HrFormat(String hour24Format) {
  int hour = int.parse(hour24Format);
  if (hour > 12) {
    hour -= 12;
  }
  if (hour == 0) {
    hour = 12;
  }

  return hour.toString() + ":00";
}

String getTimeStringFromDouble(double secValTot) {
  if (secValTot < 0) return 'Invalid Value';
  int minVal = secValTot ~/ 60;
  int secVal = (secValTot - minVal * 60).toInt();
  return '$minVal'.padLeft(2, "0") + ':' + '$secVal'.padLeft(2, "0");
}

List<String> getPastThreeMonthsInArabic(DateTime firstDate) {
  List<String> pastMonths = [];
  pastMonths.add(arabicMonths[firstDate.month] ?? "الشهر\n ده");
  pastMonths.add(
      arabicMonths[firstDate.subtract(const Duration(days: 30)).month] ??
          "الشهر \nاللي فات");
  pastMonths.add(
      arabicMonths[firstDate.subtract(const Duration(days: 60)).month] ??
          "الشهر \nاللي قبله");

  return pastMonths;
}

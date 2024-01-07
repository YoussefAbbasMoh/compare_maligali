import 'package:charts_flutter/flutter.dart' as charts;

class BarChartModel {
  String day;
  int profit;
  final charts.Color color;

  BarChartModel({
    required this.day,
    required this.profit,
    required this.color,
  });
}

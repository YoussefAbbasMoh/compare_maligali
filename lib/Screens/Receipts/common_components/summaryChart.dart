import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../BusinessLogic/Models/barChartModel.dart';
import '../../../constants.dart';
import 'package:flutter/material.dart';

class SummaryChart extends StatelessWidget {
  final List<BarChartModel>? data;

  const SummaryChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
          id: "summary",
          data: data!,
          domainFn: (BarChartModel series, _) => series.day,
          measureFn: (BarChartModel series, _) => series.profit,
          colorFn: (BarChartModel series, _) => series.color,
          labelAccessorFn: (BarChartModel series, _) => '${series.profit}')
    ];

    return Container(
      decoration: BoxDecoration(
        color: purplePrimaryColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        border: Border.all(
          width: 3,
          color: purplePrimaryColor,
          style: BorderStyle.solid,
        ),
      ),
      height: 350.h,
      padding: const EdgeInsets.all(20).w,
      child: Card(
        color: purplePrimaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0).w,
          child: Column(
            children: <Widget>[
              Expanded(
                child: charts.BarChart(
                  series.reversed.toList(),
                  animate: false,
                  vertical: true,
                  defaultRenderer: charts.BarRendererConfig(
                      cornerStrategy: const charts.ConstCornerStrategy(10)),
                  barRendererDecorator: charts.BarLabelDecorator<String>(),
                  domainAxis: charts.OrdinalAxisSpec(
                      renderSpec: charts.SmallTickRendererSpec(
                          minimumPaddingBetweenLabelsPx: 5.w.round(),
                          labelStyle: const charts.TextStyleSpec(
                              fontSize: 12,
                              color: charts.MaterialPalette.white),
                          lineStyle: const charts.LineStyleSpec(
                              color: charts.MaterialPalette.white))),
                  primaryMeasureAxis: const charts.NumericAxisSpec(
                      renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                              fontSize: 18,
                              color: charts.MaterialPalette.white),
                          lineStyle: charts.LineStyleSpec(
                              color: charts.MaterialPalette.white))),
                ),
              ),
              SizedBox(height: 10.h),
              const Text(
                "مقارنة بسيطة بين الشهر / المكسب",
                style: TextStyle(color: textWhite),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

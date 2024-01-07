import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants.dart';

/*this displays a rectangler widget that shows a summary of receipts created during a certain hour
it shows:
- total revenue from receipts sold in that hour
- total profit from receipts sold in that hour
- number of receipts sold in that hour
- number of items sold in that hour

it also has customizable on tap function that that runs the function passed to it as a paramater when it is pressed

***********all these values are not calculated inside here, they are just passed as strings


 */
class ReceiptsSummaryPerHourWidget extends StatelessWidget {
  final String revenue;
  final String totalSalesProfit;
  final String itemsCount;
  final String receiptsCount;
  final void Function()? onTap;

  const ReceiptsSummaryPerHourWidget(
      {required this.revenue,
      required this.totalSalesProfit,
      required this.itemsCount,
      required this.receiptsCount,
       this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /////////////////revenue///////////////////////////////
                  Text(
                    ":المكسب ",
                    style: TextStyle(
                        fontWeight: commonTextWeight,
                        fontSize: commonTextSize.sp,
                        color: darkBlue),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    "$revenue ج",
                    style: TextStyle(
                        fontWeight: commonTextWeight,
                        fontSize: commonTextSize.sp,
                        color: darkBlue),
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: authGradient3,
              thickness: 1.w,
              indent: 0.1 * 0.05.h,
              endIndent: 0.16 * 0.05.h,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    ///////////////////////profit//////////////////////////////
                    Text(
                      ":المبيعات    ",
                      style:
                          TextStyle(fontSize: tinyTextSize.sp, color: darkBlue),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      " $totalSalesProfit",
                      style:
                          TextStyle(fontSize: tinyTextSize.sp, color: darkBlue),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      " ج ",
                      style:
                          TextStyle(fontSize: tinyTextSize.sp, color: darkBlue),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    //////////////////////////////itemCount//////////////////////////
                    Text(
                      ":المنتجات المباعه  ",
                      style:
                          TextStyle(fontSize: tinyTextSize.sp, color: darkBlue),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      itemsCount,
                      style:
                          TextStyle(fontSize: tinyTextSize.sp, color: darkBlue),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    ///////////////////////number of receipts//////////////////////////
                    Text(
                      ":عدد الفواتير  ",
                      style:
                          TextStyle(fontSize: tinyTextSize.sp, color: darkBlue),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      receiptsCount,
                      style:
                          TextStyle(fontSize: tinyTextSize.sp, color: darkBlue),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ]),
      ///////////////customizable on tap function////////////////////////
      onTap: onTap,
    );
  }
}

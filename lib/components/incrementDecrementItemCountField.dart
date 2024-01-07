import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class ItemCountField extends StatelessWidget {
  final Color iconColor = darkGreen;
  final Color backgroundColor = lightGreyButtons;
  TextEditingController counterController = TextEditingController(text: "0");
  bool preventChecking = false;

  final number = ValueNotifier(0.0);

  double getCount() {
    if (counterController.text.isEmpty) {
      counterController.text = "0";
    }

    return double.parse(counterController.value.text);
  }

  ItemCountField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (counterController.text.isEmpty) {
      counterController.text = "0";
    }
    return ValueListenableBuilder<double>(
        valueListenable: number,
        builder: (context, value, child) {
          return SizedBox(
            width: 270.w,
            child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0).w),
                selected: true,
                selectedTileColor: backgroundColor,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: iconColor,
                        borderRadius: BorderRadius.circular(50).w,
                      ),
                      child: IconButton(
                        iconSize: 35.w,
                        icon: const Icon(
                          Icons.remove,
                        ),
                        color: textWhite,
                        onPressed: () {
                          double count =
                              double.parse(counterController.value.text);
                          if (count > 0) {
                            preventChecking = true;
                            counterController.text = (count - 1).toString();
                            number.value--;
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50.w,
                      height: 50.h,
                      child: TextField(
                        onChanged: (count) {
                          double res = 0.0;
                          if (count != "") {
                            res = double.parse(count);
                          }
                          number.value = res;
                        },
                        controller: counterController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: (counterController.value.text == "0")
                                ? darkRed
                                : Colors.blueAccent,
                            fontSize: commonTextSize.sp,
                            fontWeight: commonTextWeight),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: iconColor,
                        borderRadius: BorderRadius.circular(50).w,
                      ),
                      child: IconButton(
                        iconSize: 35.w,
                        icon: const Icon(Icons.add),
                        color: textWhite,
                        onPressed: () {
                          int count = int.parse(counterController.value.text);
                          preventChecking = true;

                          counterController.text = (count + 1).toString();
                          number.value++;
                        },
                      ),
                    ),
                  ],
                )),
          );
        });
  }
}

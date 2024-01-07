import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../constants.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final Color bgColor;
  final double padding;
  final Color gradient1;
  final Color gradient2;
  final Color gradient3;
  final Color gradient4;
  final Color gradient5;
  final double containerWidth;
  final double topLeftBorder;
  final double topRightBorder;
  final double bottomLeftBorder;
  final double bottomRightBorder;
  final double topLeftContainerBorder;
  final double topRightContainerBorder;
  final double bottomLeftContainerBorder;
  final double bottomRightContainerBorder;

  const GradientContainer({
    required Key? key,
    this.child = const Text("Empty"),
    this.padding = 1.0,
    required this.width,
    this.bgColor = purpleContainerColor,
    this.gradient1 = const Color(0xFF71FAE1),
    this.gradient2 = const Color(0xFFDE61AE),
    this.gradient3 = const Color(0xFFC8F5ED),
    this.gradient4 = const Color(0xFFC987AA),
    this.gradient5 = const Color(0xFFF6EAA2),
    this.containerWidth = 0,
    this.topLeftBorder = 20.0,
    this.topRightBorder = 20.0,
    this.bottomLeftBorder = 20.0,
    this.bottomRightBorder = 20.0,
    this.topLeftContainerBorder = 20.0,
    this.topRightContainerBorder = 20.0,
    this.bottomLeftContainerBorder = 20.0,
    this.bottomRightContainerBorder = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
                topLeft: Radius.circular(topLeftContainerBorder),
                topRight: Radius.circular(topRightContainerBorder),
                bottomLeft: Radius.circular(bottomLeftContainerBorder),
                bottomRight: Radius.circular(bottomRightContainerBorder))
            .w,
        gradient: LinearGradient(
          colors: [gradient1, gradient2, gradient3, gradient4, gradient5],
          stops: [0.15.w, 0.25.w, 0.7.w, 0.8.w, 0.95.w],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Padding(
        // this padding is for the border size
        padding: EdgeInsets.all(padding).w,
        child: Container(
          width: 50.w,
          child: child,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: textWhite),
            borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(topLeftBorder),
                    topRight: Radius.circular(topRightBorder),
                    bottomLeft: Radius.circular(bottomLeftBorder),
                    bottomRight: Radius.circular(bottomRightBorder))
                .w,
          ),
        ),
      ),
    );
  }
}

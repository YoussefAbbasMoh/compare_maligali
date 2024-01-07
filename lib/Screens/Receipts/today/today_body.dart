import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/Screens/Receipts/today/components/receipts_summary_per_hour_listview.dart';
import 'package:maligali/components/subscription_bundle_finished_pop_up.dart';
import 'package:provider/provider.dart';
import '../../../BusinessLogic/view_models/receipts_view_models/today_view_models/start_day_provider.dart';
import '../../../BusinessLogic/view_models/receipts_view_models/today_view_models/today_page_view_model.dart';
import '../../../BusinessLogic/view_models/subscriptions_view_model.dart';
import '../../../components/buttons.dart';
import '../../../constants.dart';
import 'sub_screens/new_receipt/newReceipt.dart';
import 'sub_screens/today_summary/todaySummary.dart';
/*actual entry point of the application after signup/login
this body is a part of the tab bar view of the homescreen that allows the user to switch between it and previous body
this body has two main variations, dayStartedBody and dayNotStartedBody
they operates as follows:-
-(dayNotStartedBody) when the user opens the application, he has an option to "start the day" if he has not already , when he clicks it the body is changed (dayStartedBody)

-(dayStartedBody) shows small summaries of all receipts created from selling operations during this day grouped by hour and if a summary is clicked the user is directed to ReceiptsDuringHourScreen that shows all receipts made during that specific hour that the user clicked 
on its summary, the user also is preseneted with a plus button that directs him to NewReceiptScreen which allows him to start a new selling process and create a new receipt for it , a button called "end the day" is also presented, when it is click the user is directed to TodaySummaryScreen where he can see a summary of what he has
done in this day and allows him to succesfully end the day and save all his progress ********Note : when the user clicks on "start the day", before we create the body of an empty new day, we first check if he has any receipts that coresspond to the day we are currently on, if 
he does then we preload those receipts into the body instead of displaying an empty one
 */

class TodayBody extends StatefulWidget {
  const TodayBody({Key? key}) : super(key: key);

  @override
  State<TodayBody> createState() => _TodayBodyState();
}

class _TodayBodyState extends State<TodayBody> {
  @override
  Widget build(BuildContext context) {
    return StartDayProvider
            .dayStarted //check if the user has already started the day
        ? SafeArea(
            child: dayStartedBody(context), /////body to display if the user started the day
          )
        : dayNotStartedBody(context); /////body to display if the user has not
  }

////////////////////////////////
  Widget dayStartedBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            /////////////////widget responsible for viewing summaries of all receipts made on this day in a vertical list goruped by hour/////////////////
            child: const ReceiptsSummaryPerHourListView()),
        ////////////////////end day button//////////////////////
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20).w,
                child: DefaultButton(
                  text: "انهاء اليوم",
                  height: 45.h,
                  width: 130.w,
                  fontSize: subFontSize.sp,
                  fontWeight: subFontWeight,
                  onPressed: () async {
                    //when clicked
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: ((context) => const Center(
                              child: CircularProgressIndicator(),

                              ///show loading indicator
                            )));
                    await Provider.of<TodayPageViewModel>(context,
                            listen: false)
                        .ensureAllSummariesExistBeforeDayEnd(); /////make sure all receipts made on that day are saved correctly in their respective hour summaries on firestore before proceeding
                    setState(() {});
                    Navigator.of(context).pop(); //remove loading indicator
                    Navigator.pushNamed(
                        context,
                        TodaySummary
                            .routeName); //direct the user to TodaySummaryScreen to see a summary of what he has done and to confirm ending the day and saving everythin
                  },
                ),
              ),
              ////////////////////////////////////////////


              ////////////////////////////////////create a new receipt button////////////////////////////
              Padding(
                padding: const EdgeInsets.only(right: 20).w,
                child: ElevatedButton(
                  child: Center(
                      //icon of the button
                      child: Icon(Icons.add,
                          color: textWhite,
                          size: MediaQuery.of(context).size.height * 0.066)),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    primary:
                        TodayPageViewModel.allowReceiptCreation
                            ? redTextAlert
                            : darkGreen,
                    fixedSize: Size.fromRadius(
                        MediaQuery.of(context).size.height * 0.036),
                    alignment: Alignment.center,
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero.w,
                  ), /////when button is pressed////////
                  onPressed: () async {
                    //check if the user subscription hasn't ended (he can create new receipts or not)
                    bool subscriptionState = await SubscriptionsViewModel().allowReceiptUsage();

                    if (subscriptionState == true) {
                      //if the users subscription is active
                      await Navigator.pushNamed(
                          context,
                          NewReceipt
                              .routeName); //navigate to create a new receipt screen
                    } else {
                      //if the user subscription has ended
                      showDialog(
                          context: context,
                          builder: (context) {
                            return subscriptionBundleFinishedPopup(
                                context); //show subscription ended popup
                          });
                    }
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

/////body to show if the user has not started the day yet
  Widget dayNotStartedBody(BuildContext context) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.3,
          left: 10,
          bottom: 8,
          right: 10,
        ).r,
        child: Align(
            alignment: Alignment.bottomCenter,
            ///////////////start day button////////////////////
            child: DefaultButton(
              height: MediaQuery.of(context).size.height * 0.09,
              width: MediaQuery.of(context).size.width * 0.8,
              bgColor: darkRed,
              text: "ابتدي فواتير النهاردة",
              onPressed: () async {
                //when pressed
                await Provider.of<TodayPageViewModel>(context,
                        listen: false)
                    .startDay(); //set day started
                setState(() {}); //refresh the screen
              },
            )),
      ),
    ]);
  }
}

import 'package:maligali/BusinessLogic/Services/NotificationServices/firebase_messaging_services.dart';
import 'package:maligali/components/returnAppBar.dart';
import 'package:maligali/scaffoldComponents/GeneralScaffold.dart';
import '../../BusinessLogic/view_models/notifications_view_model.dart';
import 'package:maligali/BusinessLogic/Models/notification_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

/* This screen is responsible for allowing the user to view all the notifications previosuly sent to him by the 
application in a list that is ordered by newest on top we have 2 soruces of notifications 

Inventory notifications : these notifications are sent and controlled by NotificationsViewModel (like a product running out , inconcistency in inventory and sold products , etc...)

firebase notifications : these notifications are sent and controlled by FBMessagingServices (this service allows us to directly send a message as a developer to the user that will appear as a notification)


 */

class NotificationScreen extends StatefulWidget {
  static String routeName =
      "/NotificationScreen"; // route name used for this page by navigator
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    FBMessagingServices().getToken();

    if (SchedulerBinding.instance?.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance?.addPostFrameCallback((_) => Provider.of<
              NotificationsViewModel>(context, listen: false)
          .setBadgeNotifier(
              false)); //used to controll showing the red dot besides the ntofications on the dropdown bar of the users phone when a notfication is sent to him
    }
  }

  @override
  Widget build(BuildContext context) {
    ///////////////////////////////////////////////
    ///appbar///
    return GeneralScaffold(
        backGroundColor: white2BG,
        appBar: ReturnAppBar(
          onPressed: () {
            NotificationsViewModel().setBadgeNotifier(
                false); //used to controll showing the red dot besides the ntofications on the dropdown bar of the users phone when a notfication is sent to him
            Navigator.pop(context);
          },
          iconColor: textBlack,
          key: null,
          pageTitle: "اشعارات المخزن",
          preferredSize: Size.fromHeight(40.h),
        ),
        curentPage: NotificationScreen.routeName,
        ///////////////////////////////////////////////////
        ///body///
        body: FutureBuilder<List<NotificationModel>>(
            future: NotificationsViewModel()
                .readNotificationsFromMemory(), // read inventory notifications that has been sent and stored in viewmodel in order to show for the user in a single collection
            builder: (context, notificationsSnapshot) {
              // when loading is complete
              if (notificationsSnapshot.connectionState ==
                  ConnectionState.done) {
                //if there are notifications to show
                if (notificationsSnapshot.data!.isNotEmpty) {
                  // show the notifications
                  return mainContainer(notificationsSnapshot
                      .data!); //notifications list container
                  //if there are no notifications
                } else if (notificationsSnapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      //show empty notifications widget
                      "مفيش اشعارات",
                      style: TextStyle(
                          fontSize: mainFontSize.sp,
                          fontWeight: mainFontWeight),
                    ),
                  );
                }
              } else if (notificationsSnapshot.hasError) {
                //if an error occured
                return Center(
                  child: Text(
                    //show wrror widget
                    "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                    style: TextStyle(
                        fontSize: commonTextSize.sp,
                        fontWeight: commonTextWeight),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }

  ////////////////////////////////////////////////////////////
  ///this widget is a container for the list of notifications that has been sent to the user
  Widget mainContainer(List<NotificationModel> notifs) {
    return Container(
      margin: const EdgeInsets.all(10).w,
      height: 650.h,
      width: 340.w,
      decoration: BoxDecoration(
        color: textWhite,
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ).w,
        boxShadow: [
          BoxShadow(
            color: lightGreyReceiptBG,
            spreadRadius: 5.r,
            blurRadius: 7.r,
          ),
        ],
      ),
      child: notificationsListView(notifs), //notification list view
    );
  }

  //notification list view
  notificationsListView(List<NotificationModel> notifs) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: notifs.length,
      itemBuilder: (context, index) {
        NotificationModel notif =
            notifs[index]; // for each single notifcation in the list
        return ListTile(
          //show an icon to the left
          trailing: const Icon(
            Icons.notifications_active,
            color: redTextAlert,
          ),
          title: Text(
            //show name and date of the notfication
            notif.notificationTitle + "     " + notif.notificationDate,
            textDirection: TextDirection.rtl,
            style: TextStyle(
                fontSize: tinyTextSize.sp, fontWeight: tinyTextWeight),
          ),
          subtitle: Text(
            //show text content / body of the notification
            notif.notificationBody,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 13.sp),
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(
        //separator line between each notification
        color: darkGreen,
        indent: 15.w,
        endIndent: 15.w,
      ),
    );
  }
}

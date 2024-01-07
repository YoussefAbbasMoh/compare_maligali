import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/BusinessLogic/Models/store_owner_model.dart';
import 'package:maligali/BusinessLogic/view_models/receipts_view_models/today_view_models/today_page_view_model.dart';
import 'package:provider/provider.dart';
import '../BusinessLogic/view_models/authentication_view_models/authentication_view_model.dart';
import '../BusinessLogic/Services/NotificationServices/firebase_messaging_services.dart';
import '../BusinessLogic/utils/globalSnackBar.dart';
import '../BusinessLogic/view_models/inventory_view_models/add_to_user_inventory_view_model.dart';
import '../BusinessLogic/view_models/inventory_view_models/inventory_page_view_model.dart';
import '../BusinessLogic/view_models/mhalatko_orders_view_models/orders_view_model.dart';
import '../BusinessLogic/view_models/notifications_view_model.dart';
import '../BusinessLogic/view_models/receipts_view_models/common_receipt_view_models/hour_view_model.dart';
import '../BusinessLogic/view_models/receipts_view_models/common_receipt_view_models/receipt_view_model.dart';
import '../BusinessLogic/view_models/receipts_view_models/previous_day_view_models/previous_day_page_view_model.dart';
import '../BusinessLogic/view_models/update_user_info.dart';
import '../root.dart';
import '../routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FBMessagingServices().initListenToMessages();
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return FutureBuilder(builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('تعذر تحميل التطبيق'),
              );
            } else {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (context) {
                    return TodayPageViewModel();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return AuthenticationServices();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return UpdateUserInfoViewModel();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return PreviousDayPageViewModel();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return ReceiptViewModel();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return InventoryPageVM();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return AddToUserInvVM();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return NotificationsViewModel();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return StoreOwner();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return HourReceiptViewModel();
                  }),
                  ChangeNotifierProvider(create: (context) {
                    return OrdersViewModel();
                  }),
                ],
                child: MaterialApp(

                  scaffoldMessengerKey: scaffoldMessengerKey,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate
                  ],
                  initialRoute: Root.routeName,
                  routes: routes,
                  theme: ThemeData(fontFamily: 'Changa'),
                  debugShowCheckedModeBanner: false,
                ),
              );
            }
          });
        });
  }
}

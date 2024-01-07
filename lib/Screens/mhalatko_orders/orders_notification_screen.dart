import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/BusinessLogic/utils/globalSnackBar.dart';
import 'package:maligali/Screens/mhalatko_orders/old_orders.dart';
import 'package:maligali/components/buttons.dart';
import 'package:provider/provider.dart';
import '../../BusinessLogic/Models/mhalatko_order_models/order_model.dart';
import '../../BusinessLogic/view_models/mhalatko_orders_view_models/orders_view_model.dart';
import '../../components/returnAppBar.dart';
import '../../constants.dart';
import '../../scaffoldComponents/GeneralScaffold.dart';
import '../Receipts/common_components/custom_app_bar.dart';
import 'new_orders.dart';
import 'order_detail_screen.dart';

class OrdersNotificationsScreen extends StatefulWidget {
  static String routeName = "/OrdersNotificationsScreen";

  const OrdersNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<OrdersNotificationsScreen> createState() =>
      _OrdersNotificationsScreenState();
}

class _OrdersNotificationsScreenState extends State<OrdersNotificationsScreen>
    with SingleTickerProviderStateMixin  {
  late OrdersViewModel ordersVM;
  late final TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    ordersVM = Provider.of<OrdersViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
      backGroundColor: white2BG,
      appBar: ReturnAppBar(
        key: null,
        iconColor: textBlack,
        preferredSize: Size.fromHeight(80.h),
        pageTitle: "طلبيات محلاتكو",
        bottom: DefaultTabController(
          length: 2,
          //////////////////tab bar used to switch between bodies//////////////
          child: TabBar(
            controller: _tabController,
            unselectedLabelColor: purplePrimaryColor,
            labelColor: purplePrimaryColor,
            indicatorColor: purplePrimaryColor,
            labelStyle: TextStyle(
                fontSize: commonTextSize.sp,
                fontWeight: commonTextWeight), //For Selected tab
            unselectedLabelStyle: TextStyle(
                fontSize: commonTextSize.sp, fontWeight: commonTextWeight),
            indicatorSize: TabBarIndicatorSize.label,

            tabs: [
              SizedBox(
                  height: 40.h,
                  child:
                  const Tab(text: "طلبات جديد")), ///////////first tab title
              SizedBox(
                  height: 40.h,
                  child: const Tab(
                      text: "طلبات قديمة")), /////////////second tab title
            ],
          ),
        ),
      ),
      curentPage: OrdersNotificationsScreen.routeName,
      body: TabBarView(
        controller: _tabController,
        children: const [
          SingleChildScrollView(
              child: NewOrders()), ///////////first tab actual code body
          SingleChildScrollView(
              child: OldOrders()), ///////////second tab actual code body
        ],
      ),

    );
  }

}

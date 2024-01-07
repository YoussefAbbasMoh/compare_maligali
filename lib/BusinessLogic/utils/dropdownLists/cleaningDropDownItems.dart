import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/dropDownBox.dart';
import '../../../constants.dart';

List<Item> cleaningSectionNameList = <Item>[
  Item(
      "selfCare",
      "التجميل والعناية الشخصية".trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "Bathroom",
      'منظفات حمام'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "walls",
      'منظفات حوائط'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("floor",
      'منظفات ارضيات'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("clothes",
      'منظفات ملابس'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "plates",
      'منظفات اطباق'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "sparkles",
      'ملمعات'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "wood",
      'منظفات اخشاب'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "deodorants",
      'روائح عطرية'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("kitchen",
      'ادوات مطبخ'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("other",
      'اخري'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
];

// List<Item> cleaningPurchaseUnitList = <Item>[
//   const Item(
//       "kilo",
//       "كيلو",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "litre",
//       "لتر",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "carton",
//       "كرتونة",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "piece",
//       "قطعة",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "box",
//       "علبة",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "packet",
//       "بكتة",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "bala",
//       "بالة",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "pack",
//       "قاروصة",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "ribbon",
//       "شريط",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "sheet",
//       "حصيرة",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "shrink",
//       "شرنك",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
// ];
//
// List<Item> cleaningSaleUnitList = <Item>[
//   const Item(
//       "kilo",
//       "كيلو",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "gram",
//       "جرام",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "litre",
//       "لتر",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "piece",
//       "قطعة",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "pack",
//       "كيس",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "box",
//       "علبة",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "bottle",
//       "زجاجة",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "roll",
//       "رول",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "spray",
//       "سبراي",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
// ];

Map<String, String> cleaningSectionsBarCodes = {
  "التجميل والعناية الشخصية".trim(): "364",
  "منظفات حمام".trim(): "537",
  "منظفات حوائط".trim(): "160",
  "منظفات ارضيات".trim(): "144",
  "منظفات ملابس".trim(): "123",
  "منظفات اطباق".trim(): "177",
  "ملمعات".trim(): "098",
  "منظفات اخشاب".trim(): "094",
  "روائح عطرية".trim(): "066",
  "ادوات مطبخ".trim(): "046",
  "اخري".trim(): "014",
};
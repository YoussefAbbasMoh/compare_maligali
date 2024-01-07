import 'package:flutter/material.dart';
import '../../../components/dropDownBox.dart';
import '../../../constants.dart';

List<Item> stationarySectionNameList = <Item>[
  Item(
      "papersAndCopybooks",
      'ورق وكراريس'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "paperbackBooks",
      'كتب خارجية'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "stationary",
      "ادوات مكتبية".trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("artTools",
      'ادوات فنية'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("engineeringTools",
      'ادوات هندسية'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "electronicSupplies",
      'اجهزة'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),

  Item(
      "presents",
      'هدايا'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "toys",
      'العاب'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "services",
      "خدمات".trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("foodSupplies",
      'ادوات الطعام المدرسية'.trim(),
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
//
// List<Item> stationaryPurchaseUnitList = <Item>[
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
//       "packet",
//       "بكتة",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "dozen",
//       "دستة",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "roll",
//       "رول",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "sheet",
//       "فرخ",
//       Icon(
//         Icons.shopping_basket_rounded,
//         color: purplePrimaryColor,
//       )),
// ];
//
// List<Item> stationarySaleUnitList = <Item>[
//
//   const Item(
//       "piece",
//       "قطعة",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),   const Item(
//       "unit",
//       "وحدة",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),  const Item(
//       "meter",
//       "متر",
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
//       "packet",
//       "باكت",
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

Map<String, String> stationarySectionsBarCodes = {
  'ورق وكراريس'.trim(): "537",
  'كتب خارجية'.trim(): "160",
  "ادوات مكتبية".trim(): "144",
  'ادوات فنية'.trim(): "123",
  'ادوات هندسية'.trim(): "177",
  'اجهزة'.trim(): "098",
  'هدايا'.trim(): "094",
  'العاب'.trim(): "066",
  "خدمات".trim(): "046",
  'ادوات الطعام المدرسية'.trim(): "234",
  'اخري'.trim(): "224",
};



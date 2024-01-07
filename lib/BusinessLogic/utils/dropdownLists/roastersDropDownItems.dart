import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/dropDownBox.dart';
import '../../../constants.dart';

List<Item> roastersSectionNameList = <Item>[
  Item(
      "services",
      'خدمات'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "roasters",
      'التسالي'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "sweets",
      'الحلويات'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "beverage",
      'مياه غازيه/عصائر'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "hotDrinks",
      'المشروبات'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "cans",
      'المعلبات'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("sauces",
      "الصوصات".trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("cigarettes",
      'السجائر'.trim(),
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

// List<Item> roastersPurchaseUnitList = <Item>[
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
//       "cup",
//       "كوب",
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
// List<Item> roastersSaleUnitList = <Item>[
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
//       "can",
//       "كانز",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "cup",
//       "كوب",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "plasticEgg",
//       "بيضة",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
//   const Item(
//       "cone",
//       "كون",
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
// ];

Map<String, String> roastersSectionsBarCodes = {
  "خدمات".trim(): "723",
  "التسالي".trim(): "371",
  "ياميش ومكسرات".trim():"547",
  "الحلويات".trim(): "624",
  "مياه غازيه/عصائر".trim(): "237",
  "المشروبات".trim(): "160",
  "المعلبات".trim(): "098",
  "الصوصات".trim(): "094",
  "السجائر".trim(): "039",
  "اخري".trim(): "014",
};
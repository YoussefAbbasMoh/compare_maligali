import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/dropDownBox.dart';
import '../../../constants.dart';

List<Item> grocerySectionNameList = <Item>[
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
  Item("makeup",
      'التجميل'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("cleaning",
      'منظفات المنزل	'.trim(),
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
      "groceries",
      'البقالة'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "eggAndCheese",
      'بيض و جبن	'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("dairies",
      'الألبان'.trim(),
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
      'العطاره و الصوصات'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item(
      "oils",
      'الزيوت/الزبده	'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("frozen",
      'المجمدات'.trim(),
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
  Item("cereals",
      'رقائق'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("beans",
      'البقوليات'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("bread",
      'المخبوزات'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("organic",
      'خضروات و فواكة'.trim(),
      const Icon(
        Icons.shopping_cart_sharp,
        color: purplePrimaryColor,
      )),
  Item("pickles",
      'مخللات'.trim(),
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

// List<Item> groceryPurchaseUnitList = <Item>[
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
// List<Item> grocerySaleUnitList = <Item>[
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
//   const Item(
//       "spray",
//       "سبراي",
//       Icon(
//         Icons.shopify_rounded,
//         color: purplePrimaryColor,
//       )),
// ];

Map<String, String> grocerySectionsBarCodes = {
  "خدمات".trim(): "751",
  "الحلويات".trim(): "624",
  "التجميل".trim(): "364",
  "منظفات المنزل".trim(): "289",
  "مياه غازيه/عصائر".trim(): "237",
  "المشروبات".trim(): "160",
  "البقالة".trim(): "144",
  "بيض و جبن".trim(): "123",
  "الألبان".trim(): "177",
  "المعلبات".trim(): "098",
  "العطاره و الصوصات".trim(): "094",
  "الزيوت/الزبده".trim(): "066",
  "المجمدات".trim(): "046",
  "السجائر".trim(): "039",
  "رقائق".trim(): "021",
  "البقوليات".trim(): "019",
  "المخبوزات".trim(): "017",
  "مخللات".trim(): "010",
  "خضروات و فواكة".trim(): "003",
  "اخري".trim(): "014",
};
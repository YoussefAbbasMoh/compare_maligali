import 'dart:ui';

class ItemFinishedInInventory {
  final Image itemImage;
  final int itemCountNeeded;
  final String itemName;

  ItemFinishedInInventory(
      {required this.itemImage,
      required this.itemCountNeeded,
      required this.itemName});
}

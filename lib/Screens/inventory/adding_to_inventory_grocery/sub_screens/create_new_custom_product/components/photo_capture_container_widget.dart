import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../../../../constants.dart';
import 'dart:io';

import '../../../../../../BusinessLogic/view_models/inventory_view_models/add_to_user_inventory_view_model.dart';

/*this widget is responsible for taking a photo for the user to set as product photo WHEN IT IS CLICKED as well as showing the photo of the product afterwards*/
class PhotoCaptureContainer extends StatefulWidget {
  PhotoCaptureContainer({Key? key}) : super(key: key);

  File? _itemPhotoCaptured; //file that stores the photo when it is taken

  //getters for the photo location and file
  getPhotoPath() => _itemPhotoCaptured!.path;
  getPhotoFile() => _itemPhotoCaptured;

  @override
  State<PhotoCaptureContainer> createState() => _PhotoCaptureContainerState();
}

class _PhotoCaptureContainerState extends State<PhotoCaptureContainer> {
  //flag for determing when to activate the container to take and show a photo
  bool _activate = false;

  @override
  Widget build(BuildContext context) {
    return _activate //if the container should be activated
        ? Consumer<AddToUserInvVM>(builder: (context, addToInvVM, child) {
            return FutureBuilder<XFile?>(
                future:
                    addToInvVM.captureImgFromCamera(), //attempt to take a photo
                builder: (context, imagePathSnapshot) {
                  if (imagePathSnapshot.connectionState ==
                      ConnectionState.done) {
                    ////////////////////////////////
                    if (imagePathSnapshot.hasError) {
                      //if photo couldn't be taken properly
                      _activate = false;
                      return Center(
                        child: Text(
                          "حصل مشكلة في التصوير",
                          style: TextStyle(
                              fontSize: commonTextSize.sp,
                              fontWeight: commonTextWeight),
                        ),
                      );
                      ///////////////////////////
                    } else if (imagePathSnapshot.hasData) {
                      //if photo was taken but could be saved properly
                      if (imagePathSnapshot.data!.path == "unknown") {
                        return Center(
                          child: Text(
                            "حصل مشكلة في حفظ الصورة",
                            style: TextStyle(
                                fontSize: commonTextSize.sp,
                                fontWeight: commonTextWeight),
                          ),
                        );
                      }
                      //////////////////////////////
                      else {
                        //if photo was taken and saved properly
                        widget._itemPhotoCaptured =
                            File(imagePathSnapshot.data!.path); //show the photo
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _activate =
                                  true; //take a new photo if the container is touched again
                            });
                          },
                          child: SizedBox(
                              width: 150.w,
                              height: 230.h,
                              child: Image.file(widget._itemPhotoCaptured!,
                                  fit: BoxFit.cover,
                                  width: 150.w,
                                  height: 230.h)),
                        );
                      }
                    }
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
          })
        ///////////////////////////////////
        ///default container to display if no photo has been captured
        : InkWell(
            onTap: () {
              setState(() {
                // the photo taking functionality is activated when the container is pressed
                _activate = true;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 15).r,
              child: Container(
                color: lightGreyButtons2,
                width: 150.w,
                height: 230.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/camera.png'),
                    Text(
                      "صور صوره واضحة للمنتج",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: tinyTextSize.sp),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

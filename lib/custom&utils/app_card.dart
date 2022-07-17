import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../generated/assets.dart';
import '../model/card_model.dart';

class AppCard extends StatelessWidget {
  final AppCardModel cardData;
  final void Function(AppCardModel cardData) onTap;

  const AppCard({
    Key? key,
    required this.cardData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onLongPress: () async {
        if (cardData.isDeleteAble) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Remove this app from list?",
                  style: Theme.of(context).textTheme.headline6,
                ),
                content: Text(
                  "Press confirm to remove this item.",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await cardData.delete();
                      Fluttertoast.showToast(
                        msg: "App Successfully Deleted",
                        backgroundColor: Theme.of(context).primaryColor,
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT,
                      );
                      Get.back();
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              );
            },
          );
        }
      },
      onTap: () => onTap(cardData),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            if (cardData.backgroundImage != null)
              Container(
                height: 350.0,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(cardData.backgroundImage!),
                  ),
                ),
              ),
            Container(
              height: 350.0,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  cardData.backgroundImage != null ? 0.9 : 1.0,
                ),
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: cardData.gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            if (!(cardData.assetIcon != null &&
                (cardData.assetIcon == Assets.imagesAvatar ||
                    cardData.assetIcon == Assets.imagesShibburnText)))
              Positioned(
                bottom: 0,
                left: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: cardData.assetIcon != null
                      ? cardData.assetIcon!.endsWith(".svg")
                          ? SvgPicture.asset(
                              cardData.assetIcon!,
                              width: 64,
                              height: 90,
                              color: Colors.white,
                              fit: BoxFit.fill,
                            )
                          : Image.asset(
                              cardData.assetIcon!,
                              height: 72,
                              width: 90,
                              color: Colors.white,
                              fit: BoxFit.fill,
                            )
                      : cardData.fileIcon!.endsWith(".svg")
                          ? SvgPicture.file(
                              File(cardData.fileIcon!),
                              width: 64,
                              height: 90,
                              color: Colors.white,
                              fit: BoxFit.fill,
                            )
                          : Image.file(
                              File(cardData.fileIcon!),
                              width: 64,
                              height: 90,
                              color: Colors.white,
                              fit: BoxFit.fill,
                            ),
                ),
              ),
            Container(
              height: 350,
              width: 200,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!(cardData.title == "shibburn"))
                        Text(
                          cardData.title,
                          style: theme.textTheme.headline5
                              ?.copyWith(color: Colors.white),
                        ),
                      cardData.assetIcon != null
                          ? cardData.assetIcon!.endsWith(".svg")
                              ? SvgPicture.asset(
                                  cardData.assetIcon!,
                                  width: 32,
                                  height: 32,
                                  color: Colors.white,
                                )
                              : Image.asset(
                                  cardData.assetIcon!,
                                  height: cardData.assetIcon ==
                                          Assets.imagesShibburnText
                                      ? 24
                                      : 32,
                                  width: cardData.assetIcon ==
                                          Assets.imagesShibburnText
                                      ? null
                                      : 32,
                                )
                          : cardData.fileIcon!.endsWith(".svg")
                              ? SvgPicture.file(
                                  File(cardData.fileIcon!),
                                  width: 32,
                                  height: 32,
                                )
                              : Image.file(
                                  File(cardData.fileIcon!),
                                  width: 32,
                                  height: 32,
                                )
                    ],
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  Text(
                    "Time used this week",
                    style: theme.textTheme.bodyText2?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTimeString(cardData.timeUsedMinutes),
                        style: theme.textTheme.headline5?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SvgPicture.asset(Assets.iconsEye)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTimeString(int timeUsedMinutes) {
    final hours = timeUsedMinutes ~/ 60;
    final minutes = timeUsedMinutes % 60;
    return "$hours Hours $minutes min";
  }
}

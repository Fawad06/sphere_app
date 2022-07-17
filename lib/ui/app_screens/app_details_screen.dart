import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppDetailsScreen extends StatefulWidget {
  static String id = "appdetailsscreen";

  const AppDetailsScreen({Key? key}) : super(key: key);

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  late final String url;
  late final Timer timer;
  late final Timer timer2;
  late WebViewController controller;
  int time = 0;
  int previousScrollValue = 0;
  double appBarHeight = 60;

  @override
  void initState() {
    url = Get.arguments;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      time = timer.tick;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    height: appBarHeight,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            controller.goBack();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            controller.goForward();
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: Theme.of(context).primaryColor),
                          onPressed: () {
                            timer.cancel();
                            timer2.cancel();
                            Get.back(result: time);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.home_filled,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              Text(
                                "Home",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                  width: MediaQuery.of(context).size.width,
                  child: WebView(
                    gestureRecognizers: Set()
                      ..add(Factory<OneSequenceGestureRecognizer>(() {
                        return EagerGestureRecognizer();
                      })),
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: url,
                    onWebViewCreated: (controller) {
                      this.controller = controller;
                      timer2 = Timer.periodic(const Duration(milliseconds: 500),
                          (timer) {
                        controller.getScrollY().then((value) {
                          setState(() {
                            if (previousScrollValue > value) {
                              appBarHeight = 60;
                            } else if (previousScrollValue < value) {
                              appBarHeight = 0;
                            }
                            previousScrollValue = value;
                          });
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

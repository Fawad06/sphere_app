import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vector_math/vector_math.dart' as vmath;

import '../generated/assets.dart';
import '../main.dart';

class MyBottomNavBar extends StatefulWidget {
  final bool showNavButton;
  final List<MyBottomNavBarItem> items;
  final List<BottomNavBarSubItem>? subItems;
  final Color backgroundColor;
  final bool shadow;
  final BorderRadius? borderRadius;
  final bool showNavArrows;
  final double elevation;
  final double bottomBarHeight;
  final EdgeInsets? padding;
  final BannerAd? bannerAd;
  final void Function(int index)? onTap;
  final void Function(Future<void> Function() handleOverlayCallBack)
      onScrollOverlayCallBack;
  final void Function(void Function(bool isScrollingDown) handleSizeCallBack)
      onScrollSizeCallBack;
  const MyBottomNavBar({
    Key? key,
    required this.items,
    this.backgroundColor = Colors.white,
    this.showNavButton = false,
    this.borderRadius,
    this.elevation = 4,
    this.shadow = false,
    this.onTap,
    this.showNavArrows = false,
    this.padding,
    this.subItems,
    this.bottomBarHeight = 92,
    required this.onScrollOverlayCallBack,
    this.bannerAd,
    required this.onScrollSizeCallBack,
  })  : assert(showNavButton ? subItems != null : true,
            "If Nav button is enabled, there must be at least one item."),
        assert(items.length >= 2, "There must be at least two tabs"),
        assert(showNavButton ? items.length % 2 == 0 : true,
            "Items should be in even quantity if Nav button is to be shown."),
        super(key: key);
  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  double bottomBarHeight = 92;
  late final List<MyBottomNavBarItem> itemsWithMiddleButtonAdded;

  @override
  void initState() {
    widget.onScrollSizeCallBack(handleScrolling);
    itemsWithMiddleButtonAdded = widget.items;
    itemsWithMiddleButtonAdded.insert(
      widget.items.length ~/ 2,
      MyBottomNavBarItem(icon: Icons.key),
    );
    super.initState();
  }

  void handleScrolling(bool isScrollingDown) {
    if (isScrollingDown && bottomBarHeight != 0) {
      setState(() {
        bottomBarHeight = 0;
      });
    } else if (!isScrollingDown && bottomBarHeight != widget.bottomBarHeight) {
      setState(() {
        bottomBarHeight = widget.bottomBarHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.bottomBarHeight + 50,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuart,
            child: Container(
              height:
                  bottomBarHeight == 0 ? bottomBarHeight : bottomBarHeight - 15,
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
                boxShadow: widget.shadow
                    ? [
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 6,
                        )
                      ]
                    : null,
              ),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.showNavArrows
                        ? buildArrowButton(() {
                            setState(() {
                              minusIndexValue();
                            });
                          }, Icons.arrow_back_ios_rounded)
                        : const SizedBox.shrink(),
                    ...(widget.showNavButton
                        ? itemsWithMiddleButtonAdded
                            .asMap()
                            .entries
                            .map((e) => _MyBottomNavBarItemWidget(
                                isActive: e.key == selectedIndex,
                                item: e.value,
                                onTap: () {
                                  //if not middle item then react else not
                                  if (e.key !=
                                      itemsWithMiddleButtonAdded.length ~/ 2) {
                                    setState(() {
                                      if (widget.onTap != null) {
                                        if (e.key >
                                            itemsWithMiddleButtonAdded.length ~/
                                                2) {
                                          widget.onTap!(e.key - 1);
                                        } else {
                                          widget.onTap!(e.key);
                                        }
                                      }
                                      selectedIndex = e.key;
                                    });
                                  }
                                }))
                            .toList()
                        : widget.items
                            .asMap()
                            .entries
                            .map((e) => _MyBottomNavBarItemWidget(
                                isActive: e.key == selectedIndex,
                                item: e.value,
                                onTap: () {
                                  //react on every tap as no additional item is added
                                  setState(() {
                                    if (widget.onTap != null) {
                                      widget.onTap!(e.key);
                                    }
                                    selectedIndex = e.key;
                                  });
                                }))
                            .toList()),
                    widget.showNavArrows
                        ? buildArrowButton(() {
                            setState(() {
                              plusIndexValue();
                            });
                          }, Icons.arrow_forward_ios_rounded)
                        : const SizedBox.shrink(),
                  ]),
            ),
          ),
          if (widget.bannerAd != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuart,
              bottom:
                  bottomBarHeight == 0 ? bottomBarHeight : bottomBarHeight - 15,
              child: Center(
                child: SizedBox(
                  height: widget.bannerAd!.size.height.toDouble(),
                  width: widget.bannerAd!.size.width.toDouble(),
                  child: AdWidget(ad: widget.bannerAd!),
                ),
              ),
            ),
          if (widget.showNavButton)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuart,
              top: bottomBarHeight == 0 ? 200 : 50,
              child: _CenterNavigationButton(
                items: widget.subItems!,
                icon: SvgPicture.asset(
                  Assets.iconsRefresh,
                  width: 28,
                  height: 28,
                  color: Colors.white,
                ),
                onScrollCallBack: (handleOverlayCallback) {
                  widget.onScrollOverlayCallBack(handleOverlayCallback);
                },
              ),
            ),
        ],
      ),
    );
  }

  void minusIndexValue() {
    ///minus only if next answer is in range
    if (selectedIndex > 0 && widget.showNavButton) {
      if (selectedIndex - 1 > itemsWithMiddleButtonAdded.length ~/ 2) {
        //if next tab is on right side of middle item
        selectedIndex--;
        if (widget.onTap != null) widget.onTap!(selectedIndex - 1);
      } else if (selectedIndex - 1 == itemsWithMiddleButtonAdded.length ~/ 2) {
        //if next tab is the middle item
        selectedIndex -= 2;
        if (widget.onTap != null) widget.onTap!(selectedIndex);
      } else {
        //if next tab is on left side of middle item
        selectedIndex--;
        if (widget.onTap != null) widget.onTap!(selectedIndex);
      }
    } else if (selectedIndex > 0 && !widget.showNavButton) {
      //if there is not middle item added
      selectedIndex--;
      if (widget.onTap != null) widget.onTap!(selectedIndex);
    }
  }

  void plusIndexValue() {
    ///minus only if next answer is in range
    if (widget.showNavButton &&
        selectedIndex < itemsWithMiddleButtonAdded.length - 1) {
      //if next tab is on right side of middle item
      if (selectedIndex + 1 > itemsWithMiddleButtonAdded.length ~/ 2) {
        selectedIndex++;
        if (widget.onTap != null) widget.onTap!(selectedIndex - 1);
      } else if (selectedIndex + 1 == itemsWithMiddleButtonAdded.length ~/ 2) {
        //if next tab is middle item
        selectedIndex += 2;
        if (widget.onTap != null) widget.onTap!(selectedIndex - 1);
      } else {
        //if next tab is on left side of middle item
        selectedIndex++;
        if (widget.onTap != null) widget.onTap!(selectedIndex);
      }
    } else if (!widget.showNavButton &&
        selectedIndex < widget.items.length - 1) {
      //if now middle item was added
      selectedIndex++;
      if (widget.onTap != null) widget.onTap!(selectedIndex);
    }
  }

  Material buildArrowButton(VoidCallback onTap, IconData arrow) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color:
                itemsWithMiddleButtonAdded.first.activeColor?.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            arrow,
            size: 16,
            color: itemsWithMiddleButtonAdded.first.activeColor,
          ),
        ),
      ),
    );
  }
}

class MyBottomNavBarItem {
  final IconData icon;
  final Color? activeColor;
  final Color? inActiveColor;

  MyBottomNavBarItem({
    required this.icon,
    this.activeColor = Colors.white,
    this.inActiveColor = Colors.grey,
  });
}

class BottomNavBarSubItem {
  final Widget widget;
  final Function() onTap;

  BottomNavBarSubItem({required this.widget, required this.onTap});
}

class _CenterNavigationButton extends StatefulWidget {
  final Widget icon;
  final List<BottomNavBarSubItem> items;
  final void Function(Future<void> Function() handleOverlayCallback)
      onScrollCallBack;

  const _CenterNavigationButton({
    Key? key,
    required this.icon,
    required this.items,
    required this.onScrollCallBack,
  }) : super(key: key);

  @override
  State<_CenterNavigationButton> createState() =>
      _CenterNavigationButtonState();
}

class _CenterNavigationButtonState extends State<_CenterNavigationButton>
    with TickerProviderStateMixin, RouteAware {
  bool _overlayPresent = false;
  late final AnimationController controller;
  late OverlayEntry entry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver is the global variable we created before
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    widget.onScrollCallBack(_handleScrolling);
    super.initState();
  }

  @override
  void didPushNext() {
    if (_overlayPresent) {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleOverlay,
          child: Container(
            constraints: BoxConstraints.loose(const Size(60, 60)),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff3E64DA),
            ),
            child: Center(
              child: RotationTransition(
                child: widget.icon,
                turns: Tween(begin: 0.0, end: -3 / 8).animate(
                  CurvedAnimation(
                    parent: controller,
                    curve: Curves.easeOutQuart,
                    reverseCurve: Curves.easeInQuart,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleScrolling() async {
    if (_overlayPresent) {
      await _handleOverlay();
    }
  }

  Future<void> _handleOverlay() async {
    if (!_overlayPresent) {
      _addOverlay();
    } else if (_overlayPresent) {
      _removeOverlay();
    }
  }

  void _addOverlay() {
    _insertOverlay(); //it wont insert overlay if one is already present
    _overlayPresent = true;
    controller.forward();
  }

  void _removeOverlay() async {
    _overlayPresent = false;
    await controller.reverse();
    entry.remove();
  }

  void _insertOverlay() {
    final Animation<double> rotation;
    final Animation<double> translation;
    final Animation<double> scale;

    final angleDifference = 180 ~/ (widget.items.length + 1);
    translation = Tween<double>(
      begin: 0.0,
      end: 100.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInQuart,
      ),
    );
    rotation = Tween<double>(
      begin: 60,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInQuart,
      ),
    );
    scale = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInQuart,
      ),
    );
    entry = OverlayEntry(
      builder: (context) {
        return Align(
          alignment: const Alignment(0, 0.9),
          child: SizedBox(
            height: 200,
            width: double.maxFinite,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: widget.items.asMap().entries.map((widgetEntry) {
                final angleRad =
                    vmath.radians(-angleDifference * (widgetEntry.key + 1));
                //if widget goes out of parent by transforming...gestures wont work
                return AnimatedBuilder(
                    animation: controller,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _removeOverlay();
                        widgetEntry.value.onTap();
                      },
                      child: widgetEntry.value.widget,
                    ),
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: vmath.radians(rotation.value),
                        child: Transform.scale(
                          scale: scale.value,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..translate(
                                translation.value * cos(angleRad),
                                translation.value * sin(angleRad),
                              ),
                            child: child,
                          ),
                        ),
                      );
                    });
              }).toList(),
            ),
          ),
        );
      },
    );
    if (!Overlay.of(context)!.widget.initialEntries.contains(entry)) {
      Overlay.of(context)?.insert(entry);
    }
  }
}

class _MyBottomNavBarItemWidget extends StatelessWidget {
  final bool isActive;
  final Function() onTap;
  final MyBottomNavBarItem item;

  const _MyBottomNavBarItemWidget({
    Key? key,
    required this.onTap,
    required this.isActive,
    required this.item,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 60,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          item.icon,
          size: isActive ? 32 : 22,
          color: isActive ? item.activeColor : item.inActiveColor,
        ),
      ),
    );
  }
}

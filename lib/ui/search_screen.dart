import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sphere_app/model/card_model.dart';

import '../custom&utils/app_card.dart';

class SearchScreen extends StatefulWidget {
  static String id = "searchscreen";

  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchTerm = "";
  List<AppCardModel> filteredItems = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (searchTerm != "") {
      searchItems(searchTerm);
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        title: TextField(
          autofocus: true,
          onChanged: (value) {
            setState(() {
              searchTerm = value;
            });
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            filled: true,
            hintText: "Search...",
            fillColor: theme.colorScheme.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Icon(
                Icons.search,
                color: theme.iconTheme.color,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 30),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: searchTerm.isNotEmpty
                      ? filteredItems.length
                      : cardsData.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final AppCardModel cardData = searchTerm.isNotEmpty
                        ? filteredItems[index]
                        : cardsData[index];
                    return AppCard(
                      cardData: cardData,
                      onTap: (AppCardModel cardData) async {
                        if (cardData.screenRouteNamed != null) {
                          final int timeSpentInSeconds = await Get.toNamed(
                            cardData.screenRouteNamed!,
                            arguments: cardData.webUrl!,
                          );
                          cardData.timeUsedMinutes = cardData.timeUsedMinutes +
                              (timeSpentInSeconds ~/ 60);
                          cardData.lastUsed = DateTime.now();
                          await cardData.save();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void searchItems(String searchTerm) {
    filteredItems = cardsData.where((element) {
      return element.title.toLowerCase().contains(searchTerm.toLowerCase());
    }).toList();
  }
}

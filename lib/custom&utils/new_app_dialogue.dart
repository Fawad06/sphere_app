import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sphere_app/custom&utils/strings.dart';
import 'package:sphere_app/custom&utils/themes.dart';

import '../model/card_model.dart';
import '../ui/app_screens/app_details_screen.dart';

class NewAppDialogue extends StatefulWidget {
  const NewAppDialogue({Key? key}) : super(key: key);

  @override
  State<NewAppDialogue> createState() => _NewAppDialogueState();
}

class _NewAppDialogueState extends State<NewAppDialogue> {
  String webName = "";
  String webUrl = "";
  Color color1 = Colors.lightBlueAccent;
  Color color2 = Colors.blue;
  Color pickerColor = Colors.white;
  String? icon;
  final _formKey = GlobalKey<FormState>();
  String? iconError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        "Enter a new App's Details",
        style: theme.textTheme.headline6,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                onChanged: (value) {
                  webName = value;
                },
                validator: (value) =>
                    value == null || value.length < 3 ? "Too short..." : null,
                decoration: const InputDecoration(
                  labelText: "Website Name",
                  hintText: "Facebook, youtube, google etc",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  webUrl = value;
                },
                validator: (value) =>
                    value == null || value.length < 3 ? "Too short..." : null,
                decoration: const InputDecoration(
                  labelText: "Website Link",
                  hintText: "https://www.google.com etc.",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Icon:(.png)",
                    style: theme.textTheme.bodyText1,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        iconError = null;
                        final permanentImage =
                            await saveImagePermanently(image.path);
                        icon = permanentImage.path;
                        if (kDebugMode) {
                          print('icon: ${permanentImage.path}');
                        }
                        // if (image.path.endsWith("png")) {
                        //   iconError = null;
                        //   final permanentImage =
                        //       await saveImagePermanently(image.path);
                        //   icon = permanentImage.path;
                        //   if (kDebugMode) {
                        //     print('icon: ${permanentImage.path}');
                        //   }
                        // } else {
                        //   iconError = "select png image!";
                        //   if (kDebugMode) {
                        //     print('icon: ${image.path}');
                        //   }
                        // }
                      } else {
                        iconError = "Error: Select png icon!";
                        if (kDebugMode) {
                          print('icon: ${image?.path}');
                        }
                      }
                      // FilePickerResult? result =
                      //     await FilePicker.platform.pickFiles(
                      //   type: FileType.custom,
                      //   allowedExtensions: [
                      //     'svg',
                      //     'png',
                      //   ],
                      // );
                      // if (result != null) {
                      //   icon = result.files.first.path!;
                      //   setState(() {});
                      // }
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      primary: theme.primaryColor,
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 28,
                    ),
                  )
                ],
              ),
              Text(
                iconError == null
                    ? icon != null
                        ? basename(icon!)
                        : "No icon selected"
                    : iconError!,
                style: theme.textTheme.caption?.copyWith(
                  color: iconError != null ? Colors.red : null,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Gradient Colors:",
              ),
              Text(
                "Choose both same for single color.",
                style: Theme.of(context).textTheme.caption,
              ),
              TextButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) {
                      return myColorPicker(
                        (color) => color1 = color,
                        pickerColor,
                      );
                    },
                  );
                  setState(() {});
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color1,
                    boxShadow: kContainerShadow,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              TextButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) {
                      return myColorPicker(
                        (color) => color2 = color,
                        pickerColor,
                      );
                    },
                  );

                  setState(() {});
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color2,
                    boxShadow: kContainerShadow,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() && icon != null) {
              final newCard = AppCardModel(
                title: webName,
                fileIcon: icon!,
                timeUsedMinutes: 0,
                gradientColors: [color1, color2],
                screenRouteNamed: AppDetailsScreen.id,
                webUrl: webUrl,
                isDeleteAble: true,
              );
              await Hive.box<AppCardModel>(
                MyStrings.cardsBoxName,
              ).add(newCard);
              final bool addedConfirm = Hive.box<AppCardModel>(
                MyStrings.cardsBoxName,
              ).values.contains(newCard);
              if (addedConfirm) {
                Fluttertoast.showToast(
                  msg: "App Successfully Added",
                  backgroundColor: Theme.of(context).primaryColor,
                  gravity: ToastGravity.BOTTOM,
                  toastLength: Toast.LENGTH_SHORT,
                );
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }

  Widget myColorPicker(Function(Color color) onSubmitted, Color pickerColor) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              setState(() {
                pickerColor = color;
              });
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              onSubmitted(pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  Future<File> saveImagePermanently(String path) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(path);
    final image = File('${directory.path}/$name');
    return File(path).copy(image.path);
  }
}

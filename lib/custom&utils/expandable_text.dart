import 'package:flutter/material.dart';

class MyExpandableText extends StatefulWidget {
  const MyExpandableText({
    required this.text,
    Key? key,
    this.style,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  @override
  _MyExpandableTextState createState() => _MyExpandableTextState();
}

class _MyExpandableTextState extends State<MyExpandableText> {
  String firstHalf = "";
  String secondHalf = "";
  bool showAll = false;
  @override
  Widget build(BuildContext context) {
    if (widget.text.length > 150) {
      firstHalf = widget.text.substring(0, 200);
      secondHalf = widget.text.substring(firstHalf.length);
    } else {
      firstHalf = widget.text;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          showAll = !showAll;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.7,
            child: Text(
              showAll ? firstHalf + secondHalf : firstHalf,
              style: widget.style ?? Theme.of(context).textTheme.bodyText2,
              overflow: showAll ? null : TextOverflow.ellipsis,
              maxLines: showAll ? null : 3,
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}

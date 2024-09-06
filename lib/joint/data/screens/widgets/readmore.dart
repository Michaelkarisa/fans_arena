import 'package:flutter/material.dart';

class ReadMoreWidget extends StatefulWidget {
  final String text;
  final List<String> hashtags;
  final int trimLines;
  final String delimiter;
  final TextStyle delimiterStyle;
  final TextStyle postDataTextStyle;
  final TextStyle hashtagTextStyle;
  final Color colorClickableText;
  final TrimMode trimMode;
  final String trimCollapsedText;
  final String trimExpandedText;
  final TextStyle moreStyle;

  const ReadMoreWidget({super.key, 
    required this.text,
    required this.hashtags,
    this.trimLines = 1,
    this.delimiter = '...',
    this.delimiterStyle = const TextStyle(color: Colors.black),
    this.postDataTextStyle = const TextStyle(color: Colors.black, fontSize: 15),
    this.hashtagTextStyle = const TextStyle(color: Colors.blue),
    this.colorClickableText = Colors.blueGrey,
    this.trimMode = TrimMode.Line,
    this.trimCollapsedText = 'Show more',
    this.trimExpandedText = 'Show less',
    this.moreStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
  });

  @override
  _ReadMoreWidgetState createState() => _ReadMoreWidgetState();
}

class _ReadMoreWidgetState extends State<ReadMoreWidget> {
  bool isExpanded = false;

  List<InlineSpan> buildSpans() {
    final List<String> words = widget.text.split(' ');

    final List<InlineSpan> spans = [];
    final delimiter = widget.delimiter;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      if (word == delimiter) {
        spans.add(TextSpan(
          text: word,
          style: widget.delimiterStyle,
        ));
      } else {
        spans.add(TextSpan(
          text: '$word ',
          style: widget.postDataTextStyle,
        ));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final spans = buildSpans();
    final visibleSpans = isExpanded ? spans : spans.take(widget.trimLines).toList();

    final textSpan = TextSpan(children: visibleSpans);

    final List<Widget> children = [];

    children.add(RichText(
      text: textSpan,
    ));

    if (isExpanded) {
      if (widget.hashtags.isNotEmpty) {
        final hashtagSpans = widget.hashtags
            .map((tag) => TextSpan(text: '$tag ', style: widget.hashtagTextStyle))
            .toList();
        children.add(RichText(
          text: TextSpan(children: hashtagSpans, style: widget.postDataTextStyle),
        ));
      }
      children.add(GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = false;
          });
        },
        child: Text(
          widget.trimExpandedText,
          style: widget.moreStyle.copyWith(
            color: widget.colorClickableText,
          ),
        ),
      ));
    } else if (spans.length > widget.trimLines) {
      children.add(GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = true;
          });
        },
        child: Text(
          widget.trimCollapsedText,
          style: widget.moreStyle.copyWith(
            color: widget.colorClickableText,
          ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

enum TrimMode {
  Line,
  Length,
}

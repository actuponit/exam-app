import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownLatex extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final bool selectable;

  const MarkdownLatex({
    super.key,
    required this.data,
    this.style,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: selectable,
      builders: {
        'math': MathBuilder(),
      },
      styleSheet: MarkdownStyleSheet(
        p: style,
      ),
    );
  }
}

class MathBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final texContent = element.textContent;
    return Math.tex(
      texContent,
      textStyle: preferredStyle,
      mathStyle: MathStyle.text,
    );
  }
} 
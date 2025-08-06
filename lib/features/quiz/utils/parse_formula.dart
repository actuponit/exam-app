import 'package:html/parser.dart' show parse, parseFragment;

String cleanHtmlAndExtractMath(String rawHtml) {
  final document = parse(rawHtml);
  final formulas = document.querySelectorAll('span.ql-formula');

  for (final formula in formulas) {
    final latex = formula.attributes['data-value'] ?? '';
    formula.replaceWith(parseFragment('<tex>$latex</tex>'));
  }

  // You can now split the result into normal text and math
  return document.body?.innerHtml ?? '';
}

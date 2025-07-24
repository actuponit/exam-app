import 'package:exam_app/core/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'latex.dart';

/// Enhanced text widget with markdown, LaTeX, and HTML support
class MarkdownLatexWidget extends StatelessWidget {
  final String data;
  final TextStyle? textStyle;
  final bool shrinkWrap;

  const MarkdownLatexWidget({
    super.key,
    required this.data,
    this.textStyle,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final parts = _parseContent(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: parts.map((part) {
        if (part.type == _ContentType.latex) {
          return Container(
            width: double.infinity,
            margin: part.isBlock
                ? const EdgeInsets.symmetric(vertical: 8.0)
                : const EdgeInsets.symmetric(horizontal: 2.0),
            alignment: part.isBlock ? Alignment.center : Alignment.centerLeft,
            child: LatexWidget(
              latex: part.content,
              isBlock: part.isBlock,
              textStyle: textStyle,
            ),
          );
        } else if (part.type == _ContentType.bold) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              part.content,
              style: (textStyle ?? const TextStyle(fontSize: 16)).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else if (part.type == _ContentType.image) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildImage(part.content, part.altText ?? ''),
          );
        } else if (part.type == _ContentType.html) {
          return _buildHtmlContent(part.content);
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              part.content,
              style: textStyle ?? const TextStyle(fontSize: 16),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildHtmlContent(String htmlContent) {
    return Html(
      shrinkWrap: true,
      data: htmlContent,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(textStyle?.fontSize ?? 16),
          color: textStyle?.color ?? Colors.black87,
          fontFamily: textStyle?.fontFamily,
          fontWeight: textStyle?.fontWeight,
        ),
        "p": Style(
          margin: Margins.only(bottom: 8),
          textAlign: TextAlign.left,
        ),
        "div": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        "span": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        "strong": Style(
          fontWeight: FontWeight.bold,
        ),
        "b": Style(
          fontWeight: FontWeight.bold,
        ),
        "em": Style(
          fontStyle: FontStyle.italic,
        ),
        "i": Style(
          fontStyle: FontStyle.italic,
        ),
        "u": Style(
          textDecoration: TextDecoration.underline,
        ),
        "br": Style(
          margin: Margins.only(bottom: 4),
        ),
      },
      onLinkTap: (url, attributes, element) {
        // Handle link taps if needed
        if (url != null) {
          launchUrl(Uri.parse(url));
        }
      },
    );
  }

  Widget _buildImage(String url, String? altText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedImage(
            imageUrl: url,
            fit: BoxFit.cover,
          ),
        ),
        if (altText != null && altText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            altText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  List<_ContentPart> _parseContent(String content) {
    final parts = <_ContentPart>[];

    // Check if content contains HTML blocks
    if (_containsHtmlBlocks(content)) {
      parts.add(_ContentPart(content, _ContentType.html, true));
      return parts;
    }

    // Regex patterns for different content types
    final blockLatexPattern = RegExp(r'\$\$([^$]+?)\$\$');
    final inlineLatexPattern = RegExp(r'\$([^$]+?)\$');
    final imagePattern = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');
    final boldPattern = RegExp(r'\*\*([^*]+?)\*\*');

    int lastEnd = 0;

    // Find all matches
    final allMatches = <_Match>[];

    // Find block LaTeX matches
    for (final match in blockLatexPattern.allMatches(content)) {
      allMatches.add(_Match(match, _ContentType.latex, isBlock: true));
    }

    // Find inline LaTeX matches (avoid overlapping with block)
    for (final match in inlineLatexPattern.allMatches(content)) {
      bool isInsideBlock = false;
      for (final blockMatch in allMatches
          .where((m) => m.type == _ContentType.latex && m.isBlock)) {
        if (match.start >= blockMatch.match.start &&
            match.end <= blockMatch.match.end) {
          isInsideBlock = true;
          break;
        }
      }
      if (!isInsideBlock) {
        allMatches.add(_Match(match, _ContentType.latex, isBlock: false));
      }
    }

    // Find image matches
    for (final match in imagePattern.allMatches(content)) {
      allMatches.add(_Match(match, _ContentType.image));
    }

    // Find bold text matches
    for (final match in boldPattern.allMatches(content)) {
      // Check if this bold match is inside any other match
      bool isInsideOther = false;
      for (final otherMatch in allMatches) {
        if (match.start >= otherMatch.match.start &&
            match.end <= otherMatch.match.end) {
          isInsideOther = true;
          break;
        }
      }
      if (!isInsideOther) {
        allMatches.add(_Match(match, _ContentType.bold));
      }
    }

    // Sort matches by position
    allMatches.sort((a, b) => a.match.start.compareTo(b.match.start));

    // Process matches
    for (final contentMatch in allMatches) {
      final match = contentMatch.match;
      final type = contentMatch.type;
      final isBlock = contentMatch.isBlock;

      // Add text before this match
      if (match.start > lastEnd) {
        final textBefore = content.substring(lastEnd, match.start);
        if (textBefore.trim().isNotEmpty) {
          parts.add(_ContentPart(textBefore, _ContentType.text, false));
        }
      }

      // Add the matched content
      if (type == _ContentType.image) {
        final altText = match.group(1);
        final imageUrl = match.group(2)!;
        parts.add(_ContentPart(imageUrl, _ContentType.image, false,
            altText: altText));
      } else if (type == _ContentType.latex) {
        final latexContent = match.group(1)!;
        parts.add(_ContentPart(latexContent, _ContentType.latex, isBlock));
      } else if (type == _ContentType.bold) {
        final boldContent = match.group(1)!;
        parts.add(_ContentPart(boldContent, _ContentType.bold, false));
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < content.length) {
      final textAfter = content.substring(lastEnd);
      if (textAfter.trim().isNotEmpty) {
        parts.add(_ContentPart(textAfter, _ContentType.text, false));
      }
    }

    // If no special content found, return the whole content as regular text
    if (parts.isEmpty) {
      parts.add(_ContentPart(content, _ContentType.text, false));
    }

    return parts;
  }

  bool _containsHtmlBlocks(String content) {
    final trimmedContent = content.trim();

    // Check for common HTML block patterns
    final htmlBlockPatterns = [
      RegExp(r'<p[^>]*>.*?</p>', dotAll: true),
      RegExp(r'<div[^>]*>.*?</div>', dotAll: true),
      RegExp(r'<section[^>]*>.*?</section>', dotAll: true),
      RegExp(r'<article[^>]*>.*?</article>', dotAll: true),
      RegExp(r'<header[^>]*>.*?</header>', dotAll: true),
      RegExp(r'<footer[^>]*>.*?</footer>', dotAll: true),
      RegExp(r'<main[^>]*>.*?</main>', dotAll: true),
      RegExp(r'<aside[^>]*>.*?</aside>', dotAll: true),
      RegExp(r'<nav[^>]*>.*?</nav>', dotAll: true),
      RegExp(r'<h[1-6][^>]*>.*?</h[1-6]>', dotAll: true),
      RegExp(r'<ul[^>]*>.*?</ul>', dotAll: true),
      RegExp(r'<ol[^>]*>.*?</ol>', dotAll: true),
      RegExp(r'<table[^>]*>.*?</table>', dotAll: true),
      RegExp(r'<form[^>]*>.*?</form>', dotAll: true),
    ];

    // Check if content starts with HTML tags
    final startsWithHtml = trimmedContent.startsWith('<') &&
        (trimmedContent.startsWith('<p') ||
            trimmedContent.startsWith('<div') ||
            trimmedContent.startsWith('<span') ||
            trimmedContent.startsWith('<strong') ||
            trimmedContent.startsWith('<b') ||
            trimmedContent.startsWith('<em') ||
            trimmedContent.startsWith('<i') ||
            trimmedContent.startsWith('<h') ||
            trimmedContent.startsWith('<ul') ||
            trimmedContent.startsWith('<ol') ||
            trimmedContent.startsWith('<li') ||
            trimmedContent.startsWith('<table') ||
            trimmedContent.startsWith('<tr') ||
            trimmedContent.startsWith('<td') ||
            trimmedContent.startsWith('<th'));

    // Check for HTML block patterns
    for (final pattern in htmlBlockPatterns) {
      if (pattern.hasMatch(trimmedContent)) {
        return true;
      }
    }

    return startsWithHtml;
  }
}

enum _ContentType { text, latex, image, bold, html }

class _ContentPart {
  final String content;
  final _ContentType type;
  final bool isBlock;
  final String? altText;

  _ContentPart(this.content, this.type, this.isBlock, {this.altText});
}

class _Match {
  final RegExpMatch match;
  final _ContentType type;
  final bool isBlock;

  _Match(this.match, this.type, {this.isBlock = false});
}

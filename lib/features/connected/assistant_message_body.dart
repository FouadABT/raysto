import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Formats assistant prose without loading model-supplied images or following
/// model-supplied links. Human messages keep their literal text rendering.
class AssistantMessageBody extends StatelessWidget {
  const AssistantMessageBody({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownBody(
      data: text,
      selectable: true,
      fitContent: false,
      imageBuilder: (uri, title, alt) => Text(alt ?? 'Image omitted'),
      onTapLink: (_, _, _) {},
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        strong: const TextStyle(fontWeight: FontWeight.w700),
        blockSpacing: 10,
        listIndent: 18,
        a: theme.textTheme.bodyMedium,
      ),
    );
  }
}

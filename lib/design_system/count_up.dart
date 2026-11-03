import 'package:flutter/material.dart';

import 'motion.dart';

/// A number that rolls to its value: from 0 the first time it is shown, from
/// the previous value when the data changes. It always lands on the real
/// value and never overshoots. Assistive technology reads only the final
/// value, and an invisible copy of it holds the width so nothing shifts.
/// Under reduced motion the value is shown directly.
class CountUp extends StatefulWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.semanticsLabel,
    this.textAlign = TextAlign.start,
  });

  final num value;

  /// Turns the (fractional, while rolling) value into text, e.g. money.
  final String Function(num value) format;
  final TextStyle? style;

  /// What the number is, e.g. "Paid sales today".
  final String? semanticsLabel;
  final TextAlign textAlign;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> {
  // The first build starts from zero; every later change starts from where
  // the number was, which TweenAnimationBuilder does by itself.
  late num _begin = 0;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final style = (widget.style ?? DefaultTextStyle.of(context).style).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final target = widget.value.toDouble();
    final text = widget.format(widget.value);
    return Semantics(
      label: widget.semanticsLabel,
      value: text,
      child: ExcludeSemantics(
        child: Stack(
          children: [
            // Holds the final width and height, so rolling digits never
            // move what is beside them.
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Text(text, style: style, textAlign: widget.textAlign),
            ),
            Positioned.fill(
              child: reduced
                  ? Text(text, style: style, textAlign: widget.textAlign)
                  : TweenAnimationBuilder<double>(
                      tween: Tween(begin: _begin.toDouble(), end: target),
                      duration: AppMotion.reveal,
                      curve: AppMotion.spatial,
                      onEnd: () => _begin = target,
                      builder: (context, value, _) => Text(
                        // The last frame is the exact value, not a rounding.
                        value == target ? text : widget.format(value),
                        style: style,
                        textAlign: widget.textAlign,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

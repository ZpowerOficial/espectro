import 'package:flutter/material.dart';

import '../theme.dart';

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color resolved = color ?? AppColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 18, height: 1.5, color: resolved),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: resolved),
          ),
        ),
      ],
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.foreground = AppColors.ink,
    this.background = AppColors.surface,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final Widget button = Material(
      color: background,
      shape: CircleBorder(side: BorderSide(color: AppColors.line, width: 1)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, size: 20, color: foreground),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

enum AppButtonKind { filled, outline, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.filled,
    this.icon,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final (Color background, Color foreground, BorderSide border) = switch (kind) {
      AppButtonKind.filled => (AppColors.ink, AppColors.surface, BorderSide.none),
      AppButtonKind.outline => (Colors.transparent, AppColors.ink, const BorderSide(color: AppColors.ink, width: 1.3)),
      AppButtonKind.ghost => (Colors.transparent, AppColors.inkSoft, BorderSide.none),
    };

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: foreground,
                fontSize: 15,
                letterSpacing: 0,
              ),
        ),
        if (icon != null) ...<Widget>[
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: foreground),
        ],
      ],
    );

    final Widget button = Opacity(
      opacity: enabled ? 1 : 0.38,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AnswerTile extends StatelessWidget {
  const AnswerTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.badge,
    this.accent = AppColors.ink,
    super.key,
  }) : assert(icon != null || badge != null, 'informe icon ou badge');

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? badge;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Widget marker = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: selected ? accent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: selected ? accent : AppColors.line, width: 1.4),
      ),
      alignment: Alignment.center,
      child: badge != null
          ? Text(
              badge!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.surface : AppColors.muted,
              ),
            )
          : Icon(icon, size: 15, color: selected ? AppColors.surface : AppColors.muted),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.07) : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : AppColors.line,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              marker,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.ink,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = AppColors.surface,
    this.borderColor = AppColors.line,
    this.radius = 22,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class ProgressRail extends StatelessWidget {
  const ProgressRail({required this.value, this.color = AppColors.ink, super.key});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(
        children: <Widget>[
          Container(height: 6, color: AppColors.line),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag({
    required this.label,
    this.background = AppColors.surfaceAlt,
    this.foreground = AppColors.ink,
    super.key,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontSize: 9.5,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}

/// Enunciado com os termos sublinhados que abrem a definição ao toque.
class TermText extends StatelessWidget {
  const TermText({
    required this.text,
    required this.terms,
    required this.onTermTap,
    this.style,
    super.key,
  });

  final String text;
  final List<({int start, int end, String term, String definition})> terms;
  final void Function(String term, String definition) onTermTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = style ?? Theme.of(context).textTheme.headlineSmall ?? const TextStyle();
    final List<({int start, int end, String term, String definition})> valid = terms
        .where((term) => term.start >= 0 && term.end <= text.length && term.start < term.end)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final List<InlineSpan> spans = <InlineSpan>[];
    var cursor = 0;
    for (final term in valid) {
      if (term.start < cursor) continue;
      if (term.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, term.start)));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () => onTermTap(term.term, term.definition),
            child: Text(
              text.substring(term.start, term.end),
              style: base.copyWith(
                decoration: TextDecoration.underline,
                decorationThickness: 2,
                decorationColor: AppColors.accent,
                decorationStyle: TextDecorationStyle.solid,
              ),
            ),
          ),
        ),
      );
      cursor = term.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return Text.rich(TextSpan(style: base, children: spans));
  }
}

Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.62,
        maxChildSize: 0.92,
        minChildSize: 0.35,
        builder: (BuildContext context, ScrollController controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
            children: <Widget>[
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              child,
            ],
          );
        },
      );
    },
  );
}

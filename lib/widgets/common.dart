import 'package:flutter/material.dart';

import '../theme.dart';

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color resolved = color ?? p.muted;
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: resolved,
        fontSize: 11,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.foreground,
    this.background,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Widget button = Material(
      color: background ?? p.surface,
      shape: CircleBorder(side: BorderSide(color: p.line, width: 1)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: foreground ?? p.ink),
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
    this.onDark = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;
  final bool expand;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final bool enabled = onPressed != null;
    final (
      Color background,
      Color foreground,
      BorderSide border,
    ) = switch (kind) {
      AppButtonKind.filled => (
        onDark ? const Color(0xFF6AE0CB) : p.accent,
        (onDark || p.isDark) ? const Color(0xFF061318) : Colors.white,
        BorderSide.none,
      ),
      AppButtonKind.outline => (
        Colors.transparent,
        p.ink,
        BorderSide(color: p.line, width: 1.4),
      ),
      AppButtonKind.ghost => (Colors.transparent, p.inkSoft, BorderSide.none),
    };

    final Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: foreground, fontSize: 16, letterSpacing: 0),
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
          borderRadius: BorderRadius.circular(13),
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
    this.accent,
    super.key,
  }) : assert(icon != null || badge != null, 'informe icon ou badge');

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? badge;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color resolvedAccent = accent ?? p.accent;
    final Color onAccent = p.isDark ? const Color(0xFF061318) : Colors.white;

    final Widget marker = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: selected ? resolvedAccent : p.canvas,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? resolvedAccent : p.canvas,
          width: 1.4,
        ),
      ),
      alignment: Alignment.center,
      child: badge != null
          ? Text(badge!, style: TextStyle(fontSize: 9, color: onAccent))
          : null,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? p.accentSoft : p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? resolvedAccent : p.line,
              width: 1,
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
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w400,
                    color: p.ink,
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
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.borderColor,
    this.radius = 17,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? p.line),
      ),
      child: child,
    );
  }
}

class ProgressRail extends StatelessWidget {
  const ProgressRail({required this.value, this.color, super.key});

  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color bar = color ?? p.accent;
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(
        children: <Widget>[
          Container(height: 6, color: p.surfaceMuted),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 6,
              decoration: BoxDecoration(
                color: bar,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Container responsivo que centraliza o conteúdo em telas largas (Desktop/Web/Tablet)
/// limitando a largura máxima para preservar a legibilidade e evitar overflow ou estiramento.
class ResponsiveContentFrame extends StatelessWidget {
  const ResponsiveContentFrame({
    required this.child,
    this.maxWidth = 760.0,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag({required this.label, this.background, this.foreground, super.key});

  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? p.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground ?? p.inkSoft,
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
    final EspectroPalette p = context.palette;
    final TextStyle base =
        style ?? Theme.of(context).textTheme.headlineSmall ?? const TextStyle();
    final List<({int start, int end, String term, String definition})> valid =
        terms
            .where(
              (term) =>
                  term.start >= 0 &&
                  term.end <= text.length &&
                  term.start < term.end,
            )
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));

    final List<InlineSpan> spans = <InlineSpan>[];
    var cursor = 0;
    for (final ({int start, int end, String term, String definition}) term
        in valid) {
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
                decorationColor: p.accent,
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
  final EspectroPalette p = context.palette;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.64,
        maxChildSize: 0.92,
        minChildSize: 0.35,
        builder: (BuildContext context, ScrollController controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
            children: <Widget>[
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              child,
              const SizedBox(height: 20),
              AppButton(
                label: 'Entendi',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    },
  );
}

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Feedback tátil discreto ao pressionar botões e cartões (`scale(0.98)`),
/// seguindo curva de desaceleração rápida e respeitando preferência de
/// redução de movimento do sistema.
class TactilePress extends StatefulWidget {
  const TactilePress({
    required this.child,
    this.enabled = true,
    this.scale = 0.98,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double scale;

  @override
  State<TactilePress> createState() => _TactilePressState();
}

class _TactilePressState extends State<TactilePress> {
  bool _pressed = false;

  void _setPressed(bool next) {
    if (!widget.enabled || _pressed == next) return;
    setState(() => _pressed = next);
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final Widget body = reduceMotion
        ? widget.child
        : AnimatedScale(
            scale: _pressed && widget.enabled ? widget.scale : 1.0,
            duration: EspectroMotion.fast,
            curve: EspectroMotion.easeOut,
            child: widget.child,
          );
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: body,
    );
  }
}

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
    final Widget button = TactilePress(
      enabled: onPressed != null,
      scale: 0.94,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: EspectroElevation.cardShadows(p, elevated: true),
        ),
        child: Material(
          color: background ?? p.surface,
          shape: CircleBorder(
            side: BorderSide(
              color: p.line.withValues(alpha: p.isDark ? 0.9 : 0.8),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: 20, color: foreground ?? p.ink),
            ),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Assinatura cromática horizontal do Espectro ligando os polos do catálogo.
class SpectrumGradientRule extends StatelessWidget {
  const SpectrumGradientRule({
    this.height = 3.0,
    this.radius = 999,
    this.width,
    super.key,
  });

  final double height;
  final double radius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(colors: EspectroPalette.spectrumStops),
      ),
    );
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
    ) = !enabled
        ? switch (kind) {
            AppButtonKind.filled => (
              onDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : p.surfaceMuted,
              onDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : p.muted,
              BorderSide(
                color: onDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : p.line,
              ),
            ),
            AppButtonKind.outline => (
              p.surfaceMuted.withValues(alpha: 0.55),
              p.muted,
              BorderSide(color: p.line.withValues(alpha: 0.8), width: 1.2),
            ),
            AppButtonKind.ghost => (
              Colors.transparent,
              p.muted.withValues(alpha: 0.65),
              BorderSide.none,
            ),
          }
        : switch (kind) {
            AppButtonKind.filled => (
              onDark ? Colors.white : p.accent,
              onDark
                  ? const Color(0xFF0C1018)
                  : (p.isDark ? const Color(0xFF071020) : Colors.white),
              BorderSide.none,
            ),
            AppButtonKind.outline => (
              p.surface,
              p.ink,
              BorderSide(color: p.line, width: 1.4),
            ),
            AppButtonKind.ghost => (
              Colors.transparent,
              p.inkSoft,
              BorderSide.none,
            ),
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

    final Widget button = Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: label,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: TactilePress(
          enabled: enabled,
          scale: 0.98,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              boxShadow: (enabled && kind == AppButtonKind.filled && !onDark)
                  ? EspectroElevation.cardShadows(p, tint: p.accent)
                  : const <BoxShadow>[],
            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AnswerTile extends StatefulWidget {
  const AnswerTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.badge,
    this.accent,
    this.subtitle,
    this.tag,
    this.tintedUnselected = true,
    this.showRadio = true,
    super.key,
  }) : assert(icon != null || badge != null, 'informe icon ou badge');

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? badge;
  final Color? accent;
  final String? subtitle;
  final String? tag;
  final bool tintedUnselected;
  final bool showRadio;

  @override
  State<AnswerTile> createState() => _AnswerTileState();
}

class _AnswerTileState extends State<AnswerTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color resolvedAccent = widget.accent ?? p.accent;
    final Color onAccent = p.isDark ? const Color(0xFF061318) : Colors.white;

    final Widget marker;
    if (widget.icon != null) {
      marker = AnimatedContainer(
        duration: EspectroMotion.fast,
        curve: EspectroMotion.easeOut,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: widget.selected
              ? resolvedAccent.withValues(alpha: p.isDark ? 0.28 : 0.16)
              : resolvedAccent.withValues(alpha: p.isDark ? 0.14 : 0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Icon(widget.icon, size: 17, color: resolvedAccent),
      );
    } else {
      marker = AnimatedContainer(
        duration: EspectroMotion.fast,
        curve: EspectroMotion.easeOut,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: widget.selected
              ? resolvedAccent
              : resolvedAccent.withValues(alpha: p.isDark ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.selected
                ? resolvedAccent
                : resolvedAccent.withValues(alpha: _isHovered ? 0.60 : 0.25),
            width: widget.selected ? 1.5 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: widget.badge != null
            ? Text(
                widget.badge!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.selected ? onAccent : resolvedAccent,
                  fontFamily: 'IBMPlexMono',
                ),
              )
            : null,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: TactilePress(
        scale: 0.985,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            hoverColor: Colors.transparent,
            child: AnimatedContainer(
              duration: EspectroMotion.fast,
              curve: EspectroMotion.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: widget.selected
                    ? Color.alphaBlend(
                        resolvedAccent.withValues(alpha: p.isDark ? 0.20 : 0.10),
                        p.surface,
                      )
                    : (_isHovered
                          ? Color.alphaBlend(
                              resolvedAccent.withValues(
                                alpha: p.isDark ? 0.11 : 0.05,
                              ),
                              p.surface,
                            )
                          : (widget.tintedUnselected
                                ? Color.alphaBlend(
                                    resolvedAccent.withValues(
                                      alpha: p.isDark ? 0.06 : 0.025,
                                    ),
                                    p.surface,
                                  )
                                : p.surface)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.selected
                      ? resolvedAccent
                      : (_isHovered
                            ? resolvedAccent.withValues(alpha: 0.55)
                            : (widget.tintedUnselected
                                  ? resolvedAccent.withValues(
                                      alpha: p.isDark ? 0.28 : 0.20,
                                    )
                                  : p.line)),
                  width: widget.selected ? 1.8 : 1.0,
                ),
                boxShadow: [
                  if (widget.selected)
                    ...EspectroElevation.cardShadows(p, tint: resolvedAccent)
                  else if (_isHovered)
                    ...EspectroElevation.cardShadows(
                      p,
                      tint: resolvedAccent,
                    ),
                ],
              ),
            child: Row(
              children: <Widget>[
                marker,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          height: 1.2,
                          fontWeight: widget.selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: widget.selected ? resolvedAccent : p.ink,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.2,
                            fontWeight: widget.selected
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: widget.selected
                                ? resolvedAccent.withValues(alpha: 0.90)
                                : p.inkSoft,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.tag != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: resolvedAccent.withValues(
                        alpha: widget.selected
                            ? (p.isDark ? 0.35 : 0.20)
                            : (p.isDark ? 0.16 : 0.08),
                      ),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: resolvedAccent.withValues(
                          alpha: widget.selected ? 0.60 : 0.25,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.tag!,
                      style: TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: resolvedAccent,
                      ),
                    ),
                  ),
                ],
                if (widget.showRadio) ...[
                  const SizedBox(width: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.selected
                            ? resolvedAccent
                            : (_isHovered
                                  ? resolvedAccent.withValues(alpha: 0.65)
                                  : (p.isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFFCBD5E1))),
                        width: widget.selected ? 2.0 : 1.6,
                      ),
                      color: widget.selected
                          ? resolvedAccent.withValues(
                              alpha: p.isDark ? 0.25 : 0.15,
                            )
                          : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: widget.selected
                        ? Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: resolvedAccent,
                            ),
                          )
                        : null,
                  ),
                ] else if (widget.selected) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: resolvedAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
    this.elevated = true,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final bool useShadow = elevated && color == null;
    return Container(
      padding: padding,
      decoration: EspectroElevation.cardDecoration(
        p,
        color: color,
        borderColor: borderColor,
        radius: radius,
        elevated: useShadow,
      ),
      child: child,
    );
  }
}

/// Faixa horizontal com indício visual explícito de continuação (degradê nas bordas
/// + setas de rolagem sutis em desktop/web) sempre que houver conteúdo fora da tela.
class HorizontalAffordanceStrip extends StatefulWidget {
  const HorizontalAffordanceStrip({
    required this.builder,
    this.fadeColor,
    this.edgeFadeWidth = 28,
    this.showArrows = true,
    super.key,
  });

  final Widget Function(BuildContext context, ScrollController controller)
      builder;
  final Color? fadeColor;
  final double edgeFadeWidth;
  final bool showArrows;

  @override
  State<HorizontalAffordanceStrip> createState() =>
      _HorizontalAffordanceStripState();
}

class _HorizontalAffordanceStripState extends State<HorizontalAffordanceStrip> {
  final ScrollController _controller = ScrollController();
  bool _canLeft = false;
  bool _canRight = false;
  bool _checkScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleCheck();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleCheck() {
    if (_checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (!mounted || !_controller.hasClients) return;
      _updateFromMetrics(_controller.position);
    });
  }

  void _updateFromMetrics(ScrollMetrics metrics) {
    final bool nextLeft = metrics.pixels > 2;
    final bool nextRight = metrics.maxScrollExtent - metrics.pixels > 2;
    if (nextLeft != _canLeft || nextRight != _canRight) {
      if (mounted) {
        setState(() {
          _canLeft = nextLeft;
          _canRight = nextRight;
        });
      }
    }
  }

  Future<void> _scrollBy(double delta) async {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final double target = (position.pixels + delta).clamp(
      0.0,
      position.maxScrollExtent,
    );
    await _controller.animateTo(
      target,
      duration: EspectroMotion.medium,
      curve: EspectroMotion.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color scrimBase = widget.fadeColor ?? p.canvas;
    final bool showDesktopArrows =
        widget.showArrows && MediaQuery.sizeOf(context).width >= 680;

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.horizontal) {
          _updateFromMetrics(notification.metrics);
        }
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.horizontal) {
            _updateFromMetrics(notification.metrics);
          }
          return false;
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            widget.builder(context, _controller),
            if (_canLeft)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: widget.edgeFadeWidth,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[scrimBase, scrimBase.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
            if (_canRight)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: widget.edgeFadeWidth,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: <Color>[scrimBase, scrimBase.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
            if (showDesktopArrows && _canLeft)
              Positioned(
                left: 4,
                child: _StripArrowButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Rolar para a esquerda',
                  onTap: () {
                    final double step = _controller.hasClients
                        ? math.max(180.0, _controller.position.viewportDimension * 0.65)
                        : 220.0;
                    _scrollBy(-step);
                  },
                ),
              ),
            if (showDesktopArrows && _canRight)
              Positioned(
                right: 4,
                child: _StripArrowButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Rolar para a direita',
                  onTap: () {
                    final double step = _controller.hasClients
                        ? math.max(180.0, _controller.position.viewportDimension * 0.65)
                        : 220.0;
                    _scrollBy(step);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StripArrowButton extends StatelessWidget {
  const _StripArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: TactilePress(
          scale: 0.92,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: EspectroElevation.cardShadows(p),
            ),
            child: Material(
              color: p.surface.withValues(alpha: 0.96),
              shape: CircleBorder(
                side: BorderSide(color: p.line.withValues(alpha: 0.9)),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(icon, size: 18, color: p.ink),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded capsule badge for bipolar axis poles and ternary vertices.
class PolePill extends StatelessWidget {
  const PolePill({
    required this.label,
    required this.color,
    required this.isActive,
    this.badge,
    super.key,
  });

  final String label;
  final Color color;
  final bool isActive;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.6)
              : p.line.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? color : p.inkSoft.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? color : p.inkSoft,
              ),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 4),
            Text(
              badge!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? color : p.inkSoft,
              ),
            ),
          ],
        ],
      ),
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
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: p.isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: value.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return FractionallySizedBox(
                widthFactor: animatedValue,
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [bar.withValues(alpha: 0.85), bar],
                    ),
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: bar.withValues(alpha: 0.45),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Container responsivo que centraliza o conteúdo em telas largas (Desktop/Web/Tablet)
/// limitando a largura máxima para preservar a legibilidade, mas reconhecendo a
/// rolagem (mouse wheel / trackpad) em 100% da largura da tela.
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

  static ScrollableState? _findVerticalScrollable(BuildContext root) {
    ScrollableState? found;
    void visit(Element element) {
      if (found != null) return;
      if (element is StatefulElement && element.state is ScrollableState) {
        final s = element.state as ScrollableState;
        if (s.position.axis == Axis.vertical && s.position.hasPixels) {
          found = s;
          return;
        }
      }
      element.visitChildren(visit);
    }

    root.visitChildElements(visit);
    return found;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent && event.scrollDelta.dy != 0) {
          GestureBinding.instance.pointerSignalResolver.register(event, (
            PointerSignalEvent e,
          ) {
            if (e is PointerScrollEvent) {
              final scrollable = _findVerticalScrollable(context);
              if (scrollable != null && scrollable.mounted) {
                scrollable.position.pointerScroll(e.scrollDelta.dy);
              }
            }
          });
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(padding: padding, child: child),
          ),
        ),
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
                color: p.accent,
                decoration: TextDecoration.underline,
                decorationThickness: 1.6,
                decorationColor: p.accent.withValues(alpha: 0.65),
                decorationStyle: TextDecorationStyle.dotted,
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
    // A cor é resolvida dentro do builder para que trocar o tema com a folha
    // aberta também atualize a superfície, em vez de deixar um bloco claro
    // sobre um app escuro.
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      final EspectroPalette p = context.palette;
      return Material(
        color: p.surface,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
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
        ),
      );
    },
  );
}

/// Barra de abas com gradiente suave na borda direita para sinalizar continuação
/// quando os rótulos horizontais ultrapassam a largura da tela (especialmente no mobile).
class FadeEdgeTabBar extends StatelessWidget implements PreferredSizeWidget {
  const FadeEdgeTabBar({
    required this.tabBar,
    this.fadeColor,
    this.edgeWidth = 26,
    super.key,
  });

  final TabBar tabBar;
  final Color? fadeColor;
  final double edgeWidth;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color scrim = fadeColor ?? p.canvas;
    return Stack(
      children: <Widget>[
        tabBar,
        Positioned(
          right: 0,
          top: 0,
          bottom: 1,
          width: edgeWidth,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: <Color>[scrim, scrim.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

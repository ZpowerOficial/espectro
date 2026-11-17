import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/models/study_models.dart';
import 'study_taxonomy.dart';

/// Tipo de emblema histórico vetorial para correntes que possuem simbologia
/// política/filosófica consagrada (sistema híbrido: símbolo histórico quando
/// existe + selo vetorial único pelos eixos + monograma nas demais).
enum _HistoricalEmblemKind {
  gadsdenAncap,
  circleAAnarchist,
  redBlackSyndicalist,
  mutualist,
  ecoAnarchist,
  socialRose,
  revolutionaryStar,
  greenSunflower,
  solarpunkSun,
  libertyTorch,
  classicalColumn,
  oakCrown,
  christianDemShield,
  sovereignShield,
  techHexNode,
  axisSignature,
}

/// Emblema vetorial híbrido para Correntes Ideológicas.
///
/// Zero ícones genéricos de biblioteca:
/// - Correntes com simbologia histórica reconhecida recebem brasão vetorial
///   próprio desenhado via [CustomPainter] (Gadsden/Ancap, Círculo-A, Rosa
///   Social-Democrata, Tocha Liberal, Girassol Verde, Coroa/Carvalho etc.).
/// - As demais ~240 correntes acadêmicas/filosóficas recebem um selo editorial
///   único gerado matematicamente a partir dos 12 eixos reais da corrente +
///   monograma tipográfico.
class CurrentHeraldicEmblem extends StatelessWidget {
  const CurrentHeraldicEmblem({
    required this.subject,
    required this.size,
    super.key,
  });

  final StudySubject subject;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spectrum = spectrumOf(subject);
    final color = spectrum?.color ?? Theme.of(context).colorScheme.primary;
    final id = subject.current?.id ?? subject.key.replaceFirst('current:', '');
    final kind = _resolveHistoricalKind(id);

    final monogram = _buildMonogram(subject.name);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.24 : 0.14),
            color.withValues(alpha: isDark ? 0.08 : 0.05),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.45),
          width: 1.3,
        ),
      ),
      child: CustomPaint(
        size: Size.square(size),
        painter: _CurrentEmblemPainter(
          kind: kind,
          color: color,
          isDark: isDark,
          axes: subject.displayAxes,
          monogram: monogram,
        ),
      ),
    );
  }

  static String _buildMonogram(String name) {
    const stopWords = {'de', 'da', 'do', 'das', 'dos', 'e', 'em', 'para', 'ou'};
    final words = name
        .replaceAll(RegExp(r'[()/\-]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !stopWords.contains(w.toLowerCase()))
        .toList();
    if (words.isEmpty) return 'ID';
    if (words.length == 1) {
      final w = words.first.toUpperCase();
      return w.length >= 2 ? w.substring(0, 2) : w;
    }
    return '${words[0].characters.first.toUpperCase()}${words[1].characters.first.toUpperCase()}';
  }

  static _HistoricalEmblemKind _resolveHistoricalKind(String id) {
    // 1. Correntes com bandeira/símbolo histórico específico e consagrado
    if (id == 'anarcocapitalismo' ||
        id == 'paleolibertarianismo' ||
        id == 'libertarianismo_minarquista' ||
        id == 'agorismo') {
      return _HistoricalEmblemKind.gadsdenAncap;
    }
    if (id == 'anarcossindicalismo' || id == 'sindicalismo_revolucionario') {
      return _HistoricalEmblemKind.redBlackSyndicalist;
    }
    if (id == 'mutualismo_proudhoniano') {
      return _HistoricalEmblemKind.mutualist;
    }
    if (id == 'anarcoprimitivismo' || id == 'ecologia_profunda') {
      return _HistoricalEmblemKind.ecoAnarchist;
    }
    if (id.contains('anarquism') || id == 'anarcocomunismo') {
      return _HistoricalEmblemKind.circleAAnarchist;
    }
    if (id == 'solarpunk') {
      return _HistoricalEmblemKind.solarpunkSun;
    }
    if (id == 'ecologismo_politico' || id == 'ecossocialismo') {
      return _HistoricalEmblemKind.greenSunflower;
    }
    if (id == 'social_democracia' ||
        id == 'socialismo_democratico' ||
        id == 'socialismo_fabiano' ||
        id == 'trabalhismo_desenvolvimentista' ||
        id == 'terceira_via') {
      return _HistoricalEmblemKind.socialRose;
    }
    if (id == 'marxismo_leninismo' ||
        id == 'trotskismo' ||
        id == 'maoismo' ||
        id == 'guevarismo' ||
        id == 'comunismo_de_conselhos' ||
        id == 'eurocomunismo' ||
        id == 'luxemburguismo') {
      return _HistoricalEmblemKind.revolutionaryStar;
    }
    if (id == 'liberalismo_classico' ||
        id == 'escola_austriaca' ||
        id == 'objetivismo_randiano') {
      return _HistoricalEmblemKind.libertyTorch;
    }
    if (id == 'georgismo' ||
        id == 'ordoliberalismo' ||
        id == 'liberalismo_social') {
      return _HistoricalEmblemKind.classicalColumn;
    }
    if (id == 'democracia_crista' ||
        id == 'distributismo_comunitarismo' ||
        id == 'teologia_da_libertacao') {
      return _HistoricalEmblemKind.christianDemShield;
    }
    if (id == 'conservadorismo_burkeano' ||
        id == 'conservadorismo_tradicionalista' ||
        id == 'conservadorismo_one_nation' ||
        id == 'monarquismo_constitucional') {
      return _HistoricalEmblemKind.oakCrown;
    }
    if (id == 'nacionalismo_civico' ||
        id == 'soberanismo_gaullista' ||
        id == 'peronismo_justicialismo' ||
        id == 'castilhismo' ||
        id == 'bonapartismo_cesarismo') {
      return _HistoricalEmblemKind.sovereignShield;
    }
    if (id == 'tecnocracia_institucional' ||
        id == 'ciberlibertarianismo' ||
        id == 'anarcotransumanismo' ||
        id == 'aceleracionismo_de_direita') {
      return _HistoricalEmblemKind.techHexNode;
    }
    // 2. Demais ~240 correntes filosóficas/acadêmicas sem bandeira histórica
    // recebem o selo vetorial único gerado a partir dos eixos + monograma.
    return _HistoricalEmblemKind.axisSignature;
  }
}

class _CurrentEmblemPainter extends CustomPainter {
  const _CurrentEmblemPainter({
    required this.kind,
    required this.color,
    required this.isDark,
    required this.axes,
    required this.monogram,
  });

  final _HistoricalEmblemKind kind;
  final Color color;
  final bool isDark;
  final Map<String, double> axes;
  final String monogram;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    switch (kind) {
      case _HistoricalEmblemKind.gadsdenAncap:
        _paintGadsden(canvas, size, center);
      case _HistoricalEmblemKind.redBlackSyndicalist:
        _paintBisectedAnarchy(
          canvas,
          size,
          center,
          const Color(0xFFD62828),
          const Color(0xFF181A1F),
        );
      case _HistoricalEmblemKind.mutualist:
        _paintBisectedAnarchy(
          canvas,
          size,
          center,
          const Color(0xFFE07A1F),
          const Color(0xFF181A1F),
        );
      case _HistoricalEmblemKind.ecoAnarchist:
        _paintBisectedAnarchy(
          canvas,
          size,
          center,
          const Color(0xFF2D8A56),
          const Color(0xFF181A1F),
        );
      case _HistoricalEmblemKind.circleAAnarchist:
        _paintCircleA(canvas, size, center);
      case _HistoricalEmblemKind.socialRose:
        _paintRose(canvas, size, center);
      case _HistoricalEmblemKind.revolutionaryStar:
        _paintStar(canvas, size, center);
      case _HistoricalEmblemKind.greenSunflower:
        _paintSunflower(canvas, size, center);
      case _HistoricalEmblemKind.solarpunkSun:
        _paintSolarpunk(canvas, size, center);
      case _HistoricalEmblemKind.libertyTorch:
        _paintTorch(canvas, size, center);
      case _HistoricalEmblemKind.classicalColumn:
        _paintColumn(canvas, size, center);
      case _HistoricalEmblemKind.oakCrown:
        _paintCrown(canvas, size, center);
      case _HistoricalEmblemKind.christianDemShield:
        _paintShield(canvas, size, center, withCross: true);
      case _HistoricalEmblemKind.sovereignShield:
        _paintShield(canvas, size, center, withCross: false);
      case _HistoricalEmblemKind.techHexNode:
        _paintHexNode(canvas, size, center);
      case _HistoricalEmblemKind.axisSignature:
        _paintAxisSignature(canvas, size, center, w, h);
    }
  }

  void _paintGadsden(Canvas canvas, Size size, Offset c) {
    // Diagonal gold/obsidian field + stylized coiled rattlesnake S-curve
    final gold = const Color(0xFFF2C534);
    final dark = const Color(0xFF181A1F);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = gold.withValues(alpha: isDark ? 0.34 : 0.28),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = dark.withValues(alpha: isDark ? 0.55 : 0.16),
    );

    final r = size.width * 0.28;
    final snakePaint = Paint()
      ..color = isDark ? gold : const Color(0xFF9E7806)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, size.width * 0.055)
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(c.dx - r * 0.7, c.dy + r * 0.65)
      ..cubicTo(
        c.dx + r * 0.9,
        c.dy + r * 0.75,
        c.dx - r * 0.9,
        c.dy - r * 0.05,
        c.dx + r * 0.65,
        c.dy - r * 0.15,
      )
      ..cubicTo(
        c.dx + r * 0.95,
        c.dy - r * 0.55,
        c.dx - r * 0.1,
        c.dy - r * 0.9,
        c.dx - r * 0.55,
        c.dy - r * 0.55,
      );
    canvas.drawPath(path, snakePaint);
    canvas.drawCircle(
      Offset(c.dx - r * 0.58, c.dy - r * 0.56),
      size.width * 0.045,
      Paint()..color = isDark ? gold : const Color(0xFF9E7806),
    );
  }

  void _paintBisectedAnarchy(
    Canvas canvas,
    Size size,
    Offset c,
    Color topLeft,
    Color bottomRight,
  ) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = topLeft.withValues(alpha: isDark ? 0.58 : 0.42),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = bottomRight.withValues(alpha: isDark ? 0.72 : 0.30),
    );
    _paintCircleA(canvas, size, c, strokeColor: Colors.white.withValues(alpha: 0.92));
  }

  void _paintCircleA(Canvas canvas, Size size, Offset c, {Color? strokeColor}) {
    final ink = strokeColor ?? (isDark ? const Color(0xFFE6E8EC) : const Color(0xFF1F2329));
    final r = size.width * 0.28;
    final p = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, size.width * 0.05)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(c, r, p);
    final aPath = Path()
      ..moveTo(c.dx - r * 0.75, c.dy + r * 0.85)
      ..lineTo(c.dx, c.dy - r * 0.95)
      ..lineTo(c.dx + r * 0.75, c.dy + r * 0.85)
      ..moveTo(c.dx - r * 0.78, c.dy + r * 0.16)
      ..lineTo(c.dx + r * 0.78, c.dy + r * 0.16);
    canvas.drawPath(aPath, p);
  }

  void _paintRose(Canvas canvas, Size size, Offset c) {
    final roseColor = isDark ? const Color(0xFFFF7A7A) : const Color(0xFFC82D3B);
    final stemColor = isDark ? const Color(0xFF7AD69E) : const Color(0xFF287547);
    final r = size.width * 0.22;

    // Stem & leaves
    final stem = Paint()
      ..color = stemColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.width * 0.045)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(c.dx, c.dy + r * 0.25),
      Offset(c.dx, c.dy + r * 1.45),
      stem,
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy + r * 1.0)
        ..quadraticBezierTo(c.dx + r * 0.7, c.dy + r * 0.7, c.dx + r * 0.75, c.dy + r * 1.1)
        ..quadraticBezierTo(c.dx + r * 0.3, c.dy + r * 1.2, c.dx, c.dy + r * 1.0),
      Paint()..color = stemColor.withValues(alpha: 0.85),
    );

    // Geometric rose bloom
    final bloomCenter = Offset(c.dx, c.dy - r * 0.25);
    canvas.drawCircle(bloomCenter, r * 0.92, Paint()..color = roseColor.withValues(alpha: 0.88));
    final spiral = Paint()
      ..color = isDark ? const Color(0xFF220B0E) : Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, size.width * 0.032)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: bloomCenter, radius: r * 0.52),
      0.3,
      math.pi * 1.45,
      false,
      spiral,
    );
    canvas.drawArc(
      Rect.fromCircle(center: bloomCenter, radius: r * 0.24),
      2.0,
      math.pi * 1.4,
      false,
      spiral,
    );
  }

  void _paintStar(Canvas canvas, Size size, Offset c) {
    final starColor = isDark ? const Color(0xFFFFD166) : const Color(0xFFB81D24);
    final outer = size.width * 0.31;
    final inner = outer * 0.42;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final rad = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * (math.pi / 5);
      final pt = Offset(c.dx + math.cos(angle) * rad, c.dy + math.sin(angle) * rad);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = starColor);
  }

  void _paintSunflower(Canvas canvas, Size size, Offset c) {
    final petalColor = isDark ? const Color(0xFFF7C948) : const Color(0xFFD99B00);
    final coreColor = isDark ? const Color(0xFF47C178) : const Color(0xFF1F7A46);
    final r = size.width * 0.29;
    for (int i = 0; i < 10; i++) {
      final angle = i * (2 * math.pi / 10);
      final px = c.dx + math.cos(angle) * (r * 0.65);
      final py = c.dy + math.sin(angle) * (r * 0.65);
      canvas.drawCircle(Offset(px, py), r * 0.25, Paint()..color = petalColor);
    }
    canvas.drawCircle(c, r * 0.44, Paint()..color = coreColor);
  }

  void _paintSolarpunk(Canvas canvas, Size size, Offset c) {
    final sunColor = const Color(0xFFF6B93B);
    final leafColor = const Color(0xFF2ECC71);
    final r = size.width * 0.26;
    canvas.drawCircle(
      Offset(c.dx, c.dy - r * 0.15),
      r * 0.55,
      Paint()..color = sunColor,
    );
    final rayPaint = Paint()
      ..color = sunColor.withValues(alpha: 0.85)
      ..strokeWidth = math.max(1.3, size.width * 0.032)
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 7; i++) {
      final a = -math.pi + (i * math.pi / 6);
      canvas.drawLine(
        Offset(c.dx + math.cos(a) * r * 0.72, c.dy - r * 0.15 + math.sin(a) * r * 0.72),
        Offset(c.dx + math.cos(a) * r * 1.05, c.dy - r * 0.15 + math.sin(a) * r * 1.05),
        rayPaint,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.9, c.dy + r * 0.75)
        ..quadraticBezierTo(c.dx, c.dy + r * 0.15, c.dx + r * 0.9, c.dy + r * 0.75)
        ..quadraticBezierTo(c.dx, c.dy + r * 0.95, c.dx - r * 0.9, c.dy + r * 0.75),
      Paint()..color = leafColor,
    );
  }

  void _paintTorch(Canvas canvas, Size size, Offset c) {
    final flame = isDark ? const Color(0xFFFFB703) : const Color(0xFFD97706);
    final handle = color;
    final r = size.width * 0.26;
    // Handle
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.24, c.dy + r * 0.05)
        ..lineTo(c.dx + r * 0.24, c.dy + r * 0.05)
        ..lineTo(c.dx + r * 0.1, c.dy + r * 1.1)
        ..lineTo(c.dx - r * 0.1, c.dy + r * 1.1)
        ..close(),
      Paint()..color = handle,
    );
    // Rim
    canvas.drawLine(
      Offset(c.dx - r * 0.38, c.dy + r * 0.05),
      Offset(c.dx + r * 0.38, c.dy + r * 0.05),
      Paint()
        ..color = handle
        ..strokeWidth = math.max(1.8, size.width * 0.045)
        ..strokeCap = StrokeCap.round,
    );
    // Flame
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r * 1.1)
        ..quadraticBezierTo(c.dx + r * 0.55, c.dy - r * 0.3, c.dx, c.dy - r * 0.02)
        ..quadraticBezierTo(c.dx - r * 0.55, c.dy - r * 0.3, c.dx, c.dy - r * 1.1),
      Paint()..color = flame,
    );
  }

  void _paintColumn(Canvas canvas, Size size, Offset c) {
    final ink = color;
    final r = size.width * 0.25;
    final p = Paint()
      ..color = ink
      ..strokeWidth = math.max(1.4, size.width * 0.036)
      ..strokeCap = StrokeCap.round;
    // Pediment
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.95, c.dy - r * 0.6)
        ..lineTo(c.dx, c.dy - r * 1.1)
        ..lineTo(c.dx + r * 0.95, c.dy - r * 0.6)
        ..close(),
      Paint()..color = ink.withValues(alpha: 0.85),
    );
    // 3 pillars
    for (final dx in [-r * 0.55, 0.0, r * 0.55]) {
      canvas.drawLine(
        Offset(c.dx + dx, c.dy - r * 0.45),
        Offset(c.dx + dx, c.dy + r * 0.8),
        p,
      );
    }
    // Base
    canvas.drawLine(
      Offset(c.dx - r * 0.95, c.dy + r * 0.92),
      Offset(c.dx + r * 0.95, c.dy + r * 0.92),
      p,
    );
  }

  void _paintCrown(Canvas canvas, Size size, Offset c) {
    final gold = isDark ? const Color(0xFFE9C46A) : color;
    final r = size.width * 0.27;
    final crown = Path()
      ..moveTo(c.dx - r * 0.95, c.dy + r * 0.55)
      ..lineTo(c.dx - r * 1.05, c.dy - r * 0.45)
      ..lineTo(c.dx - r * 0.45, c.dy + r * 0.05)
      ..lineTo(c.dx, c.dy - r * 0.75)
      ..lineTo(c.dx + r * 0.45, c.dy + r * 0.05)
      ..lineTo(c.dx + r * 1.05, c.dy - r * 0.45)
      ..lineTo(c.dx + r * 0.95, c.dy + r * 0.55)
      ..close();
    canvas.drawPath(crown, Paint()..color = gold);
    canvas.drawLine(
      Offset(c.dx - r * 0.88, c.dy + r * 0.8),
      Offset(c.dx + r * 0.88, c.dy + r * 0.8),
      Paint()
        ..color = gold
        ..strokeWidth = math.max(1.6, size.width * 0.04)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintShield(Canvas canvas, Size size, Offset c, {required bool withCross}) {
    final r = size.width * 0.27;
    final shield = Path()
      ..moveTo(c.dx - r * 0.85, c.dy - r * 0.85)
      ..lineTo(c.dx + r * 0.85, c.dy - r * 0.85)
      ..lineTo(c.dx + r * 0.85, c.dy + r * 0.05)
      ..quadraticBezierTo(c.dx + r * 0.75, c.dy + r * 0.75, c.dx, c.dy + r * 1.05)
      ..quadraticBezierTo(c.dx - r * 0.75, c.dy + r * 0.75, c.dx - r * 0.85, c.dy + r * 0.05)
      ..close();
    canvas.drawPath(shield, Paint()..color = color.withValues(alpha: 0.22));
    canvas.drawPath(
      shield,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.038),
    );
    if (withCross) {
      final p = Paint()
        ..color = color
        ..strokeWidth = math.max(1.5, size.width * 0.038)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(c.dx, c.dy - r * 0.5), Offset(c.dx, c.dy + r * 0.58), p);
      canvas.drawLine(Offset(c.dx - r * 0.42, c.dy - r * 0.08), Offset(c.dx + r * 0.42, c.dy - r * 0.08), p);
    } else {
      canvas.drawCircle(c, r * 0.3, Paint()..color = color);
    }
  }

  void _paintHexNode(Canvas canvas, Size size, Offset c) {
    final r = size.width * 0.28;
    final hex = Path();
    for (int i = 0; i < 6; i++) {
      final a = -math.pi / 2 + i * (math.pi / 3);
      final pt = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      if (i == 0) {
        hex.moveTo(pt.dx, pt.dy);
      } else {
        hex.lineTo(pt.dx, pt.dy);
      }
    }
    hex.close();
    canvas.drawPath(
      hex,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.038),
    );
    canvas.drawCircle(c, r * 0.32, Paint()..color = color);
  }

  void _paintAxisSignature(
    Canvas canvas,
    Size size,
    Offset c,
    double w,
    double h,
  ) {
    // 6-axis fingerprint radar derived mathematically from the current's real axes
    const sampleKeys = [
      'estrutura',
      'poder',
      'intervencao',
      'economia',
      'comercio',
      'moral',
    ];
    final outerR = w * 0.36;
    final innerR = w * 0.14;

    // Subtle concentric guide ring
    canvas.drawCircle(
      c,
      outerR,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final poly = Path();
    for (int i = 0; i < sampleKeys.length; i++) {
      final v = (axes[sampleKeys[i]] ?? 50.0).clamp(0.0, 100.0) / 100.0;
      final r = innerR + (outerR - innerR) * (0.25 + 0.75 * v);
      final angle = -math.pi / 2 + i * (2 * math.pi / sampleKeys.length);
      final pt = Offset(c.dx + math.cos(angle) * r, c.dy + math.sin(angle) * r);
      if (i == 0) {
        poly.moveTo(pt.dx, pt.dy);
      } else {
        poly.lineTo(pt.dx, pt.dy);
      }
    }
    poly.close();

    canvas.drawPath(
      poly,
      Paint()..color = color.withValues(alpha: isDark ? 0.28 : 0.18),
    );
    canvas.drawPath(
      poly,
      Paint()
        ..color = color.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    // Editorial serif/mono monogram in the center
    final tp = TextPainter(
      text: TextSpan(
        text: monogram,
        style: TextStyle(
          fontFamily: 'IBMPlexMono',
          fontSize: math.max(9.0, w * 0.25),
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: isDark ? Colors.white.withValues(alpha: 0.94) : color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CurrentEmblemPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.color != color ||
      oldDelegate.isDark != isDark ||
      oldDelegate.monogram != monogram;
}

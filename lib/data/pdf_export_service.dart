import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../domain/engine/atlas_and_nolan_engine.dart';
import '../domain/engine/compatibility_engine.dart';
import '../domain/models/atlas_models.dart';
import '../domain/models/political_models.dart';
import 'app_data.dart';

/// Serviço autônomo e 100% offline de geração e exportação de Dossiês em PDF
/// com o mapeamento cartográfico e ideológico integral do usuário.
abstract final class EspectroPdfService {
  static String _clean(String text) {
    return text
        .replaceAll('—', ' - ')
        .replaceAll('–', '-')
        .replaceAll('•', '*')
        .replaceAll('·', '|')
        .replaceAll('ś', 's')
        .replaceAll('ć', 'c')
        .replaceAll('ń', 'n')
        .replaceAll('ź', 'z')
        .replaceAll('ż', 'z')
        .replaceAll('ł', 'l')
        .replaceAll('Ś', 'S')
        .replaceAll('Ć', 'C')
        .replaceAll('Ń', 'N')
        .replaceAll('Ł', 'L')
        .replaceAll('σ', 'sigma')
        .replaceAll('μ', 'mu')
        .replaceAll('±', '+/-');
  }

  /// Gera os bytes binários do documento PDF formatado em 6 páginas.
  static Future<Uint8List> generateDossierBytes({
    required EvaluationRecord record,
    required AppData data,
  }) async {
    final pw.Document doc = pw.Document(
      title: 'Dossiê Espectro — ${record.suite.title}',
      author: 'Espectro Cartografia Política Multidimensional',
      creator: 'Espectro App',
    );

    final NolanCoordinates nolan = EspectroNolanEngine.fromEvaluation(
          axes: record.axes,
          triads: record.triads,
        ) ??
        const NolanCoordinates(
          economicFreedom: 50.0,
          personalFreedom: 50.0,
          economicSe: 15.0,
          personalSe: 15.0,
          quadrantLabel: 'Centrista / Equilíbrio Misto',
          quadrantDescription: 'Posição de equilíbrio pragmático.',
        );

    final CompatibilityReport compatReport =
        EspectroCompatibilityEngine.evaluate(
      catalog: data.catalog,
      axes: record.axes,
      triads: record.triads,
    );

    final List<AtlasMatchResult> countryMatches =
        EspectroAtlasEngine.rankEntries(
      entries: data.atlas.countries,
      axes: record.axes,
      triads: record.triads,
    );

    final List<AtlasMatchResult> personalityMatches =
        EspectroAtlasEngine.rankEntries(
      entries: data.atlas.personalities,
      axes: record.axes,
      triads: record.triads,
    );

    final BookRecommendationReport bookReport =
        EspectroAtlasEngine.recommendBooks(
      books: data.atlas.books,
      axes: record.axes,
      triads: record.triads,
    );

    final List<ThematicSynthesis> syntheses =
        EspectroAtlasEngine.computeSyntheses(
      axes: record.axes,
      triads: record.triads,
    );

    final List<DoctrinalTension> tensions =
        EspectroAtlasEngine.detectDoctrinalTensions(
      axes: record.axes,
      triads: record.triads,
    );

    // Definição de estilos tipográficos limpos
    const PdfColor primaryDark = PdfColor.fromInt(0xFF1E293B);
    const PdfColor accentBlue = PdfColor.fromInt(0xFF0F766E);
    const PdfColor accentLight = PdfColor.fromInt(0xFFCCFBF1);
    const PdfColor mutedGray = PdfColor.fromInt(0xFF64748B);
    const PdfColor surfaceMuted = PdfColor.fromInt(0xFFF1F5F9);
    const PdfColor lineGray = PdfColor.fromInt(0xFFE2E8F0);

    pw.Widget buildHeader(String pageTitle) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 14),
        padding: const pw.EdgeInsets.only(bottom: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: lineGray, width: 1),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text(
              'ESPECTRO · CARTOGRAFIA POLÍTICA MULTIDIMENSIONAL',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: accentBlue,
                letterSpacing: 1.2,
              ),
            ),
            pw.Text(
              pageTitle,
              style: const pw.TextStyle(
                fontSize: 8,
                color: mutedGray,
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildFooter(int pageNumber, int totalPages) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 14),
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: lineGray, width: 1),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text(
              'Documento gerado 100% offline no dispositivo · Sem telemetria',
              style: const pw.TextStyle(fontSize: 7.5, color: mutedGray),
            ),
            pw.Text(
              'Página $pageNumber de $totalPages',
              style: const pw.TextStyle(fontSize: 7.5, color: mutedGray),
            ),
          ],
        ),
      );
    }

    // =========================================================================
    // PÁGINA 1: Capa, Identificação e Diagrama de Nolan
    // =========================================================================
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              buildHeader('SUMÁRIO EXECUTIVO & NOLAN'),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: surfaceMuted,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: lineGray),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: <pw.Widget>[
                          pw.Text(
                            'DOSSIÊ POLÍTICO INDEPENDENTE',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: accentBlue,
                              letterSpacing: 1.5,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            record.suite.title,
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Profundidade: ${record.depth.label} · Avaliado em: ${record.createdAt.toIso8601String().substring(0, 10)}',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: mutedGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: accentLight,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        'ID: ${record.id.substring(0, math.min(8, record.id.length))}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'DIAGRAMA DE NOLAN (1969) & BÚSSOLA 2D',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: lineGray),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  children: <pw.Widget>[
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: <pw.Widget>[
                          pw.Text(
                            nolan.quadrantLabel,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: accentBlue,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            nolan.quadrantDescription,
                            style: const pw.TextStyle(
                              fontSize: 9.5,
                              color: primaryDark,
                              lineSpacing: 1.3,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            '* Liberdade Economica: ${nolan.economicFreedom.toStringAsFixed(1)}% (+/-${nolan.economicSe.toStringAsFixed(1)}%)',
                            style: const pw.TextStyle(fontSize: 9.5),
                          ),
                          pw.Text(
                            '* Liberdade Pessoal / Civil: ${nolan.personalFreedom.toStringAsFixed(1)}% (+/-${nolan.personalSe.toStringAsFixed(1)}%)',
                            style: const pw.TextStyle(fontSize: 9.5),
                          ),
                          pw.Text(
                            '* Bussola Cartesiana: X = ${nolan.compassEconomicX.toStringAsFixed(1)} | Y = ${nolan.compassCivilY.toStringAsFixed(1)}',
                            style: const pw.TextStyle(
                              fontSize: 9.5,
                              color: mutedGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        height: 130,
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: surfaceMuted,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: <pw.Widget>[
                            pw.Text(
                              'LIBERDADE PESSOAL: ${nolan.personalFreedom.round()}%',
                              style: pw.TextStyle(
                                fontSize: 7,
                                fontWeight: pw.FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: <pw.Widget>[
                                pw.Text(
                                  'ESQ',
                                  style: const pw.TextStyle(
                                    fontSize: 7,
                                    color: mutedGray,
                                  ),
                                ),
                                pw.Container(
                                  width: 80,
                                  height: 80,
                                  margin: const pw.EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: primaryDark,
                                      width: 1,
                                    ),
                                    color: PdfColors.white,
                                  ),
                                  child: pw.Stack(
                                    children: <pw.Widget>[
                                      pw.Center(
                                        child: pw.Container(
                                          width: 78,
                                          height: 1,
                                          color: lineGray,
                                        ),
                                      ),
                                      pw.Center(
                                        child: pw.Container(
                                          width: 1,
                                          height: 78,
                                          color: lineGray,
                                        ),
                                      ),
                                      pw.Positioned(
                                        left: (nolan.economicFreedom / 100.0) *
                                                72.0 +
                                            2.0,
                                        bottom: (nolan.personalFreedom / 100.0) *
                                                72.0 +
                                            2.0,
                                        child: pw.Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const pw.BoxDecoration(
                                            color: accentBlue,
                                            shape: pw.BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.Text(
                                  'DIR',
                                  style: const pw.TextStyle(
                                    fontSize: 7,
                                    color: mutedGray,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              'LIBERDADE ECONÔMICA: ${nolan.economicFreedom.round()}%',
                              style: pw.TextStyle(
                                fontSize: 7,
                                fontWeight: pw.FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'PRINCIPAIS AFINIDADES GLOBAIS',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 8),
              if (compatReport.ranked.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: lineGray),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: <pw.Widget>[
                          pw.Text(
                            '1º Corrente Ideológica: ${compatReport.primaryMatch?.current.name ?? "-"}',
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                          pw.Text(
                            '${compatReport.primaryMatch?.compatibilityPercent.toStringAsFixed(1)}% compatibilidade',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: accentBlue,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        compatReport.primaryMatch?.current.summary ?? '',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: mutedGray,
                          lineSpacing: 1.25,
                        ),
                      ),
                      if (compatReport.isLowDiscrimination) ...<pw.Widget>[
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Aviso de Metodologia: Detectada baixa discriminacao entre alternativas (respostas a polos opostos em ${compatReport.tensionAxisCount} eixos). Proximidade calculada indica vizinhanca geometrica, nao adesao dogmatica.',
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            color: accentBlue,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              pw.Spacer(),
              buildFooter(1, 6),
            ],
          );
        },
      ),
    );

    // =========================================================================
    // PÁGINA 2: Mapeamento Detalhado dos 12 Eixos Contínuos
    // =========================================================================
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          final List<BipolarDimensionScore> axes = record.axes;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              buildHeader('MAPEAMENTO DOS 12 EIXOS POLÍTICOS'),
              pw.Text(
                'MENSURAÇÃO MULTIDIMENSIONAL BIPOLAR',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Cada eixo contínuo varia entre -1.0 (polo esquerdo a 100%) e +1.0 (polo direito a 100%).',
                style: const pw.TextStyle(fontSize: 8.5, color: mutedGray),
              ),
              pw.SizedBox(height: 10),
              if (axes.isEmpty)
                pw.Center(
                  child: pw.Text(
                    'Esta modalidade não incluiu o questionário de eixos bipolares.',
                    style: const pw.TextStyle(fontSize: 10, color: mutedGray),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: lineGray, width: 0.5),
                  columnWidths: const <int, pw.TableColumnWidth>{
                    0: pw.FlexColumnWidth(2.6),
                    1: pw.FlexColumnWidth(2.2),
                    2: pw.FlexColumnWidth(3.0),
                    3: pw.FlexColumnWidth(2.2),
                  },
                  children: <pw.TableRow>[
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: surfaceMuted),
                      children: <pw.Widget>[
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Dimensão',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Polo Esquerdo (0%)',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Proporção Avaliada',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Polo Direito (100%)',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (final BipolarDimensionScore ax in axes)
                      pw.TableRow(
                        children: <pw.Widget>[
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.5),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: <pw.Widget>[
                                pw.Text(
                                  ax.label,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  'Score: ${ax.score >= 0 ? "+" : ""}${ax.score.toStringAsFixed(2)}',
                                  style: const pw.TextStyle(
                                    fontSize: 7,
                                    color: mutedGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.5),
                            child: pw.Text(
                              ax.leftPole,
                              style: const pw.TextStyle(fontSize: 7.5),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            child: pw.Column(
                              children: <pw.Widget>[
                                pw.Container(
                                  height: 8,
                                  decoration: pw.BoxDecoration(
                                    color: surfaceMuted,
                                    borderRadius: pw.BorderRadius.circular(4),
                                    border: pw.Border.all(
                                      color: lineGray,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: pw.Stack(
                                    children: <pw.Widget>[
                                      pw.Container(
                                        width: ((ax.score + 1.0) / 2.0) * 110.0,
                                        decoration: pw.BoxDecoration(
                                          color: accentBlue,
                                          borderRadius:
                                              pw.BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  '${(ax.leftPercent).round()}% / ${(ax.rightPercent).round()}%',
                                  style: const pw.TextStyle(
                                    fontSize: 6.5,
                                    color: mutedGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.5),
                            child: pw.Text(
                              ax.rightPole,
                              style: const pw.TextStyle(fontSize: 7.5),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              pw.Spacer(),
              buildFooter(2, 6),
            ],
          );
        },
      ),
    );

    // =========================================================================
    // PÁGINA 3: Espaço Baricêntrico das 6 Tríades
    // =========================================================================
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          final List<TriadDimensionScore> triads = record.triads;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              buildHeader('ESPAÇO BARICÊNTRICO DAS 6 TRÍADES'),
              pw.Text(
                'SIMPLEX TERNÁRIO E DISTRIBUIÇÃO TRIPARTITE',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Cada tríade avalia três vértices ideológicos simultâneos cuja soma das frações resulta exatamente em 100%.',
                style: const pw.TextStyle(fontSize: 8.5, color: mutedGray),
              ),
              pw.SizedBox(height: 12),
              if (triads.isEmpty)
                pw.Center(
                  child: pw.Text(
                    'Esta modalidade não incluiu o questionário de tríades baricêntricas.',
                    style: const pw.TextStyle(fontSize: 10, color: mutedGray),
                  ),
                )
              else
                pw.Column(
                  children: <pw.Widget>[
                    for (final TriadDimensionScore tr in triads)
                      pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: lineGray),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: <pw.Widget>[
                            pw.Expanded(
                              flex: 3,
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: <pw.Widget>[
                                  pw.Text(
                                    tr.label,
                                    style: pw.TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: primaryDark,
                                    ),
                                  ),
                                  pw.Text(
                                    'Dominante: ${tr.dominantVertexName} | I = ${(tr.engagement * 100).round()}% | Conf: ${tr.confidenceLabel}',
                                    style: const pw.TextStyle(
                                      fontSize: 7,
                                      color: accentBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Expanded(
                              flex: 5,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceAround,
                                children: <pw.Widget>[
                                  for (var v = 0; v < 3; v++)
                                    pw.Column(
                                      children: <pw.Widget>[
                                        pw.Text(
                                          tr.vertices[v],
                                          style: const pw.TextStyle(
                                            fontSize: 7.5,
                                          ),
                                        ),
                                        pw.SizedBox(height: 2),
                                        pw.Text(
                                          '${(tr.composition[v] * 100).toStringAsFixed(1)}%',
                                          style: pw.TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: pw.FontWeight.bold,
                                            color: v == tr.dominantVertexIndex
                                                ? accentBlue
                                                : primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              pw.Spacer(),
              buildFooter(3, 6),
            ],
          );
        },
      ),
    );

    // =========================================================================
    // PÁGINA 4: Diagnóstico Doutrinário, Sínteses e Antípoda
    // =========================================================================
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          final AtlasMatchResult? antipodCountry =
              countryMatches.isNotEmpty ? countryMatches.last : null;
          final AtlasMatchResult? antipodThinker =
              personalityMatches.isNotEmpty ? personalityMatches.last : null;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              buildHeader('DIAGNÓSTICO DOUTRINÁRIO & ANTÍPODA'),
              pw.Text(
                'SÍNTESES DE VALORES POLÍTICOS NOMEADAS',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <pw.Widget>[
                  for (final ThematicSynthesis s in syntheses.take(4))
                    pw.Container(
                      width: 250,
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: surfaceMuted,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: lineGray),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: <pw.Widget>[
                          pw.Text(
                            s.arena.toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              color: accentBlue,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            s.title,
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            s.summary,
                            style: const pw.TextStyle(
                              fontSize: 7.5,
                              color: mutedGray,
                              lineSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                'TENSÕES DOUTRINÁRIAS & COERÊNCIA IDEOLÓGICA',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 6),
              if (tensions.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: lineGray),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    'Alta consistência doutrinária: não foram identificadas posições contraditórias entre os eixos avaliados.',
                    style: const pw.TextStyle(fontSize: 8.5, color: primaryDark),
                  ),
                )
              else
                for (final DoctrinalTension t in tensions)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: lineGray),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Text(
                          t.title,
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          t.description,
                          style: const pw.TextStyle(
                            fontSize: 7.5,
                            color: mutedGray,
                          ),
                        ),
                      ],
                    ),
                  ),
              pw.SizedBox(height: 14),
              pw.Text(
                'SEU ANTÍPODA POLÍTICO (MENOR AFINIDADE)',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: surfaceMuted,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: lineGray),
                ),
                child: pw.Row(
                  children: <pw.Widget>[
                    if (antipodCountry != null)
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Text(
                              'Modelo de País Mais Distante',
                              style: const pw.TextStyle(
                                fontSize: 7,
                                color: mutedGray,
                              ),
                            ),
                            pw.Text(
                              antipodCountry.entry.name,
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              '${antipodCountry.compatibilityPercent.toStringAsFixed(1)}% compatibilidade',
                              style: const pw.TextStyle(
                                fontSize: 7.5,
                                color: accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (antipodThinker != null)
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Text(
                              'Pensador Mais Distante',
                              style: const pw.TextStyle(
                                fontSize: 7,
                                color: mutedGray,
                              ),
                            ),
                            pw.Text(
                              antipodThinker.entry.name,
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              '${antipodThinker.compatibilityPercent.toStringAsFixed(1)}% compatibilidade',
                              style: const pw.TextStyle(
                                fontSize: 7.5,
                                color: accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              pw.Spacer(),
              buildFooter(4, 6),
            ],
          );
        },
      ),
    );

    // =========================================================================
    // PÁGINA 5: Atlas Político (Correntes, Países e Pensadores)
    // =========================================================================
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              buildHeader('ATLAS POLÍTICO: PAÍSES & PERSONALIDADES'),
              pw.Text(
                'MODELOS DE PAÍSES MAIS PRÓXIMOS (TOP 4)',
                style: pw.TextStyle(
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 6),
              for (final AtlasMatchResult m in countryMatches.take(4))
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.all(7),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: lineGray),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Text(
                              _clean(m.entry.name),
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                            pw.Text(
                              _clean('${m.entry.era} · ${m.entry.category}'),
                              style: const pw.TextStyle(
                                fontSize: 7,
                                color: mutedGray,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              _clean(m.entry.summary),
                              maxLines: 2,
                              style: const pw.TextStyle(
                                fontSize: 7.5,
                                color: primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        '${m.compatibilityPercent.toStringAsFixed(1)}%',
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: accentBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              pw.SizedBox(height: 12),
              pw.Text(
                'PERSONALIDADES HISTÓRICAS & TEÓRICOS (TOP 4)',
                style: pw.TextStyle(
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 6),
              for (final AtlasMatchResult m in personalityMatches.take(4))
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.all(7),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: lineGray),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Text(
                              _clean(m.entry.name),
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                            pw.Text(
                              _clean('${m.entry.subtitle} (${m.entry.era})'),
                              style: const pw.TextStyle(
                                fontSize: 7,
                                color: mutedGray,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              _clean(m.entry.summary),
                              maxLines: 2,
                              style: const pw.TextStyle(
                                fontSize: 7.5,
                                color: primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        '${m.compatibilityPercent.toStringAsFixed(1)}%',
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: accentBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              pw.Spacer(),
              buildFooter(5, 6),
            ],
          );
        },
      ),
    );

    // =========================================================================
    // PÁGINA 6: Biblioteca Recomendada & Metodologia
    // =========================================================================
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              buildHeader('BIBLIOTECA DIALÉTICA & METODOLOGIA'),
              pw.Text(
                'LEITURAS DE AFINIDADE (APROFUNDAMENTO)',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 4),
              for (final AtlasMatchResult b in bookReport.affinityBooks.take(3))
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    color: surfaceMuted,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: <pw.Widget>[
                      pw.Expanded(
                        child: pw.Text(
                          _clean('${b.entry.name} - ${b.entry.subtitle}'),
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Text(
                        '${b.compatibilityPercent.toStringAsFixed(0)}% afinidade',
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          color: accentBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              pw.SizedBox(height: 8),
              pw.Text(
                'LEITURAS DE CONTRAPONTO DIALÉTICO (ANTI-BOLHA)',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 4),
              for (final AtlasMatchResult b
                  in bookReport.counterpointBooks.take(3))
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: lineGray),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: <pw.Widget>[
                      pw.Expanded(
                        child: pw.Text(
                          _clean('${b.entry.name} - ${b.entry.subtitle}'),
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Text(
                        'Contraponto dialético',
                        style: const pw.TextStyle(
                          fontSize: 7.5,
                          color: mutedGray,
                        ),
                      ),
                    ],
                  ),
                ),
              pw.SizedBox(height: 12),
              pw.Text(
                'METODOLOGIA MATEMÁTICA & PRIVACIDADE',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.1,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: lineGray),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      '* Metrica de Proximidade: z_d = dist(x_d, mu_d) / sqrt(sigma_d^2 + SE_d^2) com D^2 = Sigma(rel_d * z_d^2) / Sigma(rel_d). '
                      'A compatibilidade ideologica final segue a transformacao gaussiana: C = 100 * exp(-D^2 / 2).',
                      style: const pw.TextStyle(fontSize: 7.5, color: primaryDark),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      '* Distancia Triangular Elevada: d_comp = ||p - mu||_2 / sqrt(2), com penalidade de engajamento absoluto '
                      'g = clamp((|I - 0.5| - 0.15) / 0.35, 0, 1) e distancia total d = sqrt(d_comp^2 + 0.16 * g^2). '
                      'Diferencia apoio pleno de rejeicao plena e nao inventa intensidade para perfis de referencia.',
                      style: const pw.TextStyle(fontSize: 7.5, color: primaryDark),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      '* Diagnostico de Consistencia: Respostas mutuamente excludentes em metade ou mais dos eixos ativam o aviso '
                      'de baixa discriminacao sem punir o respondente. Dimensoes com itens insuficientes sao marcadas como indeterminadas.',
                      style: const pw.TextStyle(fontSize: 7.5, color: primaryDark),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      '* Privacidade e Soberania Local: O motor opera 100% offline, sem backend obrigatorio e sem telemetria. '
                      'Respostas e historico permanecem exclusivamente na memoria interna criptografada do seu dispositivo.',
                      style: const pw.TextStyle(fontSize: 7.5, color: primaryDark),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),
              buildFooter(6, 6),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  /// Salva o PDF no armazenamento temporário/documentos do aparelho e aciona
  /// o compartilhamento nativo do Android via SharePlus.
  static Future<String> exportAndSharePdf({
    required EvaluationRecord record,
    required AppData data,
  }) async {
    final Uint8List bytes = await generateDossierBytes(
      record: record,
      data: data,
    );
    final String cleanId = record.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile.fromData(
              bytes,
              mimeType: 'application/pdf',
              name: 'Espectro_Dossie_$cleanId.pdf',
            ),
          ],
          fileNameOverrides: <String>['Espectro_Dossie_$cleanId.pdf'],
          subject: 'Dossiê Político Espectro — ${record.suite.title}',
          text: 'Confira meu dossiê de avaliação política multidimensional gerado no Espectro.',
        ),
      );
      return 'Espectro_Dossie_$cleanId.pdf';
    }

    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath = '${dir.path}/Espectro_Dossie_$cleanId.pdf';
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          XFile(
            filePath,
            mimeType: 'application/pdf',
            name: 'Espectro_Dossie_$cleanId.pdf',
          ),
        ],
        subject: 'Dossiê Político Espectro — ${record.suite.title}',
        text: 'Confira meu dossiê de avaliação política multidimensional gerado no Espectro.',
      ),
    );

    return filePath;
  }
}

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/engine/atlas_and_nolan_engine.dart';
import '../../../domain/engine/compatibility_engine.dart';
import '../../../domain/models/atlas_models.dart';
import '../../../domain/models/political_models.dart';
import '../../../domain/models/study_result_link.dart';
import '../../../domain/models/study_link_uri.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../charts/nolan_diagram_chart.dart';
import '../../view_models/app_view_model.dart';

/// Modal para visualização, personalização e exportação de cards compartilháveis
/// em alta resolução (Stories 9:16 ou Post 1:1) com captura nativa via RepaintBoundary.
class ShareableCardSheet extends StatefulWidget {
  const ShareableCardSheet({
    required this.record,
    required this.appViewModel,
    super.key,
  });

  final EvaluationRecord record;
  final AppViewModel appViewModel;

  static Future<void> show(
    BuildContext context, {
    required EvaluationRecord record,
    required AppViewModel appViewModel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) =>
          ShareableCardSheet(record: record, appViewModel: appViewModel),
    );
  }

  @override
  State<ShareableCardSheet> createState() => _ShareableCardSheetState();
}

class _ShareableCardSheetState extends State<ShareableCardSheet> {
  final GlobalKey _cardRepaintKey = GlobalKey();
  bool _isStoryFormat = false; // false = 1:1 (Post), true = 9:16 (Story)
  bool _isExporting = false;

  Future<void> _copyReopenableResult() async {
    String token;
    try {
      token = encodeStudyResult(widget.record);
    } on FormatException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Este resultado é grande demais ou incompatível com um link. Use o card para compartilhar.',
            ),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    final String route = Uri(
      path: '/shared',
      queryParameters: <String, String>{'v': '1', 'data': token},
    ).toString();
    final String link = buildPublicStudyLink(route);
    final bool completeLink = Uri.parse(link).hasScheme;
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Copiar minhas respostas no link?'),
            content: Text(
              'Os dados copiados incluem suas respostas individuais, título, data e resultados. '
              'Qualquer pessoa com acesso poderá ler esses dados e reabrir a avaliação. '
              '${completeLink ? '' : 'Para obter um link completo, use a versão web. Neste app, será copiada a rota com os dados para reabrir. '}'
              'A cópia só acontece ao confirmar abaixo.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Copiar link com minhas respostas'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    try {
      await Clipboard.setData(ClipboardData(text: link));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              completeLink
                  ? 'Link com suas respostas copiado. Compartilhe somente com quem você deseja.'
                  : 'Dados para reabrir copiados. Para obter um link completo, use a versão web.',
            ),
          ),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível copiar o link para a área de transferência.',
            ),
          ),
        );
      }
    }
  }

  Future<Uint8List?> _capturePngBytes() async {
    try {
      final RenderRepaintBoundary? boundary =
          _cardRepaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _shareCardImage() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final Uint8List? bytes = await _capturePngBytes();
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha ao renderizar card visual.')),
          );
        }
        return;
      }

      if (kIsWeb) {
        await SharePlus.instance.share(
          ShareParams(
            files: <XFile>[
              XFile.fromData(
                bytes,
                mimeType: 'image/png',
                name: 'espectro_resultado.png',
              ),
            ],
            fileNameOverrides: <String>['espectro_resultado.png'],
            text: 'Meu resultado no Espectro Político Multidimensional.',
          ),
        );
        return;
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/espectro_card_${widget.record.id.substring(0, 8)}.png';
      final File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile(
              filePath,
              mimeType: 'image/png',
              name: 'espectro_resultado.png',
            ),
          ],
          text: 'Meu resultado no Espectro Político Multidimensional.',
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _saveCardToDevice() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final Uint8List? bytes = await _capturePngBytes();
      if (bytes == null) return;

      if (kIsWeb) {
        await SharePlus.instance.share(
          ShareParams(
            files: <XFile>[
              XFile.fromData(
                bytes,
                mimeType: 'image/png',
                name: 'espectro_${widget.record.id.substring(0, 8)}.png',
              ),
            ],
            fileNameOverrides: <String>[
              'espectro_${widget.record.id.substring(0, 8)}.png',
            ],
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download do card iniciado no navegador.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      final Directory docDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${docDir.path}/espectro_${widget.record.id.substring(0, 8)}.png';
      final File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card salvo com sucesso em:\n$filePath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    final NolanCoordinates nolan =
        EspectroNolanEngine.fromEvaluation(
          axes: widget.record.axes,
          triads: widget.record.triads,
        ) ??
        const NolanCoordinates(
          economicFreedom: 50.0,
          personalFreedom: 50.0,
          economicSe: 15.0,
          personalSe: 15.0,
          quadrantLabel: 'Centro',
          quadrantDescription: 'Equilíbrio',
        );

    final CompatibilityReport report = EspectroCompatibilityEngine.evaluate(
      catalog: widget.appViewModel.data.catalog,
      axes: widget.record.axes,
      triads: widget.record.triads,
    );

    final List<AtlasMatchResult> countryMatches =
        EspectroAtlasEngine.rankEntries(
          entries: widget.appViewModel.data.atlas.countries,
          axes: widget.record.axes,
          triads: widget.record.triads,
        );

    final List<AtlasMatchResult> personalityMatches =
        EspectroAtlasEngine.rankEntries(
          entries: widget.appViewModel.data.atlas.personalities,
          axes: widget.record.axes,
          triads: widget.record.triads,
        );

    final BookRecommendationReport bookReport =
        EspectroAtlasEngine.recommendBooks(
          books: widget.appViewModel.data.atlas.books,
          axes: widget.record.axes,
          triads: widget.record.triads,
        );

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Barra de arrasto
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: p.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Card Compartilhável',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Post 1:1', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text(
                          'Story 9:16',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                    selected: <bool>{_isStoryFormat},
                    onSelectionChanged: (Set<bool> sel) {
                      setState(() => _isStoryFormat = sel.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Card visual renderizado via RepaintBoundary
              Center(
                child: RepaintBoundary(
                  key: _cardRepaintKey,
                  child: Container(
                    width: 320,
                    height: _isStoryFormat ? 520 : 380,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.line, width: 1.5),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: p.ink.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Header
                        Row(
                          children: <Widget>[
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: p.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.explore_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'ESPECTRO',
                                  style: text.labelSmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.2,
                                    color: p.ink,
                                  ),
                                ),
                                Text(
                                  'cartografia política multidimensional',
                                  style: text.bodySmall?.copyWith(
                                    fontSize: 8,
                                    color: p.muted,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: p.accentSoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.record.suite.title,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: p.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Nolan badge e posição
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: p.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: p.line),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      nolan.quadrantLabel,
                                      style: text.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: p.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Econômica: ${nolan.economicFreedom.round()}% · Pessoal: ${nolan.personalFreedom.round()}%',
                                      style: text.bodySmall?.copyWith(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: NolanDiagramChart(
                                  coordinates: nolan,
                                  showModeSwitch: false,
                                  maxSize: 54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Corrente Ideológica Dominante
                        if (report.primaryMatch != null) ...<Widget>[
                          Text(
                            'CORRENTE MAIS PRÓXIMA',
                            style: text.labelSmall?.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: p.muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  report.primaryMatch!.current.name,
                                  style: text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Tag(
                                label:
                                    '${report.primaryMatch!.compatibilityPercent.toStringAsFixed(0)}% afinidade',
                                background: p.accentSoft,
                                foreground: p.accent,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        // País e Personalidade
                        Row(
                          children: <Widget>[
                            if (countryMatches.isNotEmpty)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: p.surfaceMuted,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'PAÍS / MODELO',
                                        style: TextStyle(
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                          color: p.muted,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        countryMatches.first.entry.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${countryMatches.first.compatibilityPercent.toStringAsFixed(0)}% afinidade',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: p.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(width: 6),
                            if (personalityMatches.isNotEmpty)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: p.surfaceMuted,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'PENSADOR / LÍDER',
                                        style: TextStyle(
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                          color: p.muted,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        personalityMatches.first.entry.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${personalityMatches.first.compatibilityPercent.toStringAsFixed(0)}% afinidade',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: p.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Se formato Story (mais alto), adiciona contraponto e eixos
                        if (_isStoryFormat) ...<Widget>[
                          const SizedBox(height: 10),
                          if (bookReport.counterpointBooks.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: p.line),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.auto_stories_rounded,
                                    size: 16,
                                    color: p.accent,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'LEITURA DE CONTRAPONTO',
                                          style: TextStyle(
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                            color: p.muted,
                                          ),
                                        ),
                                        Text(
                                          bookReport
                                              .counterpointBooks
                                              .first
                                              .entry
                                              .name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'PRINCIPAIS TENDÊNCIAS EM EIXOS',
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              color: p.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          for (final BipolarDimensionScore ax
                              in widget.record.axes.take(4))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    ax.label,
                                    style: const TextStyle(fontSize: 8),
                                  ),
                                  Text(
                                    ax.score < 0
                                        ? '${ax.leftPercent.round()}% ${ax.leftPole}'
                                        : '${ax.rightPercent.round()}% ${ax.rightPole}',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: p.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        const Spacer(),
                        // Rodapé do card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '100% OFFLINE · SEM RÓTULOS FORÇADOS',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                                color: p.muted,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'espectro.app',
                              style: TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                                color: p.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Reabrir esta avaliação', style: text.titleSmall),
              ),
              const SizedBox(height: 6),
              Text(
                'O link contém suas respostas individuais e os resultados. Você escolhe quando copiar e com quem compartilhar.',
                style: text.bodySmall?.copyWith(color: p.muted),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Copiar link com minhas respostas',
                icon: Icons.link,
                kind: AppButtonKind.outline,
                onPressed: _copyReopenableResult,
              ),
              const SizedBox(height: 20),
              // Botões de ação
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton(
                      label: _isExporting ? 'Salvando...' : 'Salvar Imagem',
                      kind: AppButtonKind.outline,
                      icon: Icons.download_rounded,
                      onPressed: _isExporting ? () {} : _saveCardToDevice,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: _isExporting ? 'Processando...' : 'Compartilhar',
                      kind: AppButtonKind.filled,
                      icon: Icons.share_rounded,
                      onPressed: _isExporting ? () {} : _shareCardImage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

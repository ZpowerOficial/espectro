import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/political_models.dart';
import '../../../domain/models/study_result_link.dart';
import '../../../domain/models/study_link_uri.dart';
import '../../../theme.dart';
import '../../view_models/app_view_model.dart';
import 'share_card_content.dart';
import 'share_card_export.dart';

/// Preview and PNG export use the same fixed canvas; the surrounding controls
/// remain responsive and respect the device text scale.
class ShareableCardSheet extends StatefulWidget {
  const ShareableCardSheet({
    required this.record,
    required this.appViewModel,
    this.exporter = const ShareCardExporter(),
    super.key,
  });
  final EvaluationRecord record;
  final AppViewModel appViewModel;
  final ShareCardExporter exporter;

  static Future<void> show(
    BuildContext context, {
    required EvaluationRecord record,
    required AppViewModel appViewModel,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        ShareableCardSheet(record: record, appViewModel: appViewModel),
  );

  @override
  State<ShareableCardSheet> createState() => _ShareableCardSheetState();
}

class _ShareableCardSheetState extends State<ShareableCardSheet> {
  final GlobalKey _cardRepaintKey = GlobalKey();
  bool _isStoryFormat = false;
  bool _showDiscovery = false;
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

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _copyEntryLink() async {
    final link = shareCardEntryLink();
    if (link == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: link));
      _message(
        'Link de entrada copiado. Ele não contém seu resultado nem suas respostas.',
      );
    } on Object {
      _message('Não foi possível copiar o link. Tente novamente.');
    }
  }

  Future<void> _export({required bool share}) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final Uint8List bytes = await captureShareCardPng(_cardRepaintKey);
      if (!mounted) return;
      // No record ID or answer is put in the filename or share URL.
      final filename = _isStoryFormat
          ? 'espectro-story.png'
          : 'espectro-post.png';
      if (share) {
        final String? feedback = await widget.exporter.share(
          bytes,
          filename,
          entryLink: shareCardEntryLink(),
        );
        if (feedback != null && feedback.isNotEmpty) {
          _message(feedback);
        }
      } else {
        final destination = await widget.exporter.save(bytes, filename);
        _message(destination);
      }
    } on Object {
      _message(
        share
            ? 'Não foi possível compartilhar o cartão. Você pode tentar salvar a imagem.'
            : 'Não foi possível salvar o cartão. Verifique o espaço e as permissões e tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final evidence = ShareCardEvidence.fromRecord(widget.record);
    final entryLink = shareCardEntryLink();
    final size = shareCardLogicalSize(story: _isStoryFormat);
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cartão compartilhável',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Post 1:1'),
                        selected: !_isStoryFormat,
                        onSelected: _isExporting
                            ? null
                            : (_) => setState(() => _isStoryFormat = false),
                      ),
                      ChoiceChip(
                        label: const Text('Story 9:16'),
                        selected: _isStoryFormat,
                        onSelected: _isExporting
                            ? null
                            : (_) => setState(() => _isStoryFormat = true),
                      ),
                    ],
                  ),
                  if (evidence.discoveryAxis != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Meu retrato'),
                          selected: !_showDiscovery,
                          onSelected: _isExporting
                              ? null
                              : (_) => setState(() => _showDiscovery = false),
                        ),
                        ChoiceChip(
                          label: const Text(
                            'Minha descoberta mais surpreendente',
                          ),
                          selected: _showDiscovery,
                          onSelected: _isExporting
                              ? null
                              : (_) => setState(() => _showDiscovery = true),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'A imagem contém somente o resumo mostrado abaixo. Ao salvar ou compartilhar, você exporta essas informações políticas. '
                    'O link de entrada não leva respostas pessoais.',
                    style: TextStyle(color: p.inkSoft),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) => Center(
                      child: SizedBox(
                        width: constraints.maxWidth.clamp(0, size.width),
                        height:
                            size.height *
                            (constraints.maxWidth / size.width).clamp(0, 1),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: RepaintBoundary(
                            key: _cardRepaintKey,
                            child: ShareCardCanvas(
                              record: widget.record,
                              data: widget.appViewModel.data,
                              story: _isStoryFormat,
                              discovery: _showDiscovery,
                              entryLink: entryLink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isStoryFormat
                        ? 'PNG 1080 × 1920 · Story 9:16'
                        : 'PNG 1080 × 1080 · Post 1:1',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.inkSoft),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        key: const ValueKey('save-share-card'),
                        onPressed: _isExporting
                            ? null
                            : () => _export(share: false),
                        icon: const Icon(Icons.download_rounded),
                        label: Text(
                          _isExporting ? 'Processando…' : 'Salvar imagem',
                        ),
                      ),
                      FilledButton.icon(
                        key: const ValueKey('share-share-card'),
                        onPressed: _isExporting
                            ? null
                            : () => _export(share: true),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Compartilhar imagem'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Convide alguém a explorar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  if (entryLink != null)
                    OutlinedButton.icon(
                      onPressed: _copyEntryLink,
                      icon: const Icon(Icons.link),
                      label: const Text('Copiar link de entrada sem resultado'),
                    )
                  else
                    Text(
                      'O endereço público ainda não está configurado nesta versão. A imagem pode ser exportada offline.',
                      style: TextStyle(color: p.inkSoft),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Reabrir esta avaliação',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Esta opção separada inclui respostas individuais, data e resultados no link. A cópia exige confirmação.',
                    style: TextStyle(color: p.inkSoft),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _copyReopenableResult,
                    icon: const Icon(Icons.link),
                    label: const Text('Copiar link com minhas respostas'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

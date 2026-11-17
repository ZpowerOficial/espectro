import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/raio_x_diagnostic.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';

/// Card interativo do Raio-X de Convergências e Divergências.
///
/// Apresenta os três blocos metodológicos:
/// 1. Onde vocês se aproximam;
/// 2. Onde vocês divergem;
/// 3. O que diferencia essas posições.
///
/// Permite leitura inicial rápida com expansão sob demanda para conferência
/// dos números, contribuição matemática e notas do acervo primário.
class RaioXDiagnosticCard extends StatefulWidget {
  const RaioXDiagnosticCard({
    required this.diagnostic,
    this.initialExpanded = false,
    super.key,
  });

  final RaioXDiagnostic diagnostic;
  final bool initialExpanded;

  @override
  State<RaioXDiagnosticCard> createState() => _RaioXDiagnosticCardState();
}

class _RaioXDiagnosticCardState extends State<RaioXDiagnosticCard> {
  late bool _expanded;
  final Set<String> _expandedItems = <String>{};

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  void _toggleItem(String dimId) {
    setState(() {
      if (_expandedItems.contains(dimId)) {
        _expandedItems.remove(dimId);
      } else {
        _expandedItems.add(dimId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final diag = widget.diagnostic;

    if (diag.insufficientEvidence) {
      return SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.info_outline_rounded, size: 20, color: p.muted),
                const SizedBox(width: 8),
                const Expanded(
                  child: Eyebrow('RAIO-X: EVIDÊNCIA INSUFICIENTE'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Não há sobreposição suficiente para traçar um diagnóstico detalhado.',
              style: text.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              diag.insufficientEvidenceReason ??
                  'Menos de 4 dimensões foram respondidas em comum com este perfil.',
              style: text.bodySmall?.copyWith(color: p.muted),
            ),
          ],
        ),
      );
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Cabeçalho do Card
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.compare_arrows_rounded, color: p.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Eyebrow('DIAGNÓSTICO ESTRUTURADO'),
                    const SizedBox(height: 4),
                    Text(
                      'Raio-X: Você e ${diag.targetName}',
                      style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${diag.evaluatedDimensionsCount} dimensões comparadas',
                      style: text.bodySmall?.copyWith(color: p.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _expanded ? Icons.unfold_less_rounded : Icons.unfold_more_rounded,
                  size: 20,
                  color: p.muted,
                ),
                tooltip: _expanded ? 'Recolher detalhes' : 'Expandir todos os detalhes',
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // -------------------------------------------------------------
          // BLOCO 1: Onde vocês se aproximam
          // -------------------------------------------------------------
          _buildBlockHeader(
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF10B981),
            title: diag.approachingSection.title,
            subtitle: diag.approachingSection.description,
            text: text,
            p: p,
          ),
          const SizedBox(height: 10),
          if (diag.approachingSection.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Nenhuma dimensão apresentou proximidade estatística relevante.',
                style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: p.muted),
              ),
            )
          else
            ...diag.approachingSection.items.map(
              (item) => _buildDimensionItemTile(
                item: item,
                isConvergence: true,
                isExpanded: _expanded || _expandedItems.contains(item.dimensionId),
                onTap: () => _toggleItem(item.dimensionId),
                text: text,
                p: p,
              ),
            ),
          const SizedBox(height: 22),

          // -------------------------------------------------------------
          // BLOCO 2: Onde vocês divergem
          // -------------------------------------------------------------
          _buildBlockHeader(
            icon: Icons.alt_route_rounded,
            color: const Color(0xFFF59E0B),
            title: diag.divergingSection.title,
            subtitle: diag.divergingSection.description,
            text: text,
            p: p,
          ),
          const SizedBox(height: 10),
          if (diag.divergingSection.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Nenhuma divergência acentuada foi identificada nas dimensões comuns observadas.',
                style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: p.muted),
              ),
            )
          else
            ...diag.divergingSection.items.map(
              (item) => _buildDimensionItemTile(
                item: item,
                isConvergence: false,
                isExpanded: _expanded || _expandedItems.contains(item.dimensionId),
                onTap: () => _toggleItem(item.dimensionId),
                text: text,
                p: p,
              ),
            ),
          const SizedBox(height: 24),

          // -------------------------------------------------------------
          // BLOCO 3: O que diferencia essas posições
          // -------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.psychology_outlined, size: 18, color: p.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'O que diferencia essas posições',
                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  diag.conceptualDifferentiation,
                  style: text.bodyMedium?.copyWith(height: 1.42),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Disclaimer de Integridade Epistêmica
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.shield_outlined, size: 14, color: p.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  diag.methodologicalDisclaimer,
                  style: text.bodySmall?.copyWith(
                    fontSize: 11,
                    color: p.muted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockHeader({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required TextTheme text,
    required EspectroPalette p,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: text.bodySmall?.copyWith(color: p.muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDimensionItemTile({
    required RaioXDimensionItem item,
    required bool isConvergence,
    required bool isExpanded,
    required VoidCallback onTap,
    required TextTheme text,
    required EspectroPalette p,
  }) {
    final chipColor = isConvergence ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              item.dimensionLabel,
                              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (item.isTriad) ...<Widget>[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: p.surfaceMuted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Tríade',
                                style: TextStyle(fontSize: 10, color: p.muted),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Você: ${item.userSummary}  ·  Alvo: ${item.targetSummary}',
                        style: text.bodySmall?.copyWith(color: p.inkSoft),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.isTriad
                        ? 'Δcomp ${item.deltaDistance}'
                        : 'Δ ${item.deltaDistance}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: chipColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: p.muted,
                ),
              ],
            ),
            if (isExpanded) ...<Widget>[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.functions_rounded, size: 14, color: p.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Cálculo do motor: ${item.mathematicalContribution}',
                      style: text.bodySmall?.copyWith(fontSize: 12, color: p.muted),
                    ),
                  ),
                ],
              ),
              if (item.sourceUrl != null && item.sourceUrl!.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.open_in_new_rounded, size: 14, color: p.accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final rawUrl = item.sourceUrl?.trim() ?? '';
                          final uri = Uri.tryParse(rawUrl);
                          final isValidHttps = uri != null &&
                              uri.scheme.toLowerCase() == 'https' &&
                              uri.host.trim().isNotEmpty;
                          if (!isValidHttps) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Link de referência indisponível ou inseguro (exige HTTPS com domínio válido).',
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!launched) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Não foi possível abrir o link da referência.'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          } catch (_) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Erro ao tentar abrir o documento da referência.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Referência documental catalogada (abrir documento)',
                          style: text.bodySmall?.copyWith(
                            fontSize: 11,
                            color: p.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (item.locator != null && item.locator!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.bookmark_border_rounded, size: 14, color: p.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Localizador documental: ${item.locator}',
                        style: text.bodySmall?.copyWith(fontSize: 11, color: p.muted),
                      ),
                    ),
                  ],
                ),
              ],
              if (item.catalogNote != null && item.catalogNote!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.menu_book_outlined, size: 14, color: p.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Síntese editorial: ${item.catalogNote}',
                        style: text.bodySmall?.copyWith(
                          fontSize: 12,
                          color: p.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../data/app_data.dart';
import '../../../domain/models/political_models.dart';
import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../view_models/app_view_model.dart';
import '../atlas/study_taxonomy.dart';

/// Tela de transparência metodológica, fórmulas matemáticas e explorador
/// aberto do catálogo de correntes ideológicas.
class MethodologyScreen extends StatelessWidget {
  const MethodologyScreen({required this.data, this.appViewModel, super.key});

  final AppData data;
  final AppViewModel? appViewModel;

  void _showCurrentDetail(BuildContext context, IdeologicalCurrent current) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    showInfoSheet(
      context,
      title: current.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Tag(
            label: current.family,
            background: p.accentSoft,
            foreground: p.accent,
          ),
          const SizedBox(height: 12),
          Text(current.summary, style: text.bodyLarge),
          if (current.keyIdeas.isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            const Eyebrow('Ideias-chave'),
            const SizedBox(height: 10),
            for (final String idea in current.keyIdeas)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '•  ',
                      style: TextStyle(
                        color: p.accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Expanded(child: Text(idea, style: text.bodyMedium)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 18),
          const Eyebrow('Parâmetros nos eixos (μ e tolerância σ)'),
          const SizedBox(height: 10),
          for (final axis in data.twelveAxes.axes)
            if (current.axes[axis.id] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          axis.label,
                          style: text.titleMedium?.copyWith(fontSize: 13.5),
                        ),
                        Text(
                          'μ=${current.axes[axis.id]!.mu.toStringAsFixed(2)} · '
                          'σ=${current.axes[axis.id]!.sigma.toStringAsFixed(2)} · '
                          'peso=${current.axes[axis.id]!.relevance.toStringAsFixed(1)}',
                          style: text.bodySmall?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(current.axes[axis.id]!.note, style: text.bodySmall),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final bool showBack =
        appViewModel == null || MediaQuery.sizeOf(context).width < 1100;

    Widget frame({required PreferredSizeWidget appBar, required Widget body}) =>
        appViewModel == null
        ? Scaffold(
            appBar: appBar,
            body: ResponsiveContentFrame(child: body),
          )
        : EspectroScaffold(
            appViewModel: appViewModel!,
            selectedIndex: 5,
            isSectionRoot: true,
            appBar: appBar,
            body: ResponsiveContentFrame(child: body),
          );
    return DefaultTabController(
      length: 2,
      child: frame(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: !showBack
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Center(
                    child: CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Voltar',
                    ),
                  ),
                ),
          title: const Text('Metodologia'),
          bottom: TabBar(
            labelColor: p.accent,
            unselectedLabelColor: p.muted,
            indicatorColor: p.accent,
            dividerColor: p.line,
            tabs: <Widget>[
              const Tab(text: 'Cálculos e Fórmulas'),
              Tab(text: 'Correntes (${data.catalog.currents.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              children: <Widget>[
                const EditorialHeading(
                  eyebrow: 'Método / Privacidade',
                  title: 'Confiança se\nconstrói com clareza.',
                ),
                const SizedBox(height: 26),
                const EditorialHero(
                  eyebrow: 'Como calculamos',
                  title: 'Sem caixa-preta.\nSem certezas artificiais.',
                ),
                const SizedBox(height: 22),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('LIMITES DO CATÁLOGO'),
                      const SizedBox(height: 10),
                      Text(
                        'As posições de correntes e personalidades são interpretações editoriais contextualizadas. Os parâmetros não foram validados como uma medição empírica dessas pessoas ou tradições.',
                        style: text.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Proximidade numérica não determina filiação histórica. Relações intelectuais documentadas e leituras primárias são apresentadas separadamente nos perfis. Quando uma fonte não sustenta uma posição, o campo é omitido ou recebe relevância zero e fica fora da comparação.',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Eyebrow('1. Escala, inversão e pulo'),
                      const SizedBox(height: 10),
                      Text(
                        'Cada afirmação respondida recebe um valor simétrico '
                        'r em {−2, −1, 0, +1, +2}, normalizado para x = r / 2 em [−1, +1].',
                        style: text.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Inversão e balanceamento: em todas as dimensões, 50% das perguntas '
                        'são formuladas em cada direção. Isso neutraliza o viés de aquiescência '
                        '(tendência a concordar com tudo) e permite medi-lo.\n'
                        '• Pular ≠ Neutro: escolher "Neutro / depende" vale x = 0 e puxa o eixo '
                        'para o centro. Pular exclui o item da média ponderada e reduz a cobertura.',
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Eyebrow('2. Eixos bipolares e margem de incerteza'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.line),
                        ),
                        child: Text(
                          'c_i = sinal_i · x_i\n'
                          'S   = Σ(w_i · c_i) / Σ(w_i)   em [−1, +1]\n'
                          '%PoloDireito  = 50 · (1 + S)\n'
                          '%PoloEsquerdo = 50 · (1 − S)\n'
                          'Faixa indicativa = S ± 1,96 · SE',
                          style: text.bodySmall?.copyWith(
                            fontFamily: 'IBMPlexMono',
                            color: p.ink,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Quando os itens chaveados à esquerda e os chaveados à direita '
                        'recebem apoio simultâneo (diferença interna > 0,75), o motor sinaliza '
                        '"tensão interna" em vez de esconder a contradição sob uma média de 50%.',
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Eyebrow('3. Tríades sem fechamento composicional'),
                      const SizedBox(height: 10),
                      Text(
                        'Em testes triangulares clássicos, os três vértices são forçados a '
                        'somar 100% logo no início — fazendo quem apoia fortemente os 3 vértices '
                        'e quem rejeita os 3 caírem no mesmo rótulo "Centrista".',
                        style: text.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.line),
                        ),
                        child: Text(
                          'v_k = Σ(w · c) / Σw       em [−1, +1] (por vértice)\n'
                          'u_k = (v_k + 1) / 2       em [0, 1]   (apoio absoluto)\n'
                          'p_k = u_k / (u_1+u_2+u_3) em [0, 1]   (posição no triângulo)\n'
                          'I   = (u_1 + u_2 + u_3)/3 em [0, 1]   (engajamento médio)',
                          style: text.bodySmall?.copyWith(
                            fontFamily: 'IBMPlexMono',
                            color: p.ink,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Exemplo numérico: se u = [0,85, 0,85, 0,85], a composição é '
                        '[33%, 33%, 33%] com I = 85% ("Apoio amplo aos 3 vértices"). '
                        'Se u = [0,15, 0,15, 0,15], a composição também é [33%, 33%, 33%], '
                        'mas I = 15% ("Ceticismo nos 3 vértices"), e o anel externo do ponto '
                        'reflete essa diferença.',
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'A composição sozinha é ambígua: dois padrões com a mesma '
                        'composição (apoio amplo e rejeição ampla) são indistinguíveis no '
                        'triângulo. Por isso a distância até um perfil combina composição '
                        'relativa e apoio absoluto:',
                        style: text.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.line),
                        ),
                        child: Text(
                          'd_comp = ||p − μ||_2 / √2                 em [0, 1]\n'
                          'g      = clamp((|I − 0,5| − 0,15) / 0,35, 0, 1)\n'
                          'dist   = √(d_comp² + 0,16 · g²)           em [0, 1,077]',
                          style: text.bodySmall?.copyWith(
                            fontFamily: 'IBMPlexMono',
                            color: p.ink,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Propriedades: a distância nunca é menor que a diferença de '
                        'composição (o apoio absoluto só afasta, nunca aproxima); é '
                        'monótona no afastamento de I = 0,5; e é invariante à troca '
                        'simultânea de vértices nos dois perfis.',
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Limitação declarada: os perfis do catálogo descrevem apenas '
                        'ênfase relativa, não intensidade absoluta. Por isso a coordenada '
                        'de engajamento do perfil fica no plano neutro e a métrica é '
                        'invariante ao sinal de I − 0,5: apoiar intensamente os 3 vértices e '
                        'rejeitá-los intensamente produzem a mesma distância escalar. O '
                        'sinal é comunicado separadamente pela classificação da tríade '
                        '(ex.: "Apoio amplo aos 3 vértices" vs. "Ceticismo nos 3 vértices") '
                        'e pelas contribuições item a item.',
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Eyebrow(
                        '4. Compatibilidade ideológica transparente',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.line),
                        ),
                        child: Text(
                          'z_d    = dist(x_d, μ_d) / √(σ_d² + SE_d²)\n'
                          'D²     = Σ(rel_d · z_d²) / Σ(rel_d)\n'
                          'compat = 100 · exp(−D² / 2)\n'
                          '\n'
                          'eixos:  dist = |S − μ|\n'
                          'tríades: dist = √(d_comp² + 0,16 · g²)',
                          style: text.bodySmall?.copyWith(
                            fontFamily: 'IBMPlexMono',
                            color: p.ink,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cada corrente define um centro esperado (μ), uma largura de tolerância '
                        'interna (σ) e a relevância temática daquela dimensão (rel). '
                        'A incerteza do próprio teste (SE) amplia a tolerância para não punir '
                        'testes rápidos. Se o melhor resultado ficar abaixo de 52%, o sistema '
                        'declara "Perfil híbrido / independente" sem forçar classificação única. '
                        'Se houver conflito real entre polos em pelo menos metade dos eixos '
                        'avaliados, o resultado é declarado de baixa discriminação em vez de '
                        'receber um rótulo ideológico.',
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Eyebrow('5. Cobertura, indeterminação e confiança'),
                      const SizedBox(height: 10),
                      Text(
                        'Um número só é exibido como posição quando existe evidência '
                        'suficiente para sustentá-lo. Caso contrário, a dimensão é marcada '
                        'como indeterminada em vez de receber um valor neutro inventado.',
                        style: text.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• Eixo bipolar: exige os dois polos observados e ao menos '
                        '2 itens respondidos, com cobertura ≥ 50% do peso apresentado.\n'
                        '• Tríade: exige os 3 vértices observados, cobertura ≥ 50% e ao '
                        'menos 3 itens respondidos. Vértice sem resposta recebe participação '
                        'zero e o triângulo é declarado indeterminado.\n'
                        '• Pulos não contam como resposta neutra: não deslocam o escore e '
                        'reduzem a cobertura. Respostas neutras contam e aproximam do centro.',
                        style: text.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'O rótulo de confiança (indeterminado, baixa, moderada, alta) '
                        'resume cobertura, cobertura mínima por polo/vértice e erro-padrão '
                        'estimado. Ele não é um intervalo psicométrico validado: serve para '
                        'comunicar quanta evidência sustenta o número exibido.',
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Respostas de concordância (ou discordância) máxima são tratadas '
                        'como baixa discriminação somente quando a própria estrutura '
                        'balanceada do banco revela conflito real: apoio simultâneo a polos '
                        'opostos em pelo menos 2 eixos e em metade ou mais dos eixos '
                        'avaliados. O aviso não é uma reprovação do respondente.',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Eyebrow('6. Limitações e privacidade'),
                      const SizedBox(height: 10),
                      Text(
                        'Questionários políticos são instrumentos educativos de autorreflexão, '
                        'não diagnósticos científicos definitivos. O banco atual conta com '
                        '${data.totalQuestionCount} afirmações (${data.twelveAxes.questions.length} '
                        'bipolares e ${data.sixTriangles.questions.length} triangulares). '
                        'Todos os cálculos e históricos permanecem exclusivamente no armazenamento '
                        'interno do seu aparelho, sem permissão de internet na versão final.',
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              itemCount: data.catalog.currents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final IdeologicalCurrent current = data.catalog.currents[index];
                return InkWell(
                  onTap: () => _showCurrentDetail(context, current),
                  borderRadius: BorderRadius.circular(18),
                  child: SectionCard(
                    radius: 18,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SpectrumBar(
                              color: spectrumOf(
                                    StudySubject.fromCurrent(current),
                                  )?.color ??
                                  context.palette.accent,
                              height: 18,
                              width: 3.5,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                current.name,
                                style: text.titleMedium,
                              ),
                            ),
                            Tag(label: current.family),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          current.summary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

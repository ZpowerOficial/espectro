import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../engine/six_triangles_engine.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'six/six_intro_screen.dart';
import 'twelve/twelve_intro_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.data, super.key});

  final AppData data;

  void _openTwelve(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => TwelveIntroScreen(data: data),
      ),
    );
  }

  void _openSix(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SixIntroScreen(data: data),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showInfoSheet(
      context,
      title: 'Sobre o Espectro',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Dois testes independentes para olhar a política por ângulos diferentes. '
            'Tudo é calculado no aparelho: nenhuma resposta sai daqui e o app funciona sem internet.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          _AboutLine(
            icon: Icons.grid_view_rounded,
            title: '12 Eixos',
            text:
                'Doze pares de polos — de federal a unitário, de militarista a pacifista. '
                'Disponível em 36, 60 ou 240 perguntas.',
          ),
          const SizedBox(height: 14),
          _AboutLine(
            icon: Icons.change_history_rounded,
            title: 'Six Triangles',
            text:
                'Seis áreas, cada uma com três vértices. O ponto no triângulo mostra '
                'o peso de cada vértice no seu perfil. Em 72 ou 144 perguntas.',
          ),
          const SizedBox(height: 18),
          Text(
            'Este é um projeto independente, sem vínculo com partidos, campanhas ou '
            'governos. As perguntas e os métodos seguem os testes públicos em que se inspira.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<TriangleScore> preview = <TriangleScore>[
      for (final category in data.sixTriangles.categories)
        TriangleScore(
          category: category,
          points: const <int>[333, 333, 334],
          classification: 'Centrista',
        ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'E',
                    style: TextStyle(
                      color: AppColors.surface,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'ESPECTRO',
                      style: text.labelSmall?.copyWith(
                        color: AppColors.ink,
                        letterSpacing: 2.8,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('dois testes, um só mapa', style: text.bodySmall),
                  ],
                ),
                const Spacer(),
                CircleIconButton(
                  icon: Icons.info_outline_rounded,
                  onPressed: () => _showAbout(context),
                  tooltip: 'Sobre o app',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Onde você está\nno espectro?',
              style: text.displayLarge?.copyWith(fontSize: 42),
            ),
            const SizedBox(height: 14),
            Text(
              'Duas formas de medir posições políticas. Escolha uma para começar — '
              'sem cadastro, sem envio de respostas.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 28),
            _TestCard(
              tag: '12 Eixos',
              title: 'Doze eixos',
              description:
                  'Do federal ao unitário, do militarista ao pacifista. '
                  'Veja o seu perfil em doze pares de polos.',
              meta: '36 · 60 · 240 perguntas',
              artwork: MiniAxesChart(axes: data.twelveAxes.axes),
              onTap: () => _openTwelve(context),
            ),
            const SizedBox(height: 14),
            _TestCard(
              tag: 'Six Triangles',
              title: 'Seis triângulos',
              description:
                  'Economia, liberdade, cultura, política externa, governo '
                  'e igualdade — cada área em três vértices.',
              meta: '72 · 144 perguntas',
              artwork: SixWheel(
                triangles: preview,
                size: 88,
                showDots: false,
                gapColor: AppColors.surface,
              ),
              dark: true,
              onTap: () => _openSix(context),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 15,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Funciona offline. As respostas ficam apenas no seu aparelho.',
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Inspirado nos testes públicos 12axes e Six Triangles. Sem vínculo partidário.',
              style: text.bodySmall?.copyWith(fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({
    required this.tag,
    required this.title,
    required this.description,
    required this.meta,
    required this.artwork,
    required this.onTap,
    this.dark = false,
  });

  final String tag;
  final String title;
  final String description;
  final String meta;
  final Widget artwork;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color background = dark ? AppColors.dark : AppColors.surface;
    final Color foreground = dark ? AppColors.surface : AppColors.ink;
    final Color soft = dark ? const Color(0xFFC3CCC6) : AppColors.inkSoft;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: dark ? AppColors.dark : AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Eyebrow(
                          tag,
                          color: dark
                              ? const Color(0xFF9AA69E)
                              : AppColors.muted,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: text.headlineLarge?.copyWith(
                            color: foreground,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  artwork,
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: text.bodyMedium?.copyWith(color: soft, height: 1.45),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Text(
                    meta.toUpperCase(),
                    style: text.labelSmall?.copyWith(
                      color: dark ? const Color(0xFF9AA69E) : AppColors.muted,
                      fontSize: 9.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: dark ? AppColors.surface : AppColors.ink,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: dark ? AppColors.dark : AppColors.surface,
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

class _AboutLine extends StatelessWidget {
  const _AboutLine({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.surfaceAlt,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 17, color: AppColors.ink),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(text, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'data/app_data.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

class EspectroApp extends StatelessWidget {
  const EspectroApp({required this.data, super.key});

  final AppData data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Espectro',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: HomeScreen(data: data),
    );
  }
}

/// Tela de contingência: os dados ficam embarcados no APK, então uma falha aqui
/// significa instalação corrompida — mostramos o motivo em vez de tela branca.
class EspectroErrorApp extends StatelessWidget {
  const EspectroErrorApp({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Espectro',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'ESPECTRO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.6,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Não foi possível abrir os testes.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Os dados offline não puderam ser lidos. Reinstale o aplicativo.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                Text(message, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

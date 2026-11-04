import 'package:flutter/material.dart';

/// Marca oficial exportada do componente 24:31 do Figma, sem redesenho ou tint.
class EspectroBrandMark extends StatelessWidget {
  const EspectroBrandMark({this.size = 43, super.key});
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/figma/espectro-mascot.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    semanticLabel: 'Símbolo do Espectro',
  );
}

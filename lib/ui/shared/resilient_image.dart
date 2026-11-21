import 'package:flutter/material.dart';

/// Renderiza um asset local com `gaplessPlayback` e exibição imediata de
/// [fallback] antes da decodificação ou em caso de falha — evitando quadros
/// vazios (P1.6).
Widget buildResilientAssetImage(
  String assetPath, {
  required Widget fallback,
  double? width,
  double? height,
  int? cacheWidth,
  BoxFit fit = BoxFit.cover,
  AlignmentGeometry alignment = Alignment.center,
  bool excludeFromSemantics = true,
  String? semanticLabel,
}) => Image.asset(
  assetPath,
  width: width,
  height: height,
  cacheWidth: cacheWidth,
  fit: fit,
  alignment: alignment,
  gaplessPlayback: true,
  excludeFromSemantics: excludeFromSemantics,
  semanticLabel: semanticLabel,
  frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded || frame != null) return child;
    return fallback;
  },
  errorBuilder: (_, _, _) => fallback,
);

/// Renderiza uma imagem remota com exibição imediata de [fallback] enquanto
/// o primeiro quadro carrega ou quando a rede falha (P1.6).
Widget buildResilientNetworkImage(
  String url, {
  required Widget fallback,
  double? width,
  double? height,
  int? cacheWidth,
  BoxFit fit = BoxFit.cover,
  AlignmentGeometry alignment = Alignment.center,
  bool excludeFromSemantics = true,
  String? semanticLabel,
}) => Image.network(
  url,
  width: width,
  height: height,
  cacheWidth: cacheWidth,
  fit: fit,
  alignment: alignment,
  gaplessPlayback: true,
  excludeFromSemantics: excludeFromSemantics,
  semanticLabel: semanticLabel,
  frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded || frame != null) return child;
    return fallback;
  },
  errorBuilder: (_, _, _) => fallback,
);

/// Roteia automaticamente entre asset local e URL remota com fallback imediato.
Widget buildResilientMediaImage(
  String source, {
  required Widget fallback,
  double? width,
  double? height,
  int? cacheWidth,
  BoxFit fit = BoxFit.cover,
  AlignmentGeometry alignment = Alignment.center,
  bool excludeFromSemantics = true,
  String? semanticLabel,
}) {
  if (source.startsWith('http://') || source.startsWith('https://')) {
    return buildResilientNetworkImage(
      source,
      fallback: fallback,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      fit: fit,
      alignment: alignment,
      excludeFromSemantics: excludeFromSemantics,
      semanticLabel: semanticLabel,
    );
  }
  return buildResilientAssetImage(
    source,
    fallback: fallback,
    width: width,
    height: height,
    cacheWidth: cacheWidth,
    fit: fit,
    alignment: alignment,
    excludeFromSemantics: excludeFromSemantics,
    semanticLabel: semanticLabel,
  );
}

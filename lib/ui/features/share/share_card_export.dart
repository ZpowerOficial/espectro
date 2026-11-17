import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../data/portable_export_helper.dart';
import '../../../domain/models/study_link_uri.dart';

/// Never includes the current route, answers, ID, title, date or score.
/// Native builds without a configured public origin return null honestly.
String? shareCardEntryLink({Uri? base, String? configuredOrigin}) {
  final value = buildPublicStudyLink(
    '/',
    base: base,
    configuredOrigin: configuredOrigin,
  );
  final uri = Uri.tryParse(value);
  if (uri == null ||
      !const ['https', 'http'].contains(uri.scheme) ||
      uri.host.isEmpty) {
    return null;
  }
  return value;
}

Future<Uint8List> captureShareCardPng(GlobalKey key) async {
  final boundary = key.currentContext?.findRenderObject();
  if (boundary is! RenderRepaintBoundary) throw StateError('Card unavailable');
  final ui.Image image = await boundary.toImage(pixelRatio: 3);
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('PNG encoding failed');
    return bytes.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// Browser save uses cross_file's actual download path, not Web Share. Desktop
/// prefers Downloads (or Documents fallback); Android saves in app documents.
class ShareCardExporter {
  const ShareCardExporter();

  Future<String> save(Uint8List bytes, String filename) async {
    final String location = await savePortableBytes(
      bytes: bytes,
      filename: filename,
      mimeType: 'image/png',
    );
    if (currentPortableTarget() == PortableTarget.web) {
      return location;
    }
    return 'Imagem salva em:\n$location';
  }

  Future<String?> share(
    Uint8List bytes,
    String filename, {
    String? entryLink,
  }) async {
    final PortableShareResult result = await shareOrSavePortableBytes(
      bytes: bytes,
      filename: filename,
      mimeType: 'image/png',
      text: entryLink == null
          ? 'Meu retrato exploratório no Espectro.'
          : 'Explore suas ideias no Espectro: $entryLink',
    );
    if (result.sharedViaNativeSheet) return null;
    if (currentPortableTarget() == PortableTarget.web) {
      return result.locationOrMessage;
    }
    return 'Compartilhamento nativo indisponível neste sistema. Imagem salva em:\n${result.locationOrMessage}';
  }
}

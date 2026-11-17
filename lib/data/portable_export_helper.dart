import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Categorias de portabilidade para fluxos de exportação e compartilhamento.
enum PortableTarget { web, desktopNoNativeShare, mobileOrNativeShare }

/// Classifica o alvo atual sem importar `dart:io`, mantendo compatibilidade
/// total entre Web, Android, Linux, Windows e macOS.
PortableTarget currentPortableTarget({
  bool? overrideIsWeb,
  TargetPlatform? overridePlatform,
}) {
  final bool web = overrideIsWeb ?? kIsWeb;
  if (web) return PortableTarget.web;
  final TargetPlatform platform = overridePlatform ?? defaultTargetPlatform;
  return switch (platform) {
    TargetPlatform.linux ||
    TargetPlatform.windows => PortableTarget.desktopNoNativeShare,
    _ => PortableTarget.mobileOrNativeShare,
  };
}

/// Constrói um caminho juntando diretório e arquivo respeitando o separador do SO.
String joinNativeFilePath(String directoryPath, String filename) {
  final String trimmed = directoryPath.replaceFirst(RegExp(r'[\\/]+$'), '');
  final String sep = trimmed.contains('\\') ? '\\' : '/';
  return '$trimmed$sep$filename';
}

/// Salva bytes no dispositivo (Downloads em desktop quando disponível, ou
/// Documentos do app) e dispara download direto na Web.
Future<String> savePortableBytes({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) async {
  final XFile file = XFile.fromData(bytes, mimeType: mimeType, name: filename);
  if (kIsWeb) {
    await file.saveTo(filename);
    return 'Download solicitado ao navegador. Verifique sua pasta de downloads.';
  }
  final String dirPath = await _resolveExportDirectoryPath();
  final String path = joinNativeFilePath(dirPath, filename);
  await file.saveTo(path);
  return path;
}

/// Compartilha arquivos quando o sistema possui Share Sheet nativo (Android/iOS/macOS)
/// ou salva em pasta acessível no Linux/Windows/Web quando o navegador ou desktop
/// não oferece compartilhamento direto de arquivos binários.
Future<PortableShareResult> shareOrSavePortableBytes({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
  String? subject,
  String? text,
}) async {
  final PortableTarget target = currentPortableTarget();
  final XFile memoryFile = XFile.fromData(
    bytes,
    mimeType: mimeType,
    name: filename,
  );

  if (target == PortableTarget.web) {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[memoryFile],
          fileNameOverrides: <String>[filename],
          subject: subject,
          text: text,
        ),
      );
      return PortableShareResult(
        sharedViaNativeSheet: true,
        locationOrMessage: filename,
      );
    } on Object {
      await memoryFile.saveTo(filename);
      return const PortableShareResult(
        sharedViaNativeSheet: false,
        locationOrMessage:
            'Download solicitado ao navegador. Verifique sua pasta de downloads.',
      );
    }
  }

  final String dirPath = await _resolveExportDirectoryPath();
  final String filePath = joinNativeFilePath(dirPath, filename);
  await memoryFile.saveTo(filePath);

  if (target == PortableTarget.desktopNoNativeShare) {
    return PortableShareResult(
      sharedViaNativeSheet: false,
      locationOrMessage: filePath,
    );
  }

  try {
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(filePath, mimeType: mimeType, name: filename)],
        fileNameOverrides: <String>[filename],
        subject: subject,
        text: text,
      ),
    );
    return PortableShareResult(
      sharedViaNativeSheet: true,
      locationOrMessage: filePath,
    );
  } on Object {
    return PortableShareResult(
      sharedViaNativeSheet: false,
      locationOrMessage: filePath,
    );
  }
}

class PortableShareResult {
  const PortableShareResult({
    required this.sharedViaNativeSheet,
    required this.locationOrMessage,
  });

  final bool sharedViaNativeSheet;
  final String locationOrMessage;
}

Future<String> _resolveExportDirectoryPath() async {
  if (currentPortableTarget() == PortableTarget.desktopNoNativeShare) {
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads.path;
    } on Object {
      // Fallback para documentos do aplicativo quando Downloads não existir.
    }
  }
  final docs = await getApplicationDocumentsDirectory();
  return docs.path;
}

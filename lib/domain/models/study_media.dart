import '../../data/strict_json.dart';

/// Retrato real importado sem geração de imagem, com licença por arquivo.
class StudyPortrait {
  const StudyPortrait({
    required this.assetPath,
    required this.caption,
    required this.author,
    required this.licenseName,
    required this.licenseUrl,
    required this.sourceUrl,
    required this.changes,
    required this.sha256,
    required this.verifiedOn,
  });
  final String assetPath,
      caption,
      author,
      licenseName,
      licenseUrl,
      sourceUrl,
      changes,
      sha256,
      verifiedOn;
  factory StudyPortrait.fromJson(Map<String, Object?> json) {
    String value(String key) => readString(json[key], 'portrait.$key');
    final path = value('assetPath');
    if (path.length > 200) {
      throw const FormatException('Caminho de retrato muito longo');
    }
    if (path.length > 200 ||
        !RegExp(r'^assets/portraits/[a-z0-9_]+\.(jpg|png)$').hasMatch(path)) {
      throw const FormatException('Caminho de retrato inválido');
    }
    final source = Uri.tryParse(value('sourceUrl'));
    final license = Uri.tryParse(value('licenseUrl'));
    if (source?.scheme != 'https' ||
        source?.host != 'commons.wikimedia.org' ||
        source?.userInfo.isNotEmpty == true ||
        source?.hasPort == true ||
        (license?.scheme != 'https' ||
            license?.host != 'creativecommons.org' ||
            license?.userInfo.isNotEmpty == true ||
            license?.hasPort == true)) {
      throw const FormatException('Proveniência de retrato inválida');
    }
    return StudyPortrait(
      assetPath: path,
      caption: value('caption'),
      author: value('author'),
      licenseName: value('licenseName'),
      licenseUrl: license.toString(),
      sourceUrl: source.toString(),
      changes: value('changes'),
      sha256: value('sha256'),
      verifiedOn: value('verifiedOn'),
    );
  }
}

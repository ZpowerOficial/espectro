import '../../data/strict_json.dart';

/// Contexto da interpretação editorial, sem atribuir validação empírica aos números.
class StudyEditorialBasis {
  const StudyEditorialBasis({
    required this.reviewedAt,
    required this.scope,
    required this.coordinateMethod,
    required this.limitations,
    required this.sourceUrls,
    required this.empiricallyValidated,
  });
  final String reviewedAt, scope, coordinateMethod;
  final List<String> limitations, sourceUrls;
  final bool empiricallyValidated;
  static StudyEditorialBasis? parse(Object? raw, String path) {
    if (raw == null) return null;
    final row = readObject(raw, path);
    List<String> strings(String key) => List.unmodifiable(
      readArray(
        row[key],
        '$path.$key',
      ).asMap().entries.map((e) => readString(e.value, '$path.$key[${e.key}]')),
    );
    final urls = strings('sourceUrls');
    if (urls.any((u) {
      final uri = Uri.tryParse(u);
      return uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty;
    })) {
      throw FormatException('$path: fonte inválida');
    }
    if (row['empiricallyValidated'] is! bool) {
      throw FormatException('$path: estado de validação inválido');
    }
    return StudyEditorialBasis(
      reviewedAt: readString(row['reviewedAt'], '$path.reviewedAt'),
      scope: readString(row['scope'], '$path.scope'),
      coordinateMethod: readString(
        row['coordinateMethod'],
        '$path.coordinateMethod',
      ),
      limitations: strings('limitations'),
      sourceUrls: urls,
      empiricallyValidated: row['empiricallyValidated'] as bool,
    );
  }
}

Map<String, String> readStudyCoordinateNotes(Object? raw, String path) =>
    raw == null
    ? const {}
    : Map.unmodifiable(
        readObject(
          raw,
          path,
        ).map((key, value) => MapEntry(key, readString(value, '$path.$key'))),
      );
Map<int, String> readStudyCompositionNotes(Object? raw, String path) {
  final out = <int, String>{};
  for (final e in readStudyCoordinateNotes(raw, path).entries) {
    final id = int.tryParse(e.key);
    if (id == null || id < 0 || id > 5) {
      throw FormatException('$path: tríade inválida');
    }
    out[id] = e.value;
  }
  return Map.unmodifiable(out);
}

import 'dart:ui';

/// Leitura estrita de JSON: nenhum cast solto, todo erro vira [FormatException]
/// com o caminho do campo, para falhar cedo em vez de propagar `null`.
Map<String, Object?> readObject(Object? value, String path) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      if (entry.key is String) {
        result[entry.key as String] = entry.value;
      } else {
        throw FormatException('$path: chave não textual "${entry.key}"');
      }
    }
    return result;
  }
  throw FormatException('$path: esperado objeto');
}

List<Object?> readArray(Object? value, String path) {
  if (value is List<Object?>) return value;
  throw FormatException('$path: esperado lista');
}

String readString(Object? value, String path) {
  if (value is String) return value;
  throw FormatException('$path: esperado texto');
}

String? readStringOrNull(Object? value, String path) {
  if (value == null) return null;
  return readString(value, path);
}

double readDouble(Object? value, String path) {
  if (value is num) return value.toDouble();
  throw FormatException('$path: esperado número');
}

int readInt(Object? value, String path) {
  if (value is int) return value;
  if (value is num && value == value.roundToDouble()) return value.toInt();
  throw FormatException('$path: esperado inteiro');
}

bool readBool(Object? value, String path) {
  if (value is bool) return value;
  throw FormatException('$path: esperado booleano');
}

/// Aceita `#RRGGBB` (formato usado pelos dois sites).
Color readColor(Object? value, String path) {
  final text = readString(value, path);
  final hex = text.startsWith('#') ? text.substring(1) : text;
  if (hex.length != 6) {
    throw FormatException('$path: cor inválida "$text"');
  }
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) {
    throw FormatException('$path: cor inválida "$text"');
  }
  return Color(0xFF000000 | parsed);
}

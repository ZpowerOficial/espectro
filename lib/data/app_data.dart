import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'models.dart';
import 'strict_json.dart';

/// Conteúdo embarcado dos dois testes. Carregado uma única vez em `main` para
/// que as telas nunca lidem com `Future` ou com JSON cru.
class AppData {
  const AppData({required this.twelveAxes, required this.sixTriangles});

  final TwelveAxesData twelveAxes;
  final SixTrianglesData sixTriangles;

  static Future<AppData> load({AssetBundle? bundle}) async {
    final source = bundle ?? rootBundle;
    final twelveRaw = jsonDecode(await source.loadString('assets/data/twelve_axes.json'));
    final sixRaw = jsonDecode(await source.loadString('assets/data/six_triangles.json'));
    return AppData(
      twelveAxes: TwelveAxesData.fromJson(readObject(twelveRaw, 'twelve_axes')),
      sixTriangles: SixTrianglesData.fromJson(readObject(sixRaw, 'six_triangles')),
    );
  }
}

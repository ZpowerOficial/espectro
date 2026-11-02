import 'package:flutter/material.dart';

import 'app.dart';
import 'data/app_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final AppData data = await AppData.load();
    runApp(EspectroApp(data: data));
  } catch (error) {
    runApp(EspectroErrorApp(message: error.toString()));
  }
}

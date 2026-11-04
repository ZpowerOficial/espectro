import 'package:flutter/material.dart';

import 'app.dart';
import 'data/app_data.dart';
import 'data/evaluation_repository.dart';
import 'data/local_storage_service.dart';
import 'ui/view_models/app_view_model.dart';

/// Inicializa somente o estado pessoal. O catálogo já deve ter sido carregado
/// com sucesso: erros nos assets não são tratados como falhas de armazenamento.
Future<AppViewModel> initializeAppViewModel({
  required AppData data,
  LocalStorageService? storage,
}) async {
  final AppViewModel durable = AppViewModel(
    data: data,
    repository: EvaluationRepository(storage: storage ?? LocalStorageService()),
  );
  try {
    await durable.initialize();
    return durable;
  } on Object {
    durable.dispose();
    // Não apaga nem substitui dados duráveis. A biblioteca continua acessível,
    // e toda gravação desta sessão fica exclusivamente na memória.
    final AppViewModel temporary = AppViewModel(
      data: data,
      repository: EvaluationRepository(storage: LocalStorageService.inMemory()),
      storageNotice:
          'Modo temporário: o armazenamento local está indisponível. '
          'Avaliações, favoritos e preferências desta sessão não persistem ao '
          'fechar ou recarregar o app. Verifique a permissão e o espaço disponível.',
    );
    await temporary.initialize();
    return temporary;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppData data;
  try {
    data = await AppData.load();
  } on Object catch (error) {
    runApp(EspectroErrorApp(message: error.toString()));
    return;
  }
  final AppViewModel appViewModel = await initializeAppViewModel(data: data);
  runApp(EspectroApp(appViewModel: appViewModel));
}

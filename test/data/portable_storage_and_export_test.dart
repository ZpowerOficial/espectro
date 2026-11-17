import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/local_storage_native.dart';
import 'package:politico/data/portable_export_helper.dart';

void main() {
  group('Resolução de diretório nativo de persistência', () {
    test('Android prioriza filesDir do canal nativo com sufixo v2', () {
      final String path = resolveNativeStorageDirectoryPath(
        isAndroid: true,
        isWindows: false,
        androidFilesDir: '/data/user/0/com.espectro.politico/files',
        environment: const <String, String>{},
        systemTempPath: '/tmp',
        pathSeparator: '/',
      );

      expect(path, '/data/user/0/com.espectro.politico/files/v2');
    });

    test('Windows resolve LOCALAPPDATA antes de APPDATA e USERPROFILE', () {
      final String localPath = resolveNativeStorageDirectoryPath(
        isAndroid: false,
        isWindows: true,
        environment: const <String, String>{
          'LOCALAPPDATA': r'C:\Users\Maria\AppData\Local',
          'APPDATA': r'C:\Users\Maria\AppData\Roaming',
          'USERPROFILE': r'C:\Users\Maria',
        },
        systemTempPath: r'C:\Windows\Temp',
        pathSeparator: r'\',
      );
      expect(localPath, r'C:\Users\Maria\AppData\Local\espectro\v2');

      final String roamingFallback = resolveNativeStorageDirectoryPath(
        isAndroid: false,
        isWindows: true,
        environment: const <String, String>{
          'APPDATA': r'C:\Users\Maria\AppData\Roaming',
          'USERPROFILE': r'C:\Users\Maria',
        },
        systemTempPath: r'C:\Windows\Temp',
        pathSeparator: r'\',
      );
      expect(roamingFallback, r'C:\Users\Maria\AppData\Roaming\espectro\v2');

      final String profileFallback = resolveNativeStorageDirectoryPath(
        isAndroid: false,
        isWindows: true,
        environment: const <String, String>{'USERPROFILE': r'C:\Users\Maria'},
        systemTempPath: r'C:\Windows\Temp',
        pathSeparator: r'\',
      );
      expect(profileFallback, r'C:\Users\Maria\AppData\Local\espectro\v2');
    });

    test('Linux prioriza XDG_DATA_HOME e faz fallback para ~/.local/share', () {
      final String xdgPath = resolveNativeStorageDirectoryPath(
        isAndroid: false,
        isWindows: false,
        environment: const <String, String>{
          'XDG_DATA_HOME': '/home/ana/.xdg-data',
          'HOME': '/home/ana',
        },
        systemTempPath: '/tmp',
        pathSeparator: '/',
      );
      expect(xdgPath, '/home/ana/.xdg-data/espectro/v2');

      final String homePath = resolveNativeStorageDirectoryPath(
        isAndroid: false,
        isWindows: false,
        environment: const <String, String>{'HOME': '/home/ana'},
        systemTempPath: '/tmp',
        pathSeparator: '/',
      );
      expect(homePath, '/home/ana/.local/share/espectro/v2');
    });

    test('usa diretório temporário apenas quando nenhuma variável de usuário existe', () {
      final String fallback = resolveNativeStorageDirectoryPath(
        isAndroid: false,
        isWindows: false,
        environment: const <String, String>{},
        systemTempPath: '/tmp',
        pathSeparator: '/',
      );
      expect(fallback, '/tmp/espectro_local/v2');
    });
  });

  group('Portabilidade de exportação e caminhos', () {
    test('classifica alvos desktop Linux/Windows separadamente de mobile e web', () {
      expect(
        currentPortableTarget(overrideIsWeb: true),
        PortableTarget.web,
      );
      expect(
        currentPortableTarget(
          overrideIsWeb: false,
          overridePlatform: TargetPlatform.linux,
        ),
        PortableTarget.desktopNoNativeShare,
      );
      expect(
        currentPortableTarget(
          overrideIsWeb: false,
          overridePlatform: TargetPlatform.windows,
        ),
        PortableTarget.desktopNoNativeShare,
      );
      expect(
        currentPortableTarget(
          overrideIsWeb: false,
          overridePlatform: TargetPlatform.android,
        ),
        PortableTarget.mobileOrNativeShare,
      );
    });

    test('joinNativeFilePath preserva separador POSIX e Windows sem duplicação', () {
      expect(
        joinNativeFilePath('/home/ana/Downloads/', 'espectro.pdf'),
        '/home/ana/Downloads/espectro.pdf',
      );
      expect(
        joinNativeFilePath(r'C:\Users\Ana\Downloads\', 'espectro.png'),
        r'C:\Users\Ana\Downloads\espectro.png',
      );
    });
  });
}

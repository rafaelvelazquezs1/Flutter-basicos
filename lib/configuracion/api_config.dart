import 'package:flutter/foundation.dart';

// Configuración centralizada: ninguna vista o servicio escribe la URL a mano.
abstract final class ApiConfig {
  // Permite usar otra IP sin editar código: --dart-define=API_BASE_URL=http://192.168.x.x:3000
  static const String _urlConfigurada = String.fromEnvironment('API_BASE_URL');

  // Categorías exactas disponibles en el backend de Música CDs.
  static const String todas = 'Todas';
  static const List<String> categorias = [
    todas,
    'Pop / Balada',
    'Rock en Español',
    'Rock Internacional',
    'Urbano / Reggaeton',
    'Metal / Hard Rock',
  ];

  static String get baseUrl {
    if (_urlConfigurada.isNotEmpty) return _urlConfigurada;
    // 10.0.2.2 conecta el emulador Android con el localhost de la computadora.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    // Web, iOS Simulator y escritorio usan localhost directamente.
    return 'http://localhost:3000';
  }

  static Uri uri(String ruta, {Map<String, String>? queryParameters}) {
    return Uri.parse('$baseUrl$ruta').replace(queryParameters: queryParameters);
  }
}

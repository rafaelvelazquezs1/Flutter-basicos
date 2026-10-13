// Configuración centralizada: ninguna vista o servicio escribe la URL a mano.
abstract final class ApiConfig {
  // URL HTTPS pública. Funciona desde APK, web, emulador y teléfono físico.
  static const String urlProduccion = 'https://movil-backend-kiey.onrender.com';

  // Permite usar un servidor local sin modificar el código.
  // Ejemplo: --dart-define=API_BASE_URL=http://10.0.2.2:3000
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
    return urlProduccion;
  }

  static Uri uri(String ruta, {Map<String, String>? queryParameters}) {
    return Uri.parse('$baseUrl$ruta').replace(queryParameters: queryParameters);
  }
}

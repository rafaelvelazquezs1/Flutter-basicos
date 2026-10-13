import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../configuracion/api_config.dart';

// Servicio encargado de elegir una portada y enviarla al backend.
class ImageUploadService {
  static final ImagePicker _selector = ImagePicker();
  static const int _tamanoMaximo = 5 * 1024 * 1024; // 5 MB.

  // Funciona en Android, iOS y Flutter Web.
  static Future<String?> seleccionarYSubirPortada() async {
    final archivo = await _selector.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (archivo == null) return null;

    final bytes = await archivo.readAsBytes();
    if (bytes.length > _tamanoMaximo) {
      throw Exception('La imagen debe pesar como máximo 5 MB.');
    }

    final solicitud = http.MultipartRequest(
      'POST',
      ApiConfig.uri('/api/uploads/images'),
    );
    solicitud.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: archivo.name,
        contentType: _tipoDeArchivo(archivo),
      ),
    );

    final respuesta = await solicitud.send();
    final cuerpo = await respuesta.stream.bytesToString();
    final datos = _leerObjeto(cuerpo);

    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw Exception(datos['message'] ?? 'No fue posible subir la imagen.');
    }

    final url = datos['imageUrl'] as String?;
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty || uri.scheme != 'https') {
      throw Exception('El servidor devolvió una URL de imagen inválida.');
    }
    return url;
  }

  // Conserva el tipo de la foto para que el backend acepte solo imágenes reales.
  static MediaType _tipoDeArchivo(XFile archivo) {
    final tipo = archivo.mimeType;
    if (tipo != null && tipo.startsWith('image/')) return MediaType.parse(tipo);
    return MediaType('image', 'jpeg');
  }

  static Map<String, dynamic> _leerObjeto(String cuerpo) {
    try {
      final datos = jsonDecode(cuerpo);
      if (datos is Map<String, dynamic>) return datos;
    } catch (_) {
      // Si el servidor no devuelve JSON se usa el mensaje general de error.
    }
    return {};
  }
}

import 'package:flutter/material.dart';

// Componente reutilizable para mostrar las portadas de los CDs.
// Si el servidor de imágenes no responde, la aplicación conserva una vista clara.
class ImagenProducto extends StatelessWidget {
  final String url;
  final String descripcion;
  final double? alto;

  const ImagenProducto({
    super.key,
    required this.url,
    required this.descripcion,
    this.alto,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: DecoratedBox(
      // El fondo y borde permiten apreciar portadas oscuras como Back in Black.
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Image.network(
        url,
        width: double.infinity,
        height: alto,
        // Conserva completa la carátula, sin cortar el título ni al artista.
        fit: BoxFit.contain,
        semanticLabel: descripcion,
        // Se muestra mientras la portada se descarga desde Internet.
        loadingBuilder: (context, imagen, progreso) {
          if (progreso == null) return imagen;
          return const Center(child: CircularProgressIndicator());
        },
        // Evita espacios vacíos cuando una URL deja de existir o no hay conexión.
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: alto,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.album_outlined, size: 52),
              SizedBox(height: 6),
              Text('Portada no disponible'),
            ],
          ),
        ),
      ),
    ),
  );
}

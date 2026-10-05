// Modelo de producto. Sus atributos privados aplican encapsulamiento.
class Producto {
  int _id;
  String _titulo;
  double _precio;
  String _descripcion;
  String _categoria;
  String _imagen;

  Producto({
    required int id,
    required String titulo,
    required double precio,
    required String descripcion,
    required String categoria,
    required String imagen,
  }) : _id = id,
       _titulo = titulo,
       _precio = precio,
       _descripcion = descripcion,
       _categoria = categoria,
       _imagen = imagen;

  int get id => _id;
  String get titulo => _titulo;
  double get precio => _precio;
  String get precioFormateado => '\$${_precio.toStringAsFixed(2)}';
  String get descripcion => _descripcion;
  String get categoria => _categoria;
  String get imagen => _imagen;

  // Setters con validacion: el controlador tambien valida y muestra los errores.
  set titulo(String valor) {
    if (valor.trim().isNotEmpty) _titulo = valor.trim();
  }

  set precio(double valor) {
    if (valor >= 0) _precio = valor;
  }

  set descripcion(String valor) {
    if (valor.trim().isNotEmpty) _descripcion = valor.trim();
  }

  set categoria(String valor) {
    if (valor.trim().isNotEmpty) _categoria = valor.trim();
  }

  set imagen(String valor) {
    if (valor.trim().isNotEmpty) _imagen = valor.trim();
  }

  factory Producto.desdeJson(Map<String, dynamic> json) => Producto(
    id: json['id'] as int? ?? 0,
    titulo: json['title'] as String? ?? 'Producto sin título',
    precio: (json['price'] as num? ?? 0).toDouble(),
    descripcion: json['description'] as String? ?? 'Sin descripción',
    categoria: json['category'] as String? ?? 'Sin categoría',
    imagen: json['image'] as String? ?? '',
  );
}

// Modelo que representa exactamente un producto recibido de Fake Store API.
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

  // Los getters entregan los datos listos para mostrarse en la interfaz.
  int get id => _id;
  String get titulo => _titulo;
  String get precioFormateado => '\$${_precio.toStringAsFixed(2)}';
  String get descripcion => _descripcion;
  String get categoria => _categoria;
  String get imagen => _imagen;

  // Los setters validan antes de cambiar el estado del objeto.
  set titulo(String valor) {
    if (valor.trim().isNotEmpty) _titulo = valor.trim();
  }

  set precio(double valor) {
    if (valor >= 0) _precio = valor;
  }

  factory Producto.desdeJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int? ?? 0,
      titulo: json['title'] as String? ?? 'Producto sin título',
      precio: (json['price'] as num? ?? 0).toDouble(),
      descripcion: json['description'] as String? ?? 'Sin descripción',
      categoria: json['category'] as String? ?? 'Sin categoría',
      imagen: json['image'] as String? ?? '',
    );
  }
}

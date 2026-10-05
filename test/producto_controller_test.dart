import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_basicos/controllers/producto_controller.dart';
import 'package:flutter_basicos/modelos/producto.dart';

void main() {
  // Estas pruebas verifican reglas locales antes de hacer solicitudes HTTP.
  group('ProductoController.validar', () {
    final controlador = ProductoController();

    test('acepta los datos completos de un producto', () {
      final errores = controlador.validar(
        titulo: 'Mochila',
        precio: '250.50',
        descripcion: 'Mochila escolar',
        categoria: 'accesorios',
        imagen: 'https://ejemplo.com/mochila.png',
      );
      expect(errores, isEmpty);
    });

    test('rechaza campos vacios, precio no numerico y URL invalida', () {
      final errores = controlador.validar(
        titulo: '',
        precio: 'mucho',
        descripcion: '',
        categoria: '',
        imagen: 'imagen',
      );
      expect(
        errores.keys,
        containsAll(<String>[
          'titulo',
          'precio',
          'descripcion',
          'categoria',
          'imagen',
        ]),
      );
    });
  });

  test('Producto formatea el precio y no acepta un precio negativo', () {
    final producto = Producto(
      id: 1,
      titulo: 'Libro',
      precio: 45,
      descripcion: 'Lectura',
      categoria: 'libros',
      imagen: 'https://ejemplo.com/libro.png',
    );
    producto.precio = -10;
    expect(producto.precioFormateado, r'$45.00');
  });
}

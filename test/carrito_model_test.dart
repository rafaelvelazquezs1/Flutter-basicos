import 'package:flutter_basicos/modelos/carrito.dart';
import 'package:flutter_basicos/modelos/producto.dart';
import 'package:flutter_test/flutter_test.dart';

Producto productoDePrueba({int id = 1, double precio = 99.5}) => Producto(
  id: id,
  titulo: 'CD de prueba',
  precio: precio,
  descripcion: 'Prueba de carrito',
  categoria: 'Rock Internacional',
  imagen: 'https://ejemplo.com/cd.png',
);

void main() {
  group('Carrito', () {
    test('suma cantidades del mismo CD sin crear líneas duplicadas', () {
      final carrito = Carrito(usuarioId: 4);
      carrito.agregarProducto(productoDePrueba(), 2);
      carrito.agregarProducto(productoDePrueba(), 3);

      expect(carrito.articulos, hasLength(1));
      expect(carrito.articulos.single.cantidad, 5);
      expect(carrito.total, 497.5);
      expect(carrito.totalFormateado, r'$497.50 MXN');
    });

    test('al bajar una unidad a cero elimina el artículo', () {
      final carrito = Carrito(usuarioId: 4);
      carrito.agregarProducto(productoDePrueba(), 1);

      final eliminado = carrito.decrementar(1);

      expect(eliminado, isTrue);
      expect(carrito.estaVacio, isTrue);
      expect(carrito.total, 0);
    });

    test('conserva un resumen del CD para restaurar el carrito local', () {
      final original = Carrito(usuarioId: 4, idApi: 12);
      original.agregarProducto(productoDePrueba(precio: 150), 2);

      final recuperado = Carrito.desdeJson(original.toJson(), usuarioId: 4);

      expect(recuperado.idApi, 12);
      expect(recuperado.articulos.single.producto.titulo, 'CD de prueba');
      expect(recuperado.totalFormateado, r'$300.00 MXN');
    });
  });
}

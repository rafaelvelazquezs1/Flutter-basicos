import 'package:flutter/material.dart';
import 'package:flutter_basicos/Interfaces/componentes/imagen_producto.dart';
import 'package:flutter_basicos/controllers/carrito_controller.dart';
import 'package:flutter_basicos/modelos/articulo_carrito.dart';

// Pantalla de US10: muestra, modifica y elimina las líneas del carrito local.
class CarritoPantalla extends StatefulWidget {
  const CarritoPantalla({super.key});

  @override
  State<CarritoPantalla> createState() => _CarritoPantallaState();
}

class _CarritoPantallaState extends State<CarritoPantalla> {
  final _controlador = CarritoController();

  @override
  void initState() {
    super.initState();
    _controlador.addListener(_actualizarVista);
    _cargar();
  }

  void _actualizarVista() {
    if (mounted) setState(() {});
  }

  Future<void> _cargar() async {
    try {
      await _controlador.iniciar();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  Future<void> _ejecutarCambio(Future<bool> Function() cambio) async {
    try {
      final sincronizado = await cambio();
      if (!mounted || sincronizado) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controlador.avisoSincronizacion!)),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mi carrito')),
    body: _contenido(),
    bottomNavigationBar: _controlador.cargando ? null : _resumen(),
  );

  Widget _contenido() {
    if (_controlador.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controlador.estaVacio) return _carritoVacio();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _controlador.carrito.articulos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, indice) =>
          _articulo(_controlador.carrito.articulos[indice]),
    );
  }

  Widget _carritoVacio() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove_shopping_cart_outlined,
            size: 88,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'Tu carrito está vacío, explora el catálogo',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'Agrega CDs desde el detalle de cada producto.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.library_music_outlined),
            label: const Text('Explorar catálogo'),
          ),
        ],
      ),
    ),
  );

  Widget _articulo(ArticuloCarrito articulo) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: ImagenProducto(
              url: articulo.producto.imagen,
              descripcion: 'Portada de ${articulo.producto.titulo}',
              alto: 108,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulo.producto.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Precio: ${articulo.producto.precioFormateado}'),
                Text('Subtotal: \$${articulo.subtotal.toStringAsFixed(2)} MXN'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Restar una unidad',
                      onPressed: _controlador.sincronizando
                          ? null
                          : () => _ejecutarCambio(
                              () => _controlador.decrementar(
                                articulo.producto.id,
                              ),
                            ),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('Cantidad: ${articulo.cantidad}'),
                    IconButton(
                      tooltip: 'Sumar una unidad',
                      onPressed: _controlador.sincronizando
                          ? null
                          : () => _ejecutarCambio(
                              () => _controlador.incrementar(
                                articulo.producto.id,
                              ),
                            ),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Eliminar artículo',
                      onPressed: _controlador.sincronizando
                          ? null
                          : () => _ejecutarCambio(
                              () => _controlador.eliminar(articulo.producto.id),
                            ),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _resumen() => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Total: ${_controlador.carrito.totalFormateado}',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            // El botón queda desactivado de verdad cuando no hay productos.
            onPressed: _controlador.estaVacio
                ? null
                : () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'El pago es una simulación de la práctica.',
                      ),
                    ),
                  ),
            icon: const Icon(Icons.payment_outlined),
            label: const Text('Proceder al pago'),
          ),
        ],
      ),
    ),
  );
}

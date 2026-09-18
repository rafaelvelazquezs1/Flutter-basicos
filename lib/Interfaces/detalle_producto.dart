import 'package:flutter/material.dart';
import 'package:flutter_basicos/modelos/producto.dart';
import 'package:flutter_basicos/servicios/api_productos.dart';
import 'package:flutter_basicos/servicios/sesion_service.dart';

// Muestra un producto y adapta los controles al rol almacenado localmente.
class DetalleProductoPantalla extends StatefulWidget {
  final int productoId;

  const DetalleProductoPantalla({super.key, required this.productoId});

  @override
  State<DetalleProductoPantalla> createState() =>
      _DetalleProductoPantallaState();
}

class _DetalleProductoPantallaState extends State<DetalleProductoPantalla> {
  Producto? _producto;
  bool _cargando = true;
  bool _esAdministrador = false;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      final datos = await Future.wait<dynamic>([
        ApiProductos.obtenerProducto(widget.productoId),
        SesionService.obtenerRol(),
      ]);
      if (!mounted) return;
      setState(() {
        _producto = datos[0] as Producto;
        _esAdministrador = datos[1] == 'Administrador';
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      // El catálogo recibirá este aviso y mostrará la alerta al regresar.
      Navigator.pop(context, 'unavailable');
    }
  }

  // Permite al administrador cambiar el título con una validación básica.
  Future<void> _editarProducto() async {
    final controlador = TextEditingController(text: _producto!.titulo);
    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Editar producto'),
        content: TextField(
          controller: controlador,
          decoration: const InputDecoration(labelText: 'Título'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, controlador.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevoTitulo == null || nuevoTitulo.trim().isEmpty) return;
    try {
      await ApiProductos.editarTitulo(_producto!, nuevoTitulo);
      if (!mounted) return;
      setState(() => _producto!.titulo = nuevoTitulo);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Producto actualizado')));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo editar el producto')),
        );
    }
  }

  // Elimina el producto y vuelve al catálogo para mostrar la lista actualizada.
  Future<void> _eliminarProducto() async {
    try {
      await ApiProductos.eliminarProducto(_producto!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Producto eliminado')));
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el producto')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final producto = _producto!;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                producto.imagen,
                height: 230,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              producto.titulo,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              producto.precioFormateado,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Chip(label: Text(producto.categoria)),
            const SizedBox(height: 12),
            Text(producto.descripcion),
            // Estos botones ni siquiera se crean si el rol local no es Administrador.
            if (_esAdministrador) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _editarProducto,
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _eliminarProducto,
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

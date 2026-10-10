import 'package:flutter/material.dart';
import 'package:flutter_basicos/Interfaces/componentes/imagen_producto.dart';
import 'package:flutter_basicos/Interfaces/editar_producto.dart';
import 'package:flutter_basicos/controllers/detalle_producto_controller.dart';

// Vista de detalle: los permisos y la comunicacion con API viven en su controlador.
class DetalleProductoPantalla extends StatefulWidget {
  final int productoId;
  const DetalleProductoPantalla({super.key, required this.productoId});
  @override
  State<DetalleProductoPantalla> createState() =>
      _DetalleProductoPantallaState();
}

class _DetalleProductoPantallaState extends State<DetalleProductoPantalla> {
  final _controlador = DetalleProductoController();
  @override
  void initState() {
    super.initState();
    _controlador.addListener(_actualizarVista);
    _cargar();
  }

  void _actualizarVista() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      await _controlador.cargar(widget.productoId);
    } catch (_) {
      if (mounted) Navigator.pop(context, 'unavailable');
    }
  }

  Future<void> _editar() async {
    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarProductoPantalla(
          producto: _controlador.producto!,
          controladorDetalle: _controlador,
        ),
      ),
    );
    if (actualizado == true && mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CD actualizado correctamente')),
      );
  }

  Future<void> _confirmarEliminacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Estás seguro de eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogo, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true)
      return; // Cancelar no ejecuta ninguna solicitud DELETE.
    try {
      await _controlador.eliminar();
      if (mounted) {
        // El catálogo muestra el mensaje cuando esta pantalla ya se cerró.
        Navigator.pop(context, 'deleted');
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controlador.cargando)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final producto = _controlador.producto!;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ImagenProducto(
                url: producto.imagen,
                descripcion: 'Portada de ${producto.titulo}',
                alto: 230,
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
            // Los controles no se renderizan para Cliente ni Auditor.
            if (_controlador.esAdministrador) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _editar,
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _confirmarEliminacion,
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

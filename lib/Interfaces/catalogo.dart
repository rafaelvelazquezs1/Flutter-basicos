import 'package:flutter/material.dart';
import 'package:flutter_basicos/Interfaces/crear_producto.dart';
import 'package:flutter_basicos/Interfaces/detalle_producto.dart';
import 'package:flutter_basicos/Interfaces/perfil.dart';
import 'package:flutter_basicos/controllers/catalogo_controller.dart';
import 'package:flutter_basicos/modelos/usuario.dart';

// Vista del catalogo: consume el estado preparado por CatalogoController.
class CatalogoPantalla extends StatefulWidget {
  final Usuario usuario;
  const CatalogoPantalla({super.key, required this.usuario});
  @override
  State<CatalogoPantalla> createState() => _CatalogoPantallaState();
}

class _CatalogoPantallaState extends State<CatalogoPantalla> {
  final _controlador = CatalogoController();
  @override
  void initState() {
    super.initState();
    _controlador.addListener(_actualizarVista);
    _controlador.iniciar();
  }

  void _actualizarVista() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _abrirDetalle(int id) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleProductoPantalla(productoId: id),
      ),
    );
    if (!mounted) return;
    if (resultado == 'unavailable')
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto no disponible')));
    if (resultado == 'deleted') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado (Simulación)')),
      );
      _controlador.cargarCatalogo(categoria: _controlador.categoriaActiva);
    }
    if (resultado == true)
      _controlador.cargarCatalogo(categoria: _controlador.categoriaActiva);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Catálogo de productos'),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          tooltip: 'Mi perfil',
          icon: const Icon(Icons.person_outline),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PerfilPantalla(usuario: widget.usuario),
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: _controlador.esAdministrador
        ? FloatingActionButton.extended(
            onPressed: () async {
              final creado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CrearProductoPantalla(),
                ),
              );
              if (creado == true && mounted)
                _controlador.cargarCatalogo(
                  categoria: _controlador.categoriaActiva,
                );
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
          )
        : null,
    body: Column(
      children: [
        _filtros(),
        Expanded(child: _contenido()),
      ],
    ),
  );

  Widget _filtros() => SizedBox(
    height: 58,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      children: [
        ChoiceChip(
          label: const Text('Ver todos'),
          selected: _controlador.categoriaActiva == null,
          onSelected: (_) => _controlador.cargarCatalogo(),
        ),
        const SizedBox(width: 8),
        ..._controlador.categorias.map(
          (categoria) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(categoria),
              selected: _controlador.categoriaActiva == categoria,
              onSelected: (_) =>
                  _controlador.cargarCatalogo(categoria: categoria),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _contenido() {
    if (_controlador.cargando)
      return const Center(child: CircularProgressIndicator());
    if (_controlador.error != null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_controlador.error!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _controlador.cargarCatalogo,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _controlador.productos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, indice) {
        final producto = _controlador.productos[indice];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _abrirDetalle(producto.id),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                      producto.imagen,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    producto.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(producto.precioFormateado),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

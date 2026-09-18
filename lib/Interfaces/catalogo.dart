import 'package:flutter/material.dart';
import 'package:flutter_basicos/Interfaces/detalle_producto.dart';
import 'package:flutter_basicos/Interfaces/perfil.dart';
import 'package:flutter_basicos/modelos/producto.dart';
import 'package:flutter_basicos/modelos/usuario.dart';
import 'package:flutter_basicos/servicios/api_productos.dart';

// Pantalla principal: descarga, filtra y muestra el catálogo de forma reciclable.
class CatalogoPantalla extends StatefulWidget {
  final Usuario usuario;

  const CatalogoPantalla({super.key, required this.usuario});

  @override
  State<CatalogoPantalla> createState() => _CatalogoPantallaState();
}

class _CatalogoPantallaState extends State<CatalogoPantalla> {
  List<String> _categorias = [];
  List<Producto> _productos = [];
  String? _categoriaActiva;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  // Limpia los datos anteriores antes de pedir una nueva categoría.
  Future<void> _cargarCatalogo({String? categoria}) async {
    setState(() {
      _cargando = true;
      _error = null;
      _productos = [];
      _categoriaActiva = categoria;
    });
    try {
      final resultados = await Future.wait([
        ApiProductos.obtenerProductos(categoria: categoria),
        if (_categorias.isEmpty) ApiProductos.obtenerCategorias(),
      ]);
      if (!mounted) return;
      setState(() {
        _productos = resultados.first as List<Producto>;
        if (_categorias.isEmpty && resultados.length > 1) {
          _categorias = resultados[1] as List<String>;
        }
      });
    } catch (_) {
      if (mounted)
        _error = 'No se pudo cargar el catálogo. Revisa tu conexión.';
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Column(
        children: [
          _filtros(),
          Expanded(child: _contenido()),
        ],
      ),
    );
  }

  Widget _filtros() {
    return SizedBox(
      height: 58,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          ChoiceChip(
            label: const Text('Ver todos'),
            selected: _categoriaActiva == null,
            onSelected: (_) => _cargarCatalogo(),
          ),
          const SizedBox(width: 8),
          ..._categorias.map(
            (categoria) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categoria),
                selected: _categoriaActiva == categoria,
                onSelected: (_) => _cargarCatalogo(categoria: categoria),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _cargarCatalogo,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    // GridView.builder crea solo las tarjetas que se ven en pantalla.
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _productos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, indice) {
        final producto = _productos[indice];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetalleProductoPantalla(productoId: producto.id),
                ),
              );
              if (!mounted) return;
              if (resultado == 'unavailable') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto no disponible')),
                );
              } else if (resultado == true) {
                _cargarCatalogo(categoria: _categoriaActiva);
              }
            },
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

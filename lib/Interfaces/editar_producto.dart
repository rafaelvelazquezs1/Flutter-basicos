import 'package:flutter/material.dart';
import 'package:flutter_basicos/configuracion/api_config.dart';
import 'package:flutter_basicos/controllers/detalle_producto_controller.dart';
import 'package:flutter_basicos/controllers/producto_controller.dart';
import 'package:flutter_basicos/modelos/producto.dart';

// Vista US07: precarga todos los datos y delega validacion al controlador.
class EditarProductoPantalla extends StatefulWidget {
  final Producto producto;
  final DetalleProductoController controladorDetalle;
  const EditarProductoPantalla({
    super.key,
    required this.producto,
    required this.controladorDetalle,
  });
  @override
  State<EditarProductoPantalla> createState() => _EditarProductoPantallaState();
}

class _EditarProductoPantallaState extends State<EditarProductoPantalla> {
  final _formulario = ProductoController();
  late final TextEditingController _titulo = TextEditingController(
    text: widget.producto.titulo,
  );
  late final TextEditingController _precio = TextEditingController(
    text: widget.producto.precio.toString(),
  );
  late final TextEditingController _descripcion = TextEditingController(
    text: widget.producto.descripcion,
  );
  late String? _categoria = widget.producto.categoria;
  late final TextEditingController _imagen = TextEditingController(
    text: widget.producto.imagen,
  );
  Map<String, String> _errores = {};
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _formulario.addListener(_actualizarVista);
  }

  void _actualizarVista() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final campo in [_titulo, _precio, _descripcion, _imagen]) {
      campo.dispose();
    }
    _formulario.removeListener(_actualizarVista);
    _formulario.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(
      () => _errores = _formulario.validar(
        titulo: _titulo.text,
        precio: _precio.text,
        descripcion: _descripcion.text,
        categoria: _categoria ?? '',
        imagen: _imagen.text,
      ),
    );
    if (_errores.isNotEmpty) return;
    setState(() => _guardando = true);
    try {
      final actualizado = Producto(
        id: widget.producto.id,
        titulo: _titulo.text,
        precio: double.parse(_precio.text),
        descripcion: _descripcion.text,
        categoria: _categoria!,
        imagen: _imagen.text,
      );
      await widget.controladorDetalle.editar(actualizado);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // Completa el campo image con la URL segura devuelta por el backend.
  Future<void> _elegirImagen() async {
    try {
      final url = await _formulario.seleccionarYSubirPortada();
      if (url == null || !mounted) return;
      setState(() {
        _imagen.text = url;
        _errores = {..._errores}..remove('imagen');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Portada subida correctamente.')),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Editar producto')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _campo(_titulo, 'Título', 'titulo'),
        _campo(_precio, 'Precio', 'precio', teclado: TextInputType.number),
        _campo(_descripcion, 'Descripción', 'descripcion', lineas: 3),
        _selectorCategoria(),
        _campo(_imagen, 'URL de imagen', 'imagen'),
        OutlinedButton.icon(
          onPressed: _guardando || _formulario.cargando ? null : _elegirImagen,
          icon: _formulario.cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_library_outlined),
          label: Text(
            _formulario.cargando
                ? 'Subiendo portada...'
                : 'Elegir imagen de la galería',
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _guardando || _formulario.cargando ? null : _guardar,
          child: _guardando
              ? const CircularProgressIndicator()
              : const Text('Guardar cambios'),
        ),
      ],
    ),
  );
  Widget _campo(
    TextEditingController campo,
    String etiqueta,
    String llave, {
    TextInputType teclado = TextInputType.text,
    int lineas = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: campo,
      keyboardType: teclado,
      maxLines: lineas,
      decoration: InputDecoration(
        labelText: etiqueta,
        errorText: _errores[llave],
        border: const OutlineInputBorder(),
      ),
    ),
  );

  // El desplegable conserva el valor actual y limita los cambios al catálogo real.
  Widget _selectorCategoria() => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      initialValue: _categoria,
      decoration: InputDecoration(
        labelText: 'Categoría',
        errorText: _errores['categoria'],
        border: const OutlineInputBorder(),
      ),
      items: ApiConfig.categorias
          .where((categoria) => categoria != ApiConfig.todas)
          .map(
            (categoria) =>
                DropdownMenuItem(value: categoria, child: Text(categoria)),
          )
          .toList(),
      onChanged: (valor) => setState(() => _categoria = valor),
    ),
  );
}

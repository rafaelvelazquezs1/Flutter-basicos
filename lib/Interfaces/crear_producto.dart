import 'package:flutter/material.dart';
import 'package:flutter_basicos/configuracion/api_config.dart';
import 'package:flutter_basicos/controllers/producto_controller.dart';
import 'package:flutter_basicos/modelos/producto.dart';

// Vista del formulario US06. Las reglas del formulario estan en ProductoController.
class CrearProductoPantalla extends StatefulWidget {
  const CrearProductoPantalla({super.key});
  @override
  State<CrearProductoPantalla> createState() => _CrearProductoPantallaState();
}

class _CrearProductoPantallaState extends State<CrearProductoPantalla> {
  final _controlador = ProductoController();
  final _titulo = TextEditingController();
  final _precio = TextEditingController();
  final _descripcion = TextEditingController();
  String? _categoria;
  final _imagen = TextEditingController();
  Map<String, String> _errores = {};
  @override
  void initState() {
    super.initState();
    _controlador.addListener(_actualizarVista);
    _validarAcceso();
  }

  void _actualizarVista() {
    if (mounted) setState(() {});
  }

  Future<void> _validarAcceso() async {
    try {
      await _controlador.comprobarAcceso();
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    for (final campo in [_titulo, _precio, _descripcion, _imagen]) {
      campo.dispose();
    }
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(
      () => _errores = _controlador.validar(
        titulo: _titulo.text,
        precio: _precio.text,
        descripcion: _descripcion.text,
        categoria: _categoria ?? '',
        imagen: _imagen.text,
      ),
    );
    if (_errores.isNotEmpty) return;
    try {
      final creado = await _controlador.crear(
        Producto(
          id: 0,
          titulo: _titulo.text,
          precio: double.parse(_precio.text),
          descripcion: _descripcion.text,
          categoria: _categoria!,
          imagen: _imagen.text,
        ),
      );
      if (!mounted) return;
      for (final campo in [_titulo, _precio, _descripcion, _imagen]) {
        campo.clear();
      }
      setState(() => _categoria = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CD creado correctamente. Nuevo ID: ${creado.id}'),
        ),
      );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    }
  }

  // La vista pide al controlador la acción; no conoce detalles de HTTP ni Cloudinary.
  Future<void> _elegirImagen() async {
    try {
      final url = await _controlador.seleccionarYSubirPortada();
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
    appBar: AppBar(title: const Text('Agregar producto')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _campo(_titulo, 'Título', 'titulo'),
        _campo(_precio, 'Precio', 'precio', teclado: TextInputType.number),
        _campo(_descripcion, 'Descripción', 'descripcion', lineas: 3),
        _selectorCategoria(),
        _campo(_imagen, 'URL de imagen', 'imagen'),
        OutlinedButton.icon(
          onPressed: _controlador.cargando ? null : _elegirImagen,
          icon: _controlador.cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_library_outlined),
          label: Text(
            _controlador.cargando
                ? 'Subiendo portada...'
                : 'Elegir imagen de la galería',
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _controlador.cargando ? null : _guardar,
          child: _controlador.cargando
              ? const CircularProgressIndicator()
              : const Text('Guardar producto'),
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

  // Evita capturar categorías libres que el backend no reconoce.
  Widget _selectorCategoria() => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      key: ValueKey(_categoria),
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

import 'package:flutter/material.dart';
import 'package:flutter_basicos/Interfaces/catalogo.dart';
import 'package:flutter_basicos/controllers/login_controller.dart';

// Vista de login: solo pinta widgets y realiza la navegacion.
class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});
  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  final _controlador = LoginController();
  bool _ocultarContrasena = true;

  @override
  void initState() {
    super.initState();
    _controlador.addListener(_actualizarVista);
  }

  void _actualizarVista() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _usuario.dispose();
    _contrasena.dispose();
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _enviarLogin() async {
    try {
      final usuario = await _controlador.iniciarSesion(
        _usuario.text,
        _contrasena.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => CatalogoPantalla(usuario: usuario)),
        (ruta) => false,
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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.account_circle,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Bienvenido',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usuario,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contrasena,
              obscureText: _ocultarContrasena,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: const OutlineInputBorder(),
                // Permite revisar la contraseña antes de iniciar sesión.
                suffixIcon: IconButton(
                  tooltip: _ocultarContrasena
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  icon: Icon(
                    _ocultarContrasena
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _ocultarContrasena = !_ocultarContrasena),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _controlador.cargando
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: _enviarLogin,
                    child: const Text('Iniciar sesión'),
                  ),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import '../conexion/api.dart';
import '../modelos/usuario.dart';
import 'catalogo.dart';
import '../servicios/sesion_service.dart';

class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _cargando = false;

  void _iniciarSesion() async {
    final usuarioTexto = _usuarioController.text.trim();
    final passwordTexto = _passwordController.text.trim();

    if (usuarioTexto.isEmpty || passwordTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      // Petición a la API y creación de objeto POO
      Usuario usuarioLogueado = await ApiService.loginYObtenerUsuario(
        usuarioTexto,
        passwordTexto,
      );

      // La sesión se guarda antes de entrar a las pantallas protegidas.
      await SesionService.guardarSesion(
        token: ApiService.ultimoToken ?? '',
        // La API sólo tiene usuarios; se normaliza al rol pedido por la historia.
        rol: usuarioLogueado.obtenerRol() == 'Administrador'
            ? 'Administrador'
            : usuarioLogueado.obtenerRol() == 'Auditor'
                ? 'Auditor'
                : 'Cliente',
        usuarioId: usuarioLogueado.id,
      );

      if (mounted) {
        // Navegación limpia: destruye el historial previo para evitar acumulaciones en el stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CatalogoPantalla(usuario: usuarioLogueado),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: tema.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.account_circle,
                size: 80,
                color: tema.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: tema.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton(
                      onPressed: _iniciarSesion,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

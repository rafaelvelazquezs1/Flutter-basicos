import 'package:flutter/material.dart';

import '../modelos/usuario.dart';
import 'login.dart';
import '../servicios/sesion_service.dart';

class PerfilPantalla extends StatelessWidget {
  final Usuario usuario;

  const PerfilPantalla({super.key, required this.usuario});

  // Escenario 1 y 3: Limpieza de datos y token
  Future<void> _cerrarSesion(BuildContext context) async {
    // 1. Limpieza de memoria persistente (SharedPreferences)
    await SesionService.cerrarSesion(); // Elimina tokens, rol, identificador y datos locales.

    if (context.mounted) {
      // 2. Escenario 2: Destrucción del historial de navegación
      // Impide volver atrás a la vista protegida con el botón físico/gestual
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPantalla()),
        (Route<dynamic> route) => false, // Elimina todas las rutas previas
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: tema.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Evita botón de regreso manual
        actions: [
          // Botón de Cierre de Sesión en el menú de navegación
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _mostrarDialogoConfirmacion(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar con insignia
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: tema.colorScheme.primaryContainer,
                    child: Text(
                      usuario.nombreCompleto.isNotEmpty
                          ? usuario.nombreCompleto[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: tema.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: tema.colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      usuario.obtenerInsignia(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                usuario.nombreCompleto,
                style: tema.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              Chip(
                avatar: Text(usuario.obtenerInsignia()),
                label: Text(
                  usuario.obtenerRol(),
                  style: TextStyle(
                    color: tema.colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: tema.colorScheme.secondaryContainer,
                side: BorderSide.none,
              ),
              const SizedBox(height: 24),

              // Tarjeta de detalles
              Card(
                elevation: 0,
                color: tema.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('ID de Usuario'),
                        subtitle: Text('#${usuario.id}'),
                      ),
                      const Divider(indent: 16, endIndent: 16, height: 1),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Usuario'),
                        subtitle: Text(usuario.usuario),
                      ),
                      const Divider(indent: 16, endIndent: 16, height: 1),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Correo Electrónico'),
                        subtitle: Text(usuario.correo),
                      ),
                      const Divider(indent: 16, endIndent: 16, height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('Teléfono'),
                        subtitle: Text(usuario.telefono),
                      ),
                      const Divider(indent: 16, endIndent: 16, height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: const Text('Dirección'),
                        subtitle: Text(usuario.direccion),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón explícito de Cerrar Sesión
              OutlinedButton.icon(
                onPressed: () => _mostrarDialogoConfirmacion(context),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tema.colorScheme.error,
                  side: BorderSide(color: tema.colorScheme.error),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text(
            '¿Estás seguro de que deseas salir de tu cuenta?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarSesion(context);
              },
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
  }
}

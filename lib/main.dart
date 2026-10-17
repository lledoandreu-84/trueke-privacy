import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trueke/app/app.dart';
import 'core/network/telemetry_client.dart';

import 'firebase_options.dart';

// Proveedor global síncrono para evitar inicializaciones asíncronas dispersas en caliente
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Debe ser inicializado con un override en el ProviderScope',
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase de forma nativa e inmune antes de activar listeners de notificaciones
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Aviso de inicialización Firebase: $e');
  }

  // Cargar variables de entorno del sistema de forma unificada
  await dotenv.load(fileName: '.env');

  // Inicializar Supabase usando las claves del archivo .env e inyectando telemetría
  await Supabase.initialize(
    url: dotenv.get(
      'SUPABASE_URL',
      fallback: dotenv.get('NEXT_PUBLIC_SUPABASE_URL', fallback: ''),
    ),
    publishableKey: dotenv.get(
      'SUPABASE_ANON_KEY',
      fallback: dotenv.get('NEXT_PUBLIC_SUPABASE_ANON_KEY', fallback: ''),
    ),
    httpClient: TelemetryClient(),
  );

  // Inicializar almacenamiento físico local de forma centralizada antes de arrancar la interfaz
  final sharedPreferences = await SharedPreferences.getInstance();

  // Desplegar el árbol de widgets envuelto en el contenedor global de estados
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

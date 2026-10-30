import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/legal/presentation/screens/legal_text_viewer_screen.dart';
import 'package:trueke/shared/widgets/custom_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;

  void _openLegalViewer(String title, String assetPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalTextViewerScreen(
          title: title,
          assetPath: assetPath,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Eliminar Cuenta y Datos',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: const Text(
            'De acuerdo con las políticas de privacidad y los requisitos de Google Play, esta acción eliminará permanentemente tu cuenta, tus productos publicados, favoritos y mensajes de chat de nuestros servidores. Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar Permanentemente'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        // Llamar a la función RPC segura en Supabase que borra todo (Auth y Tablas)
        await Supabase.instance.client.rpc('delete_user_account');

        // Cerrar sesión localmente en la app
        FocusManager.instance.primaryFocus?.unfocus();
        await ref.read(authServiceProvider).signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tu cuenta y datos asociados han sido eliminados correctamente.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar la cuenta: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(titleText: 'Configuración y Ajustes'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Legal y Normativa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          radius: 17,
                          backgroundColor: Color(0x266750A4),
                          child: Icon(Icons.description_outlined, color: Color(0xFF6750A4), size: 19),
                        ),
                        title: const Text('Términos y Condiciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: const Text('Consulta las normas de uso de la plataforma', style: TextStyle(fontSize: 11.5)),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                        onTap: () => _openLegalViewer('Términos y Condiciones', 'assets/legal/terms_and_conditions.md'),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ListTile(
                        leading: const CircleAvatar(
                          radius: 17,
                          backgroundColor: Color(0x266750A4),
                          child: Icon(Icons.privacy_tip_outlined, color: Color(0xFF6750A4), size: 19),
                        ),
                        title: const Text('Política de Privacidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: const Text('Cómo protegemos y tratamos tus datos', style: TextStyle(fontSize: 11.5)),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                        onTap: () => _openLegalViewer('Política de Privacidad', 'assets/legal/privacy_policy.md'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Zona de Privacidad y Cuenta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0x26FF5252),
                      child: Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 19),
                    ),
                    title: const Text(
                      'Eliminar cuenta y datos',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.redAccent),
                    ),
                    subtitle: const Text('Borrado permanente conforme a Google Play', style: TextStyle(fontSize: 11.5)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.redAccent),
                    onTap: _confirmDeleteAccount,
                  ),
                ),
              ],
            ),
    );
  }
}

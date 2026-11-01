require 'fileutils'

def replace_in_file(path, old_str, new_str)
  content = File.read(path)
  content.gsub!(old_str, new_str)
  File.write(path, content)
end

# 1. Actualizar referencias en HomeHeader
replace_in_file('lib/features/home/widgets/home_header.dart', 'ref.watch(truekeProvider)', 'ref.watch(truekeMatchesProvider)')

# 2. Actualizar referencias y lógica de borrado en NotificationsScreen
replace_in_file('lib/features/notifications/presentation/screens/notifications_screen.dart', 'ref.watch(truekeProvider)', 'ref.watch(truekeMatchesProvider)')

# Corregir la acción de la papelera para que use el nuevo ValueNotifier
old_delete = <<~OLD
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      ref.read(truekeProvider.notifier).update((state) => [...state, matchId]);
                    },
                  ),
OLD

new_delete = <<~NEW
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      final notifier = ref.read(hiddenTruekesProvider);
                      notifier.value = [...notifier.value, matchId];
                    },
                  ),
NEW

replace_in_file('lib/features/notifications/presentation/screens/notifications_screen.dart', old_delete.strip, new_delete.strip)

puts "Referencias actualizadas correctamente."

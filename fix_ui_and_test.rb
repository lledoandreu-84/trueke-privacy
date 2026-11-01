require 'fileutils'

def patch_file(path, replacements)
  content = File.read(path)
  replacements.each do |old, new|
    content.gsub!(old, new)
  end
  File.write(path, content)
end

# Restaurar y corregir HomeHeader
header_content = File.read('lib/features/home/widgets/home_header.dart')

# Reemplazamos todo el bloque del Stack para manejar bien el estado de la campana
old_stack = <<~OLD
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Stack(
              children: [
                IconButton(
                  tooltip: 'Conversaciones y Notificaciones',
                  icon: const Icon(
                    notifications.isEmpty ? Icons.notifications_none_rounded : Icons.notifications_rounded,
                    color: AppColors.petrolBlue,
                    size: 23,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/notifications');
                  },
                ),
                notificationsAsync.when(
                  data: (notifications) {
                    if (notifications.isEmpty) return const SizedBox.shrink();
                    return Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${notifications.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
OLD

new_stack = <<~NEW
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: notificationsAsync.when(
              data: (notifications) => Stack(
                children: [
                  IconButton(
                    tooltip: 'Conversaciones y Notificaciones',
                    icon: Icon(
                      notifications.isEmpty ? Icons.notifications_none_rounded : Icons.notifications_rounded,
                      color: AppColors.petrolBlue,
                      size: 23,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/notifications');
                    },
                  ),
                  if (notifications.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${notifications.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              loading: () => IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.petrolBlue, size: 23),
                onPressed: () => Navigator.of(context).pushNamed('/notifications'),
              ),
              error: (_, _) => IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.petrolBlue, size: 23),
                onPressed: () => Navigator.of(context).pushNamed('/notifications'),
              ),
            ),
          ),
NEW

header_content.gsub!(old_stack.strip, new_stack.strip)
File.write('lib/features/home/widgets/home_header.dart', header_content)

puts "Código corregido. Ejecutando análisis y pruebas..."

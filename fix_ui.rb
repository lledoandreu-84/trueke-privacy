require 'fileutils'

def patch_file(path, replacements)
  content = File.read(path)
  replacements.each do |old, new|
    content.gsub!(old, new)
  end
  File.write(path, content)
end

# 1. Arreglar HomeHeader (Logo, Título y Campana)
header_replacements = {
  "SizedBox(\n            width: 52,\n            height: 52,\n            child: Transform.scale(\n              scale: 1.35,\n              child: Image.asset(\n                'assets/images/logo.png',\n                fit: BoxFit.contain,\n              ),\n            ),\n          )," => "Image.asset(\n            'assets/images/logo.png',\n            width: 40,\n            height: 40,\n            fit: BoxFit.contain,\n          ),",
  
  "const Text(\n                  'Trueke',\n                  style: TextStyle(\n                    fontSize: 24,\n                    height: 1.1,\n                    fontWeight: FontWeight.w800,\n                    color: AppColors.primary,\n                    letterSpacing: -0.8,\n                  ),\n                )," => "const Text(\n                  'Trueke',\n                  style: TextStyle(\n                    fontFamily: 'Montserrat',\n                    fontSize: 24,\n                    fontWeight: FontWeight.w800,\n                    color: AppColors.primary,\n                  ),\n                ),",

  "Icons.notifications_none_rounded" => "notifications.isEmpty ? Icons.notifications_none_rounded : Icons.notifications_rounded"
}

patch_file('lib/features/home/widgets/home_header.dart', header_replacements)

# 2. Arreglar NotificationsScreen (Estilo del AppBar)
screen_replacements = {
  "appBar: AppBar(title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)))," => "appBar: AppBar(title: const Text('Notificaciones', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold))),"
}

patch_file('lib/features/notifications/presentation/screens/notifications_screen.dart', screen_replacements)

puts "¡Cambios aplicados con éxito en HomeHeader y NotificationsScreen!"

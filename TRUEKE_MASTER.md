# TRUEKE — DOCUMENTO MAESTRO DE MIGRACIÓN Y CONTINUIDAD

**Fecha de referencia:** 3 de septiembre de 2026
**Repositorio:** lledoandreu84/Trueke
**Branch principal:** main
**Commit de referencia actual:** c0349d5 (refactor: auditoría completa, unificación de chat provider, storage service y product detail page)

## 1. OBJETIVO DEL PROYECTO
Trueke es una plataforma de compraventa e intercambio de productos, concebida funcionalmente como una alternativa tipo Wallapop, pero con especial importancia en el intercambio/trueque entre usuarios.

La meta es construir una aplicación completa con:
- Registro e inicio de sesión.
- Perfil de usuario.
- Publicación de productos (Imágenes, Catálogo, Búsqueda, Filtros).
- Favoritos.
- Detalle de producto.
- Chat entre usuarios.
- Propuestas de intercambio (Aceptación/rechazo).
- Gestión de productos propios.
- Notificaciones y Realtime.
- Persistencia real mediante Supabase (Seguridad RLS y RPC).

## 2. TECNOLOGÍA BASE
- **Frontend:** Flutter 3.44.8, Dart 3.12.2, Riverpod.
- **Backend:** Supabase (PostgreSQL, Auth, Storage, Realtime).
- **IA:** Integración preparada con `dart_openai`.
- **Persistencia local:** `shared_preferences` (para favoritos y estados locales).

## 3. ARQUITECTURA FLUTTER
Organizada por funcionalidades (features):
- `lib/app/`: Router, Shell y configuración global.
- `lib/core/`: Providers base, configuración Supabase y tema.
- `lib/features/`: Lógica de negocio por módulo (auth, products, chat, trades, etc.).
- `lib/models/`: Modelos de datos globales (aunque se prefiere cercanía a la feature).
- `lib/shared/`: Widgets y servicios reutilizables.

## 4. REGLAS DE ORO
1. **Seguridad:** Flutter NO es la frontera de seguridad. Supabase/PostgreSQL SÍ. Las comprobaciones críticas deben estar en el backend (RLS/RPC).
2. **Estado:** Usar Riverpod exclusivamente.
3. **Patrón:** UI -> Provider -> Repository -> Supabase.
4. **Migraciones:** No editar migraciones históricas. Crear nuevas para cambios de esquema.
5. **Calidad:** `dart format`, `flutter analyze` y `flutter test` deben pasar antes de cada commit.

## 5. ESTADO DE LAS FUNCIONALIDADES (AUDITORÍA)
- **Auth:** Implementado vía Supabase Auth. Eliminados duplicados antiguos.
- **Productos:** Catálogo, detalle modular (`ProductDetailPage` con slivers y widgets dedicados) y publicación funcionales. Storage centralizado (`StorageService`) con soporte para productos y avatares.
- **Favoritos:** Reactivos con Riverpod y persistencia local.
- **Chat:** Conversaciones y mensajes Realtime unificados con Supabase Streams (`chatMessagesStreamProvider` con autoDispose) y repositorio desacoplado.
- **Trades:** Sistema de propuestas mediante RPC (`create_trade_offer`, `respond_to_trade_offer`) con validaciones en base de datos.
- **CI/CD:** GitHub Actions configurado para validación y releases.

## 6. PRÓXIMOS PASOS (ROADMAP)
1. **BLOQUE CHAT (Prioridad Inmediata):** Implementar en `ChatPage` la bandeja de conversaciones dual (Pestaña "Mensajes" reactiva entre usuarios + Acceso al Asistente Trueki IA).
2. **BLOQUE B (Marketplace):** Refinar filtros, edición/eliminación de productos.
2. **BLOQUE C (Usuarios):** Edición de perfil, avatares y vista de "Mis productos".
3. **BLOQUE D/E/F:** Notificaciones y refinamiento de la experiencia de intercambio.
4. **BLOQUE G/H/I:** Tests exhaustivos, pulido de UI (UX) y preparación para producción.

---
*Este documento es la referencia para cualquier agente de IA o desarrollador que trabaje en el proyecto.*

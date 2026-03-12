# Capital Pro — Contexto del proyecto para Claude

## ¿Qué es este proyecto?
App Flutter de gestión financiera para prestamistas en Guatemala.
- Moneda: Quetzales (Q)
- Teléfonos: formato guatemalteco (8 dígitos, ej: 5555-1234)
- Código de país WhatsApp: +502
- Idioma de UI: español

## Stack técnico
| Paquete | Versión | Uso |
|---------|---------|-----|
| flutter_riverpod | ^2.4.0 | Estado global |
| go_router | ^12.0.0 | Navegación |
| sqflite | ^2.3.0 | Base de datos local |
| crypto | ^3.0.3 | Hash SHA-256 para passwords |
| shared_preferences | ^2.2.0 | Sesión de usuario |
| uuid | ^4.2.0 | IDs únicos |
| intl | ^0.18.1 | Fechas y números |
| google_fonts | ^6.1.0 | Poppins (títulos) + Inter (cuerpo) |
| image_picker | ^1.0.7 | Fotos de clientes |
| url_launcher | ^6.2.5 | Abrir WhatsApp |
| pdf + printing | ^3.11.3 / ^5.14.2 | Generar reportes PDF |
| fl_chart | ^0.66.0 | Gráficas |
| flutter_speed_dial | ^7.0.0 | FAB con múltiples opciones |
| share_plus | ^7.0.0 | Compartir archivos |

## Estructura de carpetas
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       ← TODOS los colores van aquí
│   │   ├── app_strings.dart      ← TODOS los textos de UI van aquí
│   │   ├── app_text_styles.dart  ← TODOS los estilos de texto van aquí
│   │   └── app_theme.dart        ← ThemeData de la app
│   ├── database/
│   │   └── database_helper.dart  ← Singleton sqflite
│   ├── router/
│   │   └── app_router.dart       ← go_router con todas las rutas
│   ├── services/
│   │   ├── storage_service.dart  ← SharedPreferences para sesión
│   │   ├── whatsapp_service.dart ← url_launcher para WhatsApp
│   │   ├── pdf_service.dart      ← Generar PDFs
│   │   └── backup_service.dart   ← Exportar/importar base de datos
│   └── utils/
│       ├── formatters.dart       ← AppFormatters (moneda, fechas, etc.)
│       └── validators.dart       ← AppValidators (formularios)
├── models/
│   ├── cliente.dart
│   ├── pago.dart
│   ├── prestamo.dart
│   └── resumen_financiero.dart
├── repositories/
│   ├── cliente_repository.dart
│   ├── pago_repository.dart
│   └── prestamo_repository.dart
├── providers/
│   ├── auth_provider.dart
│   ├── cliente_provider.dart
│   ├── pago_provider.dart
│   └── prestamo_provider.dart
├── screens/
│   ├── auth/           ← splash, login, registro
│   ├── dashboard/      ← dashboard_screen
│   ├── clientes/       ← lista, detalle, formulario
│   ├── pagos/          ← lista, detalle, formulario
│   ├── prestamos/      ← lista, detalle, formulario
│   └── reportes/       ← reportes_screen
└── widgets/            ← componentes reutilizables
```

## Reglas de código — LEE ESTO ANTES DE GENERAR CUALQUIER ARCHIVO

### ❌ NUNCA hagas esto
```dart
// ❌ Colores hardcodeados
color: Colors.red
color: Color(0xFFE53935)

// ❌ Strings hardcodeados en UI
Text('Guardar')
Text('Error al guardar')

// ❌ Estilos hardcodeados
style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)

// ❌ if sin llaves
if (condicion) hacerAlgo();

// ❌ value en TextFormField
TextFormField(value: texto)

// ❌ minHeight como parámetro directo
SizedBox(minHeight: 50)  // SizedBox no tiene minHeight

// ❌ async sin try/catch
Future<void> guardar() async {
  await repo.crear(item); // puede fallar sin ser capturado
}

// ❌ BuildContext después de await sin verificar mounted
await operacionLarga();
ScaffoldMessenger.of(context).showSnackBar(...); // context puede no estar montado
```

### ✅ SIEMPRE haz esto
```dart
// ✅ Colores
color: AppColors.error
color: AppColors.primary

// ✅ Strings
Text(AppStrings.guardar)
Text(AppStrings.errorGeneral)

// ✅ Estilos
style: AppTextStyles.h3
style: AppTextStyles.bodyMedium

// ✅ if siempre con llaves
if (condicion) {
  hacerAlgo();
}

// ✅ initialValue en TextFormField
TextFormField(initialValue: texto)

// ✅ Altura mínima con BoxConstraints
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 50),
  child: widget,
)

// ✅ async siempre con try/catch
Future<void> guardar() async {
  try {
    await repo.crear(item);
  } catch (e) {
    throw Exception('Error al guardar: $e');
  }
}

// ✅ Verificar mounted después de await
await operacionLarga();
if (mounted) {
  AppSnackBar.exito(context, AppStrings.guardadoExito);
}
```

## Base de datos — tablas y campos

```sql
-- Todos los IDs son UUID v4 (String)
-- Todas las fechas se guardan como ISO 8601 String
-- Booleanos como INTEGER: 1 = true, 0 = false

CREATE TABLE usuarios (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,   -- SHA-256
  fecha_registro TEXT NOT NULL
);

CREATE TABLE clientes (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  apellido TEXT NOT NULL,
  telefono TEXT NOT NULL,        -- 8 dígitos sin guion
  email TEXT,
  direccion TEXT,
  dpi TEXT,
  foto_path TEXT,
  fecha_registro TEXT NOT NULL,
  activo INTEGER NOT NULL DEFAULT 1  -- 1=activo, 0=eliminado (soft delete)
);

CREATE TABLE pagos (
  id TEXT PRIMARY KEY,
  cliente_id TEXT NOT NULL,
  prestamo_id TEXT,              -- NULL si es pago independiente
  monto REAL NOT NULL,
  fecha TEXT NOT NULL,
  metodo_pago TEXT NOT NULL,     -- 'efectivo'|'transferencia'|'cheque'|'tarjeta'
  concepto TEXT NOT NULL,
  estado TEXT NOT NULL DEFAULT 'completado', -- 'pendiente'|'completado'|'cancelado'
  notas TEXT,
  comprobante_path TEXT,
  fecha_creacion TEXT NOT NULL,
  FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  FOREIGN KEY (prestamo_id) REFERENCES prestamos(id)
);

CREATE TABLE prestamos (
  id TEXT PRIMARY KEY,
  cliente_id TEXT NOT NULL,
  monto_original REAL NOT NULL,
  tasa_interes REAL NOT NULL,    -- porcentaje mensual, ej: 5.0 = 5%
  plazo_meses INTEGER NOT NULL,
  fecha_inicio TEXT NOT NULL,
  fecha_vencimiento TEXT NOT NULL,
  saldo_pendiente REAL NOT NULL,
  estado TEXT NOT NULL DEFAULT 'activo', -- 'activo'|'pagado'|'vencido'|'cancelado'
  garantia TEXT,
  notas TEXT,
  fecha_creacion TEXT NOT NULL,
  FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

## Rutas de navegación (go_router)

```dart
// Constantes en AppRoutes
AppRoutes.splash       = '/'
AppRoutes.login        = '/login'
AppRoutes.registro     = '/registro'
AppRoutes.dashboard    = '/dashboard'
AppRoutes.clientes     = '/clientes'
AppRoutes.nuevoCliente = '/clientes/nuevo'
AppRoutes.detalleCliente = '/clientes/:id'
AppRoutes.editarCliente  = '/clientes/:id/editar'
AppRoutes.pagos        = '/pagos'
AppRoutes.nuevoPago    = '/pagos/nuevo'
AppRoutes.detallePago  = '/pagos/:id'
AppRoutes.prestamos    = '/prestamos'
AppRoutes.nuevoPrestamo = '/prestamos/nuevo'
AppRoutes.detallePrestamo = '/prestamos/:id'
AppRoutes.editarPrestamo  = '/prestamos/:id/editar'
AppRoutes.reportes     = '/reportes'

// Navegar
context.go(AppRoutes.clientes);
context.go('/clientes/$id');
context.go('/pagos/nuevo?clienteId=$clienteId');
context.push('/clientes/nuevo');  // cuando quieres poder hacer pop
context.pop();
```

## Patrón Riverpod — úsalo exactamente así

```dart
// 1. Notifier
class ClientesNotifier extends AsyncNotifier<List<Cliente>> {
  late final _repo = ClienteRepository();

  @override
  Future<List<Cliente>> build() async {
    return _repo.obtenerTodos();
  }

  Future<void> crear(Cliente cliente) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.crear(cliente);
      return _repo.obtenerTodos();
    });
  }
}

// 2. Provider
final clientesProvider =
    AsyncNotifierProvider<ClientesNotifier, List<Cliente>>(ClientesNotifier.new);

// 3. En widgets
ref.watch(clientesProvider).when(
  data: (lista) => _buildLista(lista),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => AppErrorWidget(
    mensaje: e.toString(),
    onRetry: () => ref.invalidate(clientesProvider),
  ),
);
```

## Patrón Repositorio — úsalo exactamente así

```dart
class ClienteRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Cliente>> obtenerTodos() async {
    try {
      final rows = await _db.queryAll(
        'clientes',
        where: 'activo = ?',
        whereArgs: [1],
        orderBy: 'nombre ASC',
      );
      return rows.map(Cliente.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }
}
```

## Widgets disponibles en lib/widgets/

```dart
AppCard(child: widget)
StatCard(titulo: '', valor: '', icono: Icons.x, color: AppColors.x)
LoadingButton(texto: '', onPressed: fn, isLoading: bool)
EmptyState(mensaje: '', icono: Icons.x)
ConfirmDialog.show(context, titulo: '', mensaje: '') // retorna Future<bool>
ClienteAvatar(nombre: '', apellido: '', fotoPath: null)
PagoListTile(pago: pago, cliente: cliente)
PrestamoCard(prestamo: prestamo, cliente: cliente)
SeccionHeader(titulo: '', onVerTodos: fn)
WhatsAppButton(telefono: '', mensaje: '')
AppErrorWidget(mensaje: '', onRetry: fn)
AppSnackBar.exito(context, mensaje)
AppSnackBar.error(context, mensaje)
AppSnackBar.advertencia(context, mensaje)
```

## Conversiones importantes

```dart
// Fecha DateTime ↔ String para SQLite
fecha.toIso8601String()        // guardar
DateTime.parse(map['fecha'])   // leer

// Boolean ↔ Integer para SQLite
activo ? 1 : 0                 // guardar
(map['activo'] as int) == 1    // leer

// Moneda
AppFormatters.moneda(1250.50)  // → "Q 1,250.50"

// Teléfono
AppFormatters.telefono('55551234')  // → "5555-1234"

// WhatsApp URL (Guatemala)
'https://wa.me/502${telefono}?text=${Uri.encodeComponent(mensaje)}'
```

## Cómo usar este archivo con Claude en VS Code

Cuando abras el chat de Claude en VS Code:
1. Escribe `@CLAUDE.md` para que Claude lea este contexto
2. Luego pide lo que necesitas, por ejemplo:
   - `@CLAUDE.md genera el modelo Cliente completo`
   - `@CLAUDE.md @lib/repositories/ crea el repositorio de pagos`
   - `@CLAUDE.md revisa @lib/screens/pagos/form_pago_screen.dart`

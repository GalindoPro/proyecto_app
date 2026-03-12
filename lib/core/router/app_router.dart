import 'package:go_router/go_router.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/auth/registro_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/clientes/clientes_screen.dart';
import '../../screens/clientes/detalle_cliente_screen.dart';
import '../../screens/clientes/form_cliente_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/pagos/detalle_pago_screen.dart';
import '../../screens/pagos/form_pago_screen.dart';
import '../../screens/pagos/pagos_screen.dart';
import '../../screens/prestamos/detalle_prestamo_screen.dart';
import '../../screens/prestamos/form_prestamo_screen.dart';
import '../../screens/prestamos/prestamos_screen.dart';
import '../../screens/reportes/reportes_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String dashboard = '/dashboard';
  static const String clientes = '/clientes';
  static const String nuevoCliente = '/clientes/nuevo';
  static const String pagos = '/pagos';
  static const String nuevoPago = '/pagos/nuevo';
  static const String prestamos = '/prestamos';
  static const String nuevoPrestamo = '/prestamos/nuevo';
  static const String reportes = '/reportes';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.registro,
      builder: (context, state) => const RegistroScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),

    // Clientes
    GoRoute(
      path: AppRoutes.clientes,
      builder: (context, state) => const ClientesScreen(),
    ),
    GoRoute(
      path: AppRoutes.nuevoCliente,
      builder: (context, state) => const FormClienteScreen(),
    ),
    GoRoute(
      path: '/clientes/:id',
      builder: (context, state) => DetalleClienteScreen(
        clienteId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/clientes/:id/editar',
      builder: (context, state) => FormClienteScreen(
        clienteId: state.pathParameters['id'],
      ),
    ),

    // Préstamos
    GoRoute(
      path: AppRoutes.prestamos,
      builder: (context, state) => const PrestamosScreen(),
    ),
    GoRoute(
      path: AppRoutes.nuevoPrestamo,
      builder: (context, state) {
        final clienteId = state.uri.queryParameters['clienteId'];
        return FormPrestamoScreen(clienteId: clienteId);
      },
    ),
    GoRoute(
      path: '/prestamos/:id',
      builder: (context, state) => DetallePrestamoScreen(
        prestamoId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/prestamos/:id/editar',
      builder: (context, state) => FormPrestamoScreen(
        prestamoId: state.pathParameters['id'],
      ),
    ),

    // Pagos
    GoRoute(
      path: AppRoutes.pagos,
      builder: (context, state) => const PagosScreen(),
    ),
    GoRoute(
      path: AppRoutes.nuevoPago,
      builder: (context, state) {
        final clienteId = state.uri.queryParameters['clienteId'];
        final prestamoId = state.uri.queryParameters['prestamoId'];
        return FormPagoScreen(
          clienteId: clienteId,
          prestamoId: prestamoId,
        );
      },
    ),
    GoRoute(
      path: '/pagos/:id',
      builder: (context, state) => DetallePagoScreen(
        pagoId: state.pathParameters['id']!,
      ),
    ),

    // Reportes
    GoRoute(
      path: AppRoutes.reportes,
      builder: (context, state) => const ReportesScreen(),
    ),
  ],
);

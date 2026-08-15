import 'package:go_router/go_router.dart';
import 'screens/checkout_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/restaurant_screen.dart';
import 'screens/tracking_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/restaurant/:id',
      builder: (context, state) => RestaurantScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
    GoRoute(path: '/tracking', builder: (context, state) => const TrackingScreen()),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  ],
);

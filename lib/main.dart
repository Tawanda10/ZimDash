import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'state/app_state.dart';
import 'state/cart_provider.dart';
import 'theme.dart';

void main() {
  runApp(const ZimDashApp());
}

class ZimDashApp extends StatefulWidget {
  const ZimDashApp({super.key});

  @override
  State<ZimDashApp> createState() => _ZimDashAppState();
}

class _ZimDashAppState extends State<ZimDashApp> {
  final _cart = CartProvider();
  final _appState = AppState();

  @override
  void initState() {
    super.initState();
    _cart.load();
    _appState.load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _cart),
        ChangeNotifierProvider.value(value: _appState),
      ],
      child: Consumer<AppState>(
        builder: (context, app, _) => MaterialApp.router(
          title: "ZimDash — Harare's food, delivered",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: app.themeMode,
          routerConfig: router,
        ),
      ),
    );
  }
}

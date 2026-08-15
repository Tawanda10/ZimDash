import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState app) async {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _emailError = _emailController.text.trim().isEmpty;
      _passwordError = _passwordController.text.trim().isEmpty;
    });
    if (_nameError || _emailError || _passwordError) {
      showZimToast(context, 'Please fill in all fields');
      return;
    }
    final name = _nameController.text.trim();
    await app.signIn(name, _emailController.text.trim());
    if (!mounted) return;
    showZimToast(context, 'Welcome, ${name.split(' ').first}!');
    context.go('/');
  }

  InputDecoration _deco(BuildContext context, String label, {String? error}) => InputDecoration(
        labelText: label,
        errorText: error,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.zim.line, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.zim.line, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.forest, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.flame, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return AppShell(
      currentRoute: 'login',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sign in', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28)),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.zim.line),
                      borderRadius: BorderRadius.circular(AppRadius.rLg),
                    ),
                    child: app.user != null ? _Account(user: app.user!, app: app) : _buildForm(context, app),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: AppColors.marigold, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('👤', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Text('Welcome back', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
        ]),
        const SizedBox(height: 18),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() => _nameError = false),
          decoration: _deco(context, 'Full name', error: _nameError ? 'Please enter your name.' : null),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() => _emailError = false),
          decoration: _deco(context, 'Email', error: _emailError ? 'Please enter your email.' : null),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: true,
          onChanged: (_) => setState(() => _passwordError = false),
          decoration: _deco(context, 'Password', error: _passwordError ? 'Please enter your password.' : null),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _submit(app),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.flame,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              elevation: 0,
            ),
            child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'Demo app — any name, email and password will do.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.zim.inkSoft, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

class _Account extends StatelessWidget {
  final ZimUser user;
  final AppState app;
  const _Account({required this.user, required this.app});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: AppColors.marigold, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('✅', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Text('Signed in', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
        ]),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 15),
            children: [
              const TextSpan(text: "You're signed in as "),
              TextSpan(text: user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(user.email, style: TextStyle(color: context.zim.inkSoft)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              await app.signOut();
              if (context.mounted) showZimToast(context, 'Signed out');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              side: BorderSide(color: context.zim.line),
              foregroundColor: context.zim.ink,
            ),
            child: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

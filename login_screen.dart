import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  if (!_isLogin)
                    TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم الكامل')),
                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
                  TextField(controller: _pass, decoration: const InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
                  if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() { _loading = true; _error = null; });
                            try {
                              AppUser user;
                              if (_isLogin) {
                                user = await auth.signIn(_email.text.trim(), _pass.text);
                              } else {
                                user = await auth.register(_name.text.trim(), _email.text.trim(), _pass.text);
                              }
                              if (mounted) Navigator.of(context).pushReplacementNamed('/home', arguments: user);
                            } catch (e) {
                              setState(() => _error = 'تعذر تسجيل الدخول: ${e.toString()}');
                            } finally {
                              if (mounted) setState(() => _loading = false);
                            }
                          },
                    child: Text(_isLogin ? 'دخول' : 'تسجيل'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? 'ليس لديك حساب؟ سجل الآن' : 'لديك حساب؟ سجّل الدخول'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

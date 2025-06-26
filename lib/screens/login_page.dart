// login_page.dart (API version)

import 'package:flutter/material.dart';
import '../screens/login_controller.dart';
import 'home_page.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginController = LoginController();

  bool isLoading = false;
  bool isLoginMode = true;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    bool success = false;
    if (isLoginMode) {
      success = await loginController.loginWithEmail(email, password);
    } else {
      success = await loginController.registerWithEmail(email, password);
    }

    if (!mounted) return;

    if (success) {
      final isAdmin = await loginController.isAdminUser();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isAdmin ? AdminDashboard(isAdmin: true) : const HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLoginMode ? 'Login gagal' : 'Registrasi gagal')),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.newspaper_rounded, size: 64, color: Colors.blue[900]),
              const SizedBox(height: 16),
              Text(
                isLoginMode ? 'Login ke Berita Garut' : 'Register Akun Baru',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value!.contains('@') ? null : 'Email tidak valid',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value!.length >= 6 ? null : 'Minimal 6 karakter',
                    ),
                    const SizedBox(height: 24),
                    isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blue[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _submit,
                              child: Text(isLoginMode ? 'Login' : 'Register'),
                            ),
                          ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => isLoginMode = !isLoginMode),
                      child: Text(
                        isLoginMode ? 'Belum punya akun? Daftar di sini' : 'Sudah punya akun? Login',
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

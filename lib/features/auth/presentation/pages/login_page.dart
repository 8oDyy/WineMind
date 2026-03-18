import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bubble_painter.dart';
import '../../../../injection_container.dart' as di;
import '../../../../app.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
          LoginWithEmailPasswordEvent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Se connecter",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
          }
        },
        builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Bulle Paul ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset('assets/img/Paul_Happy.png', height: 70),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PAUL",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryWine,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CustomPaint(
                            painter: BubblePainter(),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              child: const Text(
                                "Rebonjour 👋 Ravi de vous revoir sur WineMind ! "
                                "Comment souhaitez-vous vous connecter : "
                                "avec Google ou votre compte WineMind ?",
                                style: TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Formulaire ──
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        label: "Adresse email",
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Requis";
                          if (!v.contains('@')) return "Email invalide";
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Mot de passe",
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Requis";
                          if (v.length < 6) return "6 caractères minimum";
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Mot de passe oublié
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO : mot de passe oublié
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryWine,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton Se connecter
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _submit,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.login, size: 18),
                          label: Text(
                            isLoading
                                ? "Connexion en cours..."
                                : "Se connecter avec un email",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryWine,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Séparateur ──
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "ou",
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Bouton Google ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO : Google Sign In
                    },
                    icon: SvgPicture.network(
                      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                      height: 20,
                    ),
                    label: const Text(
                      "Continuer avec Google",
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "L'abus d'alcool est dangereux pour la santé",
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryWine, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

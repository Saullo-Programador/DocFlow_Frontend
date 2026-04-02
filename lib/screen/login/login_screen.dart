import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manege_doc/controller/custom_button.dart';
import 'package:manege_doc/controller/custom_input.dart';
import 'package:manege_doc/features/auth/presentation/providers/auth_provider.dart';
import 'package:manege_doc/screen/forgotPassword/forgot_password_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      _nameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      context.go("/dashboard");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: isSmallScreen ? double.infinity : 500,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone/Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.folder_shared_outlined,
                          size: 50,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Título
                      Text(
                        'Bem-vindo ao DocFlow',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Subtítulo
                      Text(
                        'Faça login para acessar seus documentos',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Campo de Usuário
                      CustomInput(
                        controller: _nameController,
                        label: "Usuário",
                        hint: "Digite seu nome de usuário",
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo obrigatório";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de Senha
                      CustomInput(
                        controller: _passwordController,
                        label: "Senha",
                        isPassword: true,
                        hint: "Digite sua senha",
                        icon: Icons.lock_outline,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo obrigatório";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Esqueci minha senha
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Esqueci minha senha",
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (context.watch<AuthProvider>().errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            context.watch<AuthProvider>().errorMessage!,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                      // Botão Entrar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CustomButton(
                          text: "Entrar",
                          isLoading: authProvider.isLoading,
                          onPressed: authProvider.isLoading? null : () =>_login(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Link para Cadastro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Não tem uma conta?",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () => context.go("/register"),
                            child: Text(
                              "Cadastre-se",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

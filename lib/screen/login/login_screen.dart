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
  bool _obscurePassword = true;
  final _userFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _userFocusNode.dispose();
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
          backgroundColor: theme.colorScheme.background,
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
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.surface.withValues(alpha: 0.08),
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
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.folder_shared_outlined,
                          size: 50,
                          color: theme.colorScheme.primary.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Título
                      Text(
                        'Bem-vindo ao DocFlow',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Subtítulo
                      Text(
                        'Faça login para acessar seus documentos',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

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
                        focusNode: _userFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_){
                          Focus.of(context).requestFocus(_passwordFocusNode);
                        },
                      ),
                      const SizedBox(height: 12),

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
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) async{
                          await _login();
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
                              color: theme.colorScheme.primary.withValues(alpha: 0.9),
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
                            style: TextStyle(color: theme.colorScheme.error.withValues(alpha: 0.9)),
                          ),
                        ),
                      // Botão Entrar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CustomButton(
                          color: theme.colorScheme.primary,
                          text: "Entrar",
                          isLoading: authProvider.isLoading,
                          onPressed: authProvider.isLoading
                              ? null
                              : () => _login(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Link para Cadastro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Não tem uma conta?",
                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          ),
                          TextButton(
                            onPressed: () => context.go("/register"),
                            child: Text(
                              "Cadastre-se",
                              style: TextStyle(
                                color: theme.colorScheme.primary.withValues(alpha: 0.9),
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

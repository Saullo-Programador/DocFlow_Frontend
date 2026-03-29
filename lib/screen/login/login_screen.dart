import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manege_doc/controller/custom_button.dart';
import 'package:manege_doc/controller/custom_input.dart';
import 'package:manege_doc/screen/forgotPassword/forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: isSmallScreen ? double.infinity : 500,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
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

                // Campo de E-mail
                CustomInput(
                  label: "E-mail",
                  hint: "Digite seu email@exemplo.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
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
                          builder: (context) => const ForgotPasswordScreen(),
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

                // Botão Entrar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomButton(
                    text: "Entrar",
                    isLoading: false,
                    onPressed: () => context.go("/dashboard"),
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
    );
  }
}
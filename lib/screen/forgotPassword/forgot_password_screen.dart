import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manege_doc/controller/custom_button.dart';
import 'package:manege_doc/controller/custom_input.dart';
import 'package:manege_doc/screen/forgotPassword/verification_code_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                // Botão Voltar
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Voltar',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Ícone de Cadeado/Esqueci Senha
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 50,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Título
                Text(
                  'Esqueceu sua senha?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtítulo
                Text(
                  'Digite seu e-mail e enviaremos um código para redefinir sua senha.',
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
                const SizedBox(height: 24),

                // Botão Enviar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomButton(
                    text: "Enviar Código",
                    isLoading: false,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerificationCodeScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Link para Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Lembrou sua senha?",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () => context.go("/login"),
                      child: Text(
                        "Faça login",
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
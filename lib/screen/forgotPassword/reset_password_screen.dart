import 'package:flutter/material.dart';
import 'package:manege_doc/controller/custom_button.dart';
import 'package:manege_doc/controller/custom_input.dart';
import 'package:manege_doc/screen/login/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: MediaQuery.of(context).size.width < 600
                ? double.infinity
                : 500,
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // Título
                  Center(
                    child: Text(
                      "Nova Senha",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      "Crie uma senha forte para sua conta.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(height: 20),
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
                  SizedBox(height: 15),
                  CustomInput(
                    label: "Confirmar Senha",
                    isPassword: true,
                    hint: "Confirme sua senha",
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo obrigatório";
                      }
                      // Aqui você pode adicionar lógica para comparar com a senha anterior
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  CustomButton(
                    text: "Redefinir Senha",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Lógica para salvar a nova senha no backend
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Senha alterada com sucesso!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Volta para o Login, removendo todas as telas do fluxo
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

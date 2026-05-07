import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manege_doc/controller/custom_button.dart';
import 'package:manege_doc/controller/custom_input.dart';
import 'package:manege_doc/core/constants/type_role.dart';
import 'package:manege_doc/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  TypeRole? _selectedRole;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      _emailController.text.trim(),
      _selectedRole ?? TypeRole.USER,
      _passwordController.text.trim(),
      name: _nameController.text.trim(),
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
                      // Botão Voltar
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () => context.go("/login"),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
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
                      const SizedBox(height: 16),

                      // Ícone
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          size: 50,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Título
                      Text(
                        'Criar Conta',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Subtítulo
                      Text(
                        'Preencha os dados abaixo para se cadastrar',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de Usuário
                      CustomInput(
                        controller: _nameController,
                        onChanged: (_) =>
                            context.read<AuthProvider>().clearError(),
                        label: "Usuário",
                        hint: "Digite seu usuário",
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo obrigatório";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Campo de E-mail
                      CustomInput(
                        controller: _emailController,
                        onChanged: (_) =>
                            context.read<AuthProvider>().clearError(),
                        label: "E-mail",
                        hint: "Digite seu email@exemplo.com",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo obrigatório";
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

                          if (!emailRegex.hasMatch(value)) {
                            return "Email inválido";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Campo de Perfil
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Perfil",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Campo de Role
                          DropdownButtonFormField<TypeRole>(
                            initialValue: _selectedRole,
                            decoration: InputDecoration(
                              hintText: 'Selecione um perfil',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withValues(alpha: 0.1),
                            ),
                            items: TypeRole.values
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedRole = value);
                              context.read<AuthProvider>().clearError();
                            },
                            validator: (value) {
                              if (value == null) return 'Selecione um perfil';
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Campo de Senha
                      CustomInput(
                        controller: _passwordController,
                        onChanged: (_) =>
                            context.read<AuthProvider>().clearError(),
                        label: "Senha",
                        isPassword: true,
                        hint: "Digite sua senha",
                        icon: Icons.lock_outline,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo obrigatório";
                          }
                          if (value.length < 6) {
                            return "A senha deve conter no mínimo 6 caracteres";
                          }
                          return null;
                        },
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Campo de Confirmar Senha
                      CustomInput(
                        controller: _confirmPasswordController,
                        onChanged: (_) =>
                            context.read<AuthProvider>().clearError(),
                        label: "Confirmar Senha",
                        isPassword: true,
                        hint: "Digite sua senha novamente",
                        icon: Icons.lock_outline,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo obrigatório";
                          }
                          if (value != _passwordController.text) {
                            return "As senhas não coincidem";
                          }
                          return null;
                        },
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Botão Registrar
                      if (authProvider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CustomButton(
                          text: "Criar Conta",
                          isLoading: authProvider.isLoading,
                          onPressed: authProvider.isLoading
                              ? null
                              : () => _register(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Link para Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Já tem uma conta?",
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
          ),
        );
      },
    );
  }
}

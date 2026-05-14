import 'package:flutter/material.dart';
import 'package:manege_doc/core/constants/app_constants.dart';
import 'package:manege_doc/features/users/presentation/providers/users_provider.dart';
import 'package:manege_doc/responsive/responsive.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController roleController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    emailController = TextEditingController();
    roleController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUser();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    roleController.dispose();

    super.dispose();
  }

  Future<void> loadUser() async {
    final provider = context.read<UsersProvider>();

    await provider.getCurrentUser();

    final user = provider.currentUser;

    if (user == null) return;

    nameController.text = user.name ?? "";
    emailController.text = user.email;
    roleController.text = user.role.label;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    final userProvider = context.read<UsersProvider>();
    final user = userProvider.currentUser;

    return SafeArea(
      child: userProvider.state == UsersState.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(
                isMobile ? 16 : AppConstants.defaultPadding,
              ),
              child: Center(
                child: Container(
                  width: isDesktop ? 900 : double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1000),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.05),
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Botão Voltar
                              InkWell(
                                onTap: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                },
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
                                        'Voltar para Configurações',
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Perfil",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Gerencie suas informações pessoais",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Conteúdo
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: _buildProfileCard(
                                        context,
                                        email:
                                            user?.email ?? "usuario@email.com",
                                        name: user?.name ?? "Usuário",
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    Expanded(
                                      flex: 2,
                                      child: _buildProfileForm(context),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildProfileCard(
                                      context,
                                      email: user?.email ?? "usuario@email.com",
                                      name: user?.name ?? "Usuário",
                                    ),
                                    const SizedBox(height: 24),
                                    _buildProfileForm(context),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    String email = "usuario@email.com",
    String name = "Usuário",
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                child: Icon(Icons.person, size: 60, color: theme.primaryColor),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 18),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Editar Foto"),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primaryColor,
              side: BorderSide(color: theme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UsersProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Informações Pessoais",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),

        // Campos do formulário
        _buildTextField(
          context,
          label: "Nome",
          hint: "Digite seu nome",
          icon: Icons.person_outline,
          controller: nameController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context,
          label: "E-mail",
          hint: "Digite seu e-mail",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context,
          label: "Cargo",
          hint: "Digite seu cargo",
          icon: Icons.work_outline,
          controller: roleController,
          enabled: false,
        ),
        const SizedBox(height: 16),

        const SizedBox(height: 32),

        // Botões de ação
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Cancelar"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: userProvider.state == UsersState.updating
                    ? null
                    : () async {
                        final success = await context
                            .read<UsersProvider>()
                            .updateProfile(name: nameController.text);

                        if (!mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Perfil atualizado")),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: userProvider.state == UsersState.updating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Salvar Alterações"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextEditingController? controller,
    //Senha
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          enabled: enabled,
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  )
                : null,

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
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manege_doc/constants.dart';
import 'package:manege_doc/responsive/responsive.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : defaultPadding),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1200),
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
                        Text(
                          "Configurações",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Gerencie suas preferências e configurações da conta",
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seção: Conta
                        _buildSectionTitle(context, "Conta"),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              _buildSettingTile(
                                context,
                                icon: Icons.person_outline,
                                title: "Perfil",
                                subtitle: "Editar informações pessoais",
                                onTap: () => context.push('/profile'),
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _buildSettingTile(
                                context,
                                icon: Icons.lock_outline,
                                title: "Segurança",
                                subtitle: "Alterar senha e autenticação",
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Seção: Preferências
                        _buildSectionTitle(context, "Preferências"),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              _buildSettingTile(
                                context,
                                icon: Icons.notifications_outlined,
                                title: "Notificações",
                                subtitle: "Gerenciar alertas e lembretes",
                                onTap: () {},
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _buildSettingTile(
                                context,
                                icon: Icons.palette_outlined,
                                title: "Aparência",
                                subtitle: "Tema e personalização",
                                onTap: () {},
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _buildSettingTile(
                                context,
                                icon: Icons.language_outlined,
                                title: "Idioma",
                                subtitle: "Português (Brasil)",
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Seção: Sair
                        _buildSectionTitle(context, "Sessão"),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.exit_to_app, color: Colors.red),
                            title: const Text(
                              "Sair da conta",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text("Encerrar sua sessão atual"),
                            trailing: const Icon(Icons.chevron_right, color: Colors.red),
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Versão do app
                        Center(
                          child: Text(
                            "DocFlow v1.0.0",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Sair"),
          content: const Text("Tem certeza que deseja encerrar a sessão?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Sair",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                context.go('/login');
              },
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:manege_doc/controller/custom_button.dart';
import 'package:manege_doc/core/constants/app_constants.dart';
import 'package:manege_doc/core/constants/type_role.dart';
import 'package:manege_doc/features/users/domain/entities/user_profile_entity.dart';
import 'package:manege_doc/features/users/presentation/providers/users_provider.dart';
import 'package:manege_doc/screen/users_screen/components/item_users.dart';
import 'package:provider/provider.dart';
import 'package:manege_doc/responsive/responsive.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  UserProfileEntity? selectedUser;
  bool _isEditing = false; // ← novo

  // Controllers para edição
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  TypeRole? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().getAllUsers();
    });
  }

  // Abre painel já em modo edição
  void _editUsers(UserProfileEntity user) {
    if (Responsive.isMobile(context)) {
      // Mobile → abre bottomSheet já em edição
      _startEditing(user);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: _buildUserDetails(Theme.of(context), user: user),
          ),
        ),
      );
    } else {
      // Desktop → painel lateral já em edição, tudo num único setState
      _nameController.text = user.name ?? '';
      _emailController.text = user.email;
      _selectedRole = user.role;
      setState(() {
        selectedUser = user;
        _isEditing = true; // ← junto com o selectedUser
      });
    }
  }

  // Ativa modo edição populando os controllers
  void _startEditing(UserProfileEntity user) {
    _nameController.text = user.name ?? '';
    _emailController.text = user.email;
    _selectedRole = user.role;
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  void _deleteUsers(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Deletar Usuário"),
        content: const Text("Tem certeza que deseja excluir este usuário?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await context.read<UsersProvider>().deleteUser(id);

    if (success && selectedUser?.id == id) {
      setState(() {
        selectedUser = null;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Usuário deletado com sucesso!"
                : "Falha ao deletar usuário. Tente novamente.",
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _saveEditing() async {
    if (selectedUser == null) return;

    final success = await context.read<UsersProvider>().updateUser(
      selectedUser!.id,
      name: _nameController.text,
      role: _selectedRole,
    );

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuário atualizado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _onSelectUser(UserProfileEntity user) {
    if (Responsive.isMobile(context)) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: _buildUserDetails(Theme.of(context), user: user),
          ),
        ),
      );
    } else {
      setState(() {
        selectedUser = user;
        _isEditing = false; // reseta ao trocar usuário
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);
    final userProvider = context.watch<UsersProvider>();
    final isLoading = userProvider.state == UsersState.loading;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : AppConstants.defaultPadding),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1200),
            // ← altura da tela menos o padding
            height:
                MediaQuery.of(context).size.height -
                (isMobile ? 32 : AppConstants.defaultPadding * 2),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header — estático
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
                                "Usuarios",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Gerencie seus usuários e permissões",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Lista — ocupa o espaço restante com scroll
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : userProvider.users.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Nenhum item encontrado",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (isDesktop &&
                                          constraints.maxWidth > 800) {
                                        return GridView.builder(
                                          // ← scroll automático do GridView
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                maxCrossAxisExtent: 300,
                                                childAspectRatio: 3,
                                                crossAxisSpacing: 12,
                                                mainAxisSpacing: 12,
                                              ),
                                          itemCount: userProvider.users.length,
                                          itemBuilder: (context, index) {
                                            final user =
                                                userProvider.users[index];
                                            return ItemUsers(
                                              userName: user.name ?? "",
                                              role: user.role.label,
                                              onTap: () => _onSelectUser(user),
                                              onDeleteUsers: () =>
                                                  _deleteUsers(user.id),
                                              onEditUsers: () =>
                                                  _editUsers(user),
                                            );
                                          },
                                        );
                                      }

                                      return ListView.builder(
                                        // ← scroll automático do ListView
                                        itemCount: userProvider.users.length,
                                        itemBuilder: (context, index) {
                                          final user =
                                              userProvider.users[index];
                                          return ItemUsers(
                                            userName: user.name ?? '',
                                            role: user.role.label,
                                            onTap: () => _onSelectUser(user),
                                            onDeleteUsers: () =>
                                                _deleteUsers(user.id),
                                            onEditUsers: () => _editUsers(user),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Painel lateral
                  if (selectedUser != null)
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          left: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: _buildUserDetails(theme),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails(ThemeData theme, {UserProfileEntity? user}) {
    final u = user ?? selectedUser!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com ações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_isEditing)
                TextButton.icon(
                  onPressed: _cancelEditing,
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  label: const Text(
                    "Cancelar",
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                )
              else
                IconButton(
                  tooltip: "Editar",
                  onPressed: () => _startEditing(u),
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                ),

              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      selectedUser = null;
                      _isEditing = false;
                    }),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),

          // Avatar
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              backgroundImage: u.avatarUrl != null
                  ? NetworkImage(u.avatarUrl!)
                  : null,
              child: u.avatarUrl == null
                  ? Text(
                      u.name?.isNotEmpty == true
                          ? u.name![0].toUpperCase()
                          : '',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 24),

          // Campos — leitura ou edição
          if (_isEditing) ...[
            _editField("Nome", _nameController),
            const SizedBox(height: 16),
            _detailItem("Email", u.email), // email não editável
            const SizedBox(height: 10),
            _roleDropdown(theme),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _saveEditing,
                icon: Icons.check,
                text: "Salvar",
              ),
            ),
          ] else ...[
            _detailItem("Nome", u.name ?? ''),
            _detailItem("Email", u.email),
            _detailItem("Cargo", u.role.label),
            _detailItem(
              "Cadastrado em",
              u.createdAt != null
                  ? "${u.createdAt!.day}/${u.createdAt!.month}/${u.createdAt!.year}"
                  : "Data não disponível",
            ),
          ],
        ],
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _roleDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cargo",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<TypeRole>(
          initialValue: _selectedRole,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: TypeRole.values.map((role) {
            return DropdownMenuItem(value: role, child: Text(role.label));
          }).toList(),
          onChanged: (value) => setState(() => _selectedRole = value),
        ),
      ],
    );
  }

  Widget _detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

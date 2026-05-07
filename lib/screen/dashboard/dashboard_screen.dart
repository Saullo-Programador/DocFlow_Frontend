import 'package:flutter/material.dart';
import 'package:manege_doc/core/constants/app_constants.dart';
import 'package:manege_doc/features/files/presentation/providers/files_provider.dart';
import 'package:manege_doc/features/folders/presentation/providers/folders_provider.dart';
import 'package:manege_doc/features/history/domain/entities/history_item_entity.dart';
import 'package:manege_doc/features/history/presentation/providers/history_provider.dart';
import 'package:manege_doc/features/users/presentation/providers/users_provider.dart';
import 'package:manege_doc/responsive/responsive.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerFolder = context.read<FoldersProvider>();
      final providerFiles = context.read<FilesProvider>();
      final providerUsers = context.read<UsersProvider>();
      final providerHistory = context.read<HistoryProvider>();

      if (providerFolder.foldersCount == 0) {
        providerFolder.getFoldersCount();
      }

      if (providerFiles.filesCount == 0) {
        providerFiles.getFilesCount();
      }

      if (providerUsers.usersCount == 0) {
        providerUsers.getUsersCount();
      }

      if (providerHistory.history.isEmpty) {
        providerHistory.getHistory(limit: 10, refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    final foldersProvider = context.watch<FoldersProvider>();
    final filesProvider = context.watch<FilesProvider>();
    final usersProvider = context.watch<UsersProvider>();
    final historyProvider = context.watch<HistoryProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : AppConstants.defaultPadding),
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
                          "Dashboard",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Visão geral do seu sistema de documentos",
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
                        // Cards de estatísticas
                        _buildStats(
                          foldersProvider,
                          filesProvider,
                          usersProvider,
                        ),

                        const SizedBox(height: 32),

                        _buildHistoryCard(historyProvider),
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

  // Widget _buildStatCard(
  //   BuildContext context, {
  //   required IconData icon,
  //   required String title,
  //   required String value,
  //   required Color color,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[50],
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey[200]!),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(10),
  //           decoration: BoxDecoration(
  //             color: color.withValues(alpha: 0.1),
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: Icon(icon, color: color, size: 24),
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           value,
  //           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
  //         const SizedBox(height: 8),
  //       ],
  //     ),
  //   );
  // }

  // =========================
  // 📊 CARDS
  // =========================

  Widget _buildStats(
    FoldersProvider folders,
    FilesProvider files,
    UsersProvider users,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1000 ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            _stat(
              Icons.folder,
              "Pastas",
              folders.state == FoldersState.loading
                  ? "..."
                  : folders.foldersCount.toString(),
              Colors.blue,
            ),

            _stat(
              Icons.insert_drive_file,
              "Documentos",
              files.state == FilesState.loading
                  ? "..."
                  : files.filesCount.toString(),
              Colors.green,
            ),

            _stat(
              Icons.people,
              "Usuários",
              users.state == UsersState.loading
                  ? "..."
                  : users.usersCount.toString(),
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _stat(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),//Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 40),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22)),
          Text(title, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // =========================
  // 🕒 HISTÓRICO
  // =========================

  Widget _buildHistoryCard(HistoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Atividades Recentes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/history");
                },
                child: const Text("Ver mais"),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildRecentActivities(provider),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(HistoryProvider provider) {
    final isMobile = Responsive.isMobile(context);

    if (provider.state == HistoryState.loading && provider.history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state == HistoryState.error) {
      return Text(provider.errorMessage ?? "Erro");
    }

    if (provider.history.isEmpty) {
      return const Text("Nenhuma atividade recente");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.history.length > 10 ? 10 : provider.history.length,
      itemBuilder: (context, index) {
        final item = provider.history[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: _getIcon(item),
              title: Text(
                item.userName ?? "Sistema",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: isMobile
                  ? null
                  : Text(
                      _formatDate(item.timestamp),
                      style: const TextStyle(fontSize: 12),
                    ),
            ),

            if (isMobile)
              Padding(
                padding: const EdgeInsets.only(left: 72, bottom: 8),
                child: Text(
                  _formatDate(item.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
          ],
        );
      },
    );
  }

  // =========================
  // 🎨 HELPERS
  // =========================

  Icon _getIcon(HistoryItemEntity item) {
    switch (item.targetType) {
      case HistoryTargetType.folder:
        return const Icon(Icons.folder, color: Colors.blue);
      case HistoryTargetType.file:
        return const Icon(Icons.insert_drive_file, color: Colors.green);
      case HistoryTargetType.user:
        return const Icon(Icons.person, color: Colors.purple);
      default:
        return const Icon(Icons.history);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return "Hoje";
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) {
      return "Ontem";
    }

    return "${date.day}/${date.month}/${date.year}";
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/password_recovery_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/files/data/datasources/files_remote_datasource.dart';
import '../../features/files/data/repositories/files_repository_impl.dart';
import '../../features/files/domain/repositories/files_repository.dart';
import '../../features/files/domain/usecases/files_usecases.dart';
import '../../features/files/presentation/providers/files_provider.dart';
import '../../features/folders/data/datasources/folders_remote_datasource.dart';
import '../../features/folders/data/repositories/folders_repository_impl.dart';
import '../../features/folders/domain/repositories/folders_repository.dart';
import '../../features/folders/domain/usecases/folders_usecases.dart';
import '../../features/folders/presentation/providers/folders_provider.dart';
import '../../features/history/data/datasources/history_remote_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/history_usecases.dart';
import '../../features/history/presentation/providers/history_provider.dart';
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_usecases.dart';
import '../../features/search/presentation/providers/search_provider.dart';
import '../../features/users/data/datasources/users_remote_datasource.dart';
import '../../features/users/data/repositories/users_repository_impl.dart';
import '../../features/users/domain/repositories/users_repository.dart';
import '../../features/users/domain/usecases/users_usecases.dart';
import '../../features/users/presentation/providers/users_provider.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';

/// Instância global do GetIt
final GetIt sl = GetIt.instance;

/// Inicializa a injeção de dependências
Future<void> initDependencies() async {
  // ===== External Dependencies =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Logger());

  // ===== Core =====
  _initCore();

  // ===== Features =====
  _initAuth();
  _initFiles();
  _initFolders();
  _initHistory();
  _initSearch();
  _initUsers();
}

/// Inicializa dependências do core
void _initCore() {
  // Local Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Interceptors
  sl.registerLazySingleton(
    () => AuthInterceptor(
      localDataSource: sl(),
      logger: sl(),
    ),
  );

  // Dio Client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      authInterceptor: sl(),
      logger: sl(),
    ),
  );
}

/// Inicializa dependências de autenticação
void _initAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => IsLoggedInUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // Provider factory (não singleton - cria nova instância)
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      isLoggedInUseCase: sl(),
      getCurrentUserUseCase: sl(),
      forgotPasswordUseCase: sl(),
      verifyCodeUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );
}

/// Inicializa dependências de arquivos
void _initFiles() {
  // Data sources
  sl.registerLazySingleton<FilesRemoteDataSource>(
    () => FilesRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<FilesRepository>(
    () => FilesRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFilesUseCase(sl()));
  sl.registerLazySingleton(() => UploadFileUseCase(sl()));
  sl.registerLazySingleton(() => DownloadFileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteFileUseCase(sl()));
  sl.registerLazySingleton(() => RenameFileUseCase(sl()));
  sl.registerLazySingleton(() => MoveFileUseCase(sl()));
  sl.registerLazySingleton(() => GetLatestUploadsUseCase(sl()));
  sl.registerLazySingleton(() => GetFilesCountUseCase(sl()));

  // Provider
  sl.registerFactory(() => FilesProvider(
    getFilesUseCase: sl(),
    uploadFileUseCase: sl(),
    downloadFileUseCase: sl(),
    deleteFileUseCase: sl(),
    renameFileUseCase: sl(),
    moveFileUseCase: sl(),
    getLatestUploadsUseCase: sl(),
  ));
}

/// Inicializa dependências de pastas
void _initFolders() {
  // Data sources
  sl.registerLazySingleton<FoldersRemoteDataSource>(
    () => FoldersRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<FoldersRepository>(
    () => FoldersRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRootFoldersUseCase(sl()));
  sl.registerLazySingleton(() => GetFolderContentUseCase(sl()));
  sl.registerLazySingleton(() => CreateFolderUseCase(sl()));
  sl.registerLazySingleton(() => GetChildFoldersUseCase(sl()));
  sl.registerLazySingleton(() => RenameFolderUseCase(sl()));
  sl.registerLazySingleton(() => DeleteFolderUseCase(sl()));
  sl.registerLazySingleton(() => GetFoldersCountUseCase(sl()));

  // Provider
  sl.registerFactory(() => FoldersProvider(
    getRootFoldersUseCase: sl(),
    getFolderContentUseCase: sl(),
    createFolderUseCase: sl(),
    renameFolderUseCase: sl(),
    deleteFolderUseCase: sl(),
  ));
}

/// Inicializa dependências de histórico
void _initHistory() {
  // Data sources
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetFileHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetFolderHistoryUseCase(sl()));

  // Provider
  sl.registerFactory(() => HistoryProvider(
    getHistoryUseCase: sl(),
    getFileHistoryUseCase: sl(),
    getFolderHistoryUseCase: sl(),
  ));
}

/// Inicializa dependências de busca
void _initSearch() {
  // Data sources
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchGlobalUseCase(sl()));
  sl.registerLazySingleton(() => SearchFilesUseCase(sl()));
  sl.registerLazySingleton(() => SearchFoldersUseCase(sl()));
  sl.registerLazySingleton(() => SearchInFolderUseCase(sl()));

  // Provider
  sl.registerFactory(() => SearchProvider(
    searchGlobalUseCase: sl(),
    searchFilesUseCase: sl(),
    searchFoldersUseCase: sl(),
    searchInFolderUseCase: sl(),
  ));
}

/// Inicializa dependências de usuários
void _initUsers() {
  // Data sources
  sl.registerLazySingleton<UsersRemoteDataSource>(
    () => UsersRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersCountUseCase(sl()));

  // Provider
  sl.registerFactory(() => UsersProvider(
    getCurrentUserProfileUseCase: sl(),
    getAllUsersUseCase: sl(),
    updateProfileUseCase: sl(),
    changePasswordUseCase: sl(),
  ));
}

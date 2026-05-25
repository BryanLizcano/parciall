import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'application/providers/auth_provider.dart';
import 'application/providers/category_provider.dart';
import 'application/providers/chat_provider.dart';
import 'application/providers/image_provider.dart';
import 'application/providers/service_provider.dart';
import 'application/providers/user_provider.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/repositories/image_repository.dart';
import 'domain/repositories/service_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'infrastructure/repositories/category_repository_impl.dart';
import 'infrastructure/repositories/chat_repository_impl.dart';
import 'infrastructure/repositories/image_repository_impl.dart';
import 'infrastructure/repositories/service_repository_impl.dart';
import 'infrastructure/repositories/user_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // ── 1. External ───────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // ── 2. Repositories ───────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(storage: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(storage: sl()),
  );
  sl.registerLazySingleton<ImageRepository>(
        () => ImageRepositoryImpl(storage: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
        () => CategoryRepositoryImpl(),
  );
  sl.registerLazySingleton<ServiceRepository>(
        () => ServiceRepositoryImpl(authRepository: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
        () => ChatRepositoryImpl(authRepository: sl()),
  );

  // ── 3. Providers ──────────────────────────────────────────────────────────
  sl.registerFactory(() => AuthProvider(authRepository: sl()));
  sl.registerFactory(() => UserProvider(userRepository: sl()));
  sl.registerFactory(() => ImageProvider(imageRepository: sl()));
  sl.registerFactory(() => ChatProvider(chatRepository: sl()));
  sl.registerLazySingleton(
        () => CategoryProvider(categoryRepository: sl()),
  );
  sl.registerFactory(() => ServiceProvider(serviceRepository: sl()));
}
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parcial/domain/repositories/chat_repository.dart';

import 'application/providers/auth_provider.dart';
import 'application/providers/category_provider.dart';
import 'application/providers/image_provider.dart';
import 'application/providers/service_provider.dart';
import 'application/providers/user_provider.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/repositories/image_repository.dart';
import 'domain/repositories/service_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'infrastructure/repositories/category_repository_impl.dart';
import 'infrastructure/repositories/image_repository_impl.dart';
import 'infrastructure/repositories/service_repository_impl.dart';
import 'infrastructure/repositories/user_repository_impl.dart';
import 'infrastructure/repositories/chat_repository_impl.dart';
import 'application/providers/chat_provider.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initInjection() async {
  // ── 1. External (paquetes de terceros) ────────────────────────────────────
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // ── 2. Repositories ───────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(storage: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(storage: sl()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(authRepository: sl()),
  );
  sl.registerLazySingleton<ImageRepository>(
    () => ImageRepositoryImpl(storage: sl()),
  );
<<<<<<< HEAD
  // 3. Providers (Application / State Management)
  // Usamos un Factory para los Providers si queremos que se cree una nueva instancia al pedirla,
  // pero para Auth suele ser útil un Singleton para mantener el estado global.
  sl.registerFactory(
    () => AuthProvider(authRepository: sl()),
  );

  sl.registerFactory(
    () => UserProvider(userRepository: sl()),
  );
  sl.registerFactory(
    () => ImageProvider(imageRepository: sl()),
  );

  sl.registerFactory(
    () => ChatProvider(chatRepository: sl()),
  );
}
=======
  // CategoryRepository es público (no requiere auth), no necesita AuthRepository
  sl.registerLazySingleton<CategoryRepository>(
        () => CategoryRepositoryImpl(),
  );
  // ServiceRepository sí necesita el token JWT vía AuthRepository
  sl.registerLazySingleton<ServiceRepository>(
        () => ServiceRepositoryImpl(authRepository: sl()),
  );

  // ── 3. Providers (Application / State Management) ─────────────────────────
  sl.registerFactory(() => AuthProvider(authRepository: sl()));
  sl.registerFactory(() => UserProvider(userRepository: sl()));
  sl.registerFactory(() => ImageProvider(imageRepository: sl()));

  // CategoryProvider como LazySingleton para que el caché de sesión
  // (HU-15 CA-1) persista sin importar desde qué pantalla se llame.
  sl.registerLazySingleton(
        () => CategoryProvider(categoryRepository: sl()),
  );

  sl.registerFactory(() => ServiceProvider(serviceRepository: sl()));
}
>>>>>>> 08ca8d88840e97d7483c4410567c4263ca767c74

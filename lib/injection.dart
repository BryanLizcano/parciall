import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parcial/domain/repositories/chat_repository.dart';

import 'application/providers/image_provider.dart';
import 'application/providers/user_provider.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/image_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'application/providers/auth_provider.dart';
import 'infrastructure/repositories/image_repository_impl.dart';
import 'infrastructure/repositories/user_repository_impl.dart';
import 'infrastructure/repositories/chat_repository_impl.dart';
import 'application/providers/chat_provider.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initInjection() async {
  // 1. External (Paquetes de terceros)
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // 2. Repositories
  // Cuando pidamos un AuthRepository, GetIt nos dará la implementación concreta
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

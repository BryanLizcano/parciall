import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'domain/repositories/auth_repository.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'application/providers/auth_provider.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initInjection() async {
  // 1. External (Paquetes de terceros)
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // 2. Repositories
  // Cuando pidamos un AuthRepository, GetIt nos dará la implementación concreta
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(storage: sl()),
  );

  // 3. Providers (Application / State Management)
  // Usamos un Factory para los Providers si queremos que se cree una nueva instancia al pedirla,
  // pero para Auth suele ser útil un Singleton para mantener el estado global.
  sl.registerFactory(
        () => AuthProvider(authRepository: sl()),
  );
}
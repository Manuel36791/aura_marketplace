import 'package:core_di/core_di.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/datasources/fake_auth_interceptor.dart';
import '../../features/auth/data/interceptors/auth_interceptor.dart';
import 'injection.config.dart';

@InjectableInit(
  externalPackageModulesBefore: [ExternalModule(CoreDiPackageModule)],
)
Future<void> configureDependencies(String environment) async {
  await getIt.init(environment: environment);
  final dio = getIt<Dio>();
  final authInterceptor = getIt<AuthInterceptor>();
  final fakeAuthInterceptor = getIt<FakeAuthInterceptor>();

  if (!dio.interceptors.contains(authInterceptor)) {
    dio.interceptors.add(authInterceptor);
  }
  if (!dio.interceptors.contains(fakeAuthInterceptor)) {
    dio.interceptors.add(fakeAuthInterceptor);
  }
}

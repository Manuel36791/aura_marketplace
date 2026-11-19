// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:core_di/core_di.dart' as _i472;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:store/core/di/modules/storage_module.dart' as _i295;
import 'package:store/features/auth/data/datasources/auth_local_data_source.dart'
    as _i645;
import 'package:store/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i358;
import 'package:store/features/auth/data/datasources/fake_auth_interceptor.dart'
    as _i609;
import 'package:store/features/auth/data/interceptors/auth_interceptor.dart'
    as _i618;
import 'package:store/features/auth/data/repositories/auth_repository_impl.dart'
    as _i857;
import 'package:store/features/auth/domain/repositories/auth_repository.dart'
    as _i465;
import 'package:store/features/auth/domain/usecases/login_usecase.dart'
    as _i163;
import 'package:store/features/auth/domain/usecases/logout_usecase.dart'
    as _i722;
import 'package:store/features/auth/domain/usecases/register_usecase.dart'
    as _i546;
import 'package:store/features/auth/domain/usecases/restore_session_usecase.dart'
    as _i660;
import 'package:store/features/auth/presentation/bloc/auth_bloc.dart' as _i436;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    await _i472.CoreDiPackageModule().init(gh);
    final storageModule = _$StorageModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.secureStorage,
    );
    gh.lazySingleton<_i609.FakeAuthInterceptor>(
      () => _i609.FakeAuthInterceptor(),
    );
    gh.lazySingleton<_i645.AuthLocalDataSource>(
      () => _i645.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i358.AuthRemoteDataSource>(
      () => _i358.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i465.AuthRepository>(
      () => _i857.AuthRepositoryImpl(
        gh<_i358.AuthRemoteDataSource>(),
        gh<_i645.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i618.AuthInterceptor>(
      () => _i618.AuthInterceptor(
        gh<_i645.AuthLocalDataSource>(),
        gh<_i361.Dio>(),
      ),
    );
    gh.factory<_i163.LoginUseCase>(
      () => _i163.LoginUseCase(gh<_i465.AuthRepository>()),
    );
    gh.factory<_i722.LogoutUseCase>(
      () => _i722.LogoutUseCase(gh<_i465.AuthRepository>()),
    );
    gh.factory<_i546.RegisterUseCase>(
      () => _i546.RegisterUseCase(gh<_i465.AuthRepository>()),
    );
    gh.factory<_i660.RestoreSessionUseCase>(
      () => _i660.RestoreSessionUseCase(gh<_i465.AuthRepository>()),
    );
    gh.factory<_i436.AuthBloc>(
      () => _i436.AuthBloc(
        loginUseCase: gh<_i163.LoginUseCase>(),
        registerUseCase: gh<_i546.RegisterUseCase>(),
        logoutUseCase: gh<_i722.LogoutUseCase>(),
        restoreSessionUseCase: gh<_i660.RestoreSessionUseCase>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i295.StorageModule {}

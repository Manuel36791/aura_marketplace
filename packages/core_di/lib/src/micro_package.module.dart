// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_di/src/app_config.dart' as _i351;
import 'package:core_di/src/modules/app_config_module.dart' as _i815;
import 'package:core_di/src/modules/network_module.dart' as _i649;
import 'package:dio/dio.dart' as _i361;
import 'package:injectable/injectable.dart' as _i526;

const String _dev = 'dev';
const String _prod = 'prod';
const String _stg = 'stg';

class CoreDiPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final appConfigModule = _$AppConfigModule();
    final networkModule = _$NetworkModule();
    gh.singleton<_i351.AppConfig>(
      () => appConfigModule.devConfig(),
      registerFor: {_dev},
    );
    gh.singleton<_i351.AppConfig>(
      () => appConfigModule.prodConfig(),
      registerFor: {_prod},
    );
    gh.singleton<_i351.AppConfig>(
      () => appConfigModule.stagingConfig(),
      registerFor: {_stg},
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio(gh<_i351.AppConfig>()));
  }
}

class _$AppConfigModule extends _i815.AppConfigModule {}

class _$NetworkModule extends _i649.NetworkModule {}

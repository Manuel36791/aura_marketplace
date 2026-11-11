import 'package:core_di/core_di.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(
  externalPackageModulesBefore: [ExternalModule(CoreDiPackageModule)],
)
Future<void> configureDependencies(String environment) async =>
    getIt.init(environment: environment);

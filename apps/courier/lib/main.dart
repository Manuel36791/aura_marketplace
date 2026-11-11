import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'flavors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.values.firstWhere((f) => f.name == appFlavor);
  await configureDependencies(F.appFlavor.name);
  runApp(const App());
}

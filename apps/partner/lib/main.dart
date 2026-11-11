import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'flavors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(F.appFlavor.name);
  runApp(const App());
}

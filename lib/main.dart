import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_shell.dart';
import 'storage/case_store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = CaseStore(prefs);
  await store.load();
  runApp(SahayakApp(store: store));
}

class SahayakApp extends StatelessWidget {
  const SahayakApp({super.key, required this.store});

  final CaseStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahayak',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: HomeShell(store: store),
    );
  }
}

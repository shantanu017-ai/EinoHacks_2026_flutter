import 'package:material_ui/material_ui.dart';

import '../data/maternal_protocol.dart';
import '../storage/case_store.dart';
import '../theme.dart';
import 'history_tab.dart';
import 'home_tab.dart';
import 'screening_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});

  final CaseStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _startScreening() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScreeningScreen(
          protocol: maternalProtocol,
          store: widget.store,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeTab(
            store: widget.store,
            onStartScreening: _startScreening,
            onOpenHistory: () => setState(() => _index = 1),
          ),
          HistoryTab(
            store: widget.store,
            onStartScreening: () {
              setState(() => _index = 0);
              _startScreening();
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.health_and_safety_outlined),
              selectedIcon: Icon(Icons.health_and_safety),
              label: 'Screen',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: 'Referrals',
            ),
          ],
        ),
      ),
    );
  }
}

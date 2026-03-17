import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/bottom_nav_bar.dart';
import 'features/wine/presentation/bloc/cellar_bloc.dart';
import 'features/wine/presentation/bloc/wine_bloc.dart';
import 'features/wine/presentation/pages/cellar_page.dart';
import 'features/wine/presentation/pages/home_page.dart';
import 'features/wine/presentation/pages/wines_page.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WineMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<WineBloc>()),
          BlocProvider(create: (_) => sl<CellarBloc>()),
        ],
        child: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    WinesPage(),
    CellarPage(),
    SizedBox.shrink(),
  ];

  void _onScan() {
    showModalBottomSheet(
      context: context,
      builder: (_) => const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            '📷 Scanner une bouteille',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        onScan: _onScan,
      ),
    );
  }
}

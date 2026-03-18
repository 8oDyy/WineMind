import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/bottom_nav_bar.dart';
import 'features/wine/presentation/bloc/wine_bloc.dart';
import 'features/wine/presentation/bloc/cellar_bloc.dart';
import 'features/wine/presentation/pages/home_page.dart';
import 'features/wine/presentation/pages/cellar_page.dart';
import 'features/wine/presentation/pages/wines_page.dart';
import 'features/auth/presentation/pages/auth_choice_page.dart';
import 'injection_container.dart' as di;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WineBloc>(
          create: (_) => di.sl<WineBloc>(),
        ),
        BlocProvider<CellarBloc>(
          create: (_) => di.sl<CellarBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'WineMind',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _SplashGate(),
      ),
    );
  }
}

/// Vérifie si l'utilisateur est connecté au démarrage
/// → connecté    : MainScreen
/// → non connecté : AuthChoicePage
class _SplashGate extends StatelessWidget {
  const _SplashGate();

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const MainScreen();
    } else {
      return const AuthChoicePage();
    }
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
    Scaffold(body: Center(child: Text('Plus — à venir'))),
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
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        onScan: _onScan,
      ),
    );
  }
}
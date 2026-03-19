import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/theme/app_theme.dart';
import 'core/widgets/bottom_nav_bar.dart';
import 'features/auth/domain/entities/user_entity.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/ai/presentation/bloc/chat_bloc.dart';
import 'features/ai/presentation/bloc/chat_event.dart' as chat_events;
import 'features/auth/presentation/pages/auth_choice_page.dart';
import 'features/wine/presentation/bloc/cellar_bloc.dart';
import 'features/wine/presentation/bloc/wine_bloc.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/wine/presentation/pages/cellar_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/wine/presentation/pages/wines_page.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<WineBloc>()),
        BlocProvider(create: (_) => sl<CellarBloc>()),
        BlocProvider(create: (_) => sl<ChatBloc>()),
      ],
      child: MaterialApp(
        title: 'WineMind',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashGate(),
      ),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return const AuthChoicePage();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.read<ChatBloc>().add(const chat_events.ResetChatEvent());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) return MainScreen(user: state.user);
          if (state is AuthUnauthenticated) return const AuthChoicePage();
          if (state is AuthError) return const AuthChoicePage();
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final UserEntity user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const WinesPage(),
      const CellarPage(),
      SettingsPage(user: widget.user),
    ];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthChoicePage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

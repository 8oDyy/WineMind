import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/wine_bloc.dart';
import '../bloc/wine_event.dart';
import '../bloc/wine_state.dart';
import '../widgets/wine_last_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'WineMind',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryWine,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              BlocBuilder<WineBloc, WineState>(
                builder: (context, state) {
                  if (state is WineInitial) {
                    context.read<WineBloc>().add(const GetLastWineEvent());
                    return const SizedBox.shrink();
                  } else if (state is WineLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryWine,
                        ),
                      ),
                    );
                  } else if (state is WineLastLoaded) {
                    return WineLastCard(wine: state.wine);
                  } else if (state is WineError) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

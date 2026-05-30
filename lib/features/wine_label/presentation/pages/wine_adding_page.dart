import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wine_label_bloc.dart';
import '../bloc/wine_label_event.dart';
import '../bloc/wine_label_state.dart';
import '../../../wine/presentation/bloc/cellar_bloc.dart';
import '../../../wine/presentation/bloc/cellar_event.dart';

class WineAddingPage extends StatefulWidget {
  const WineAddingPage({super.key});

  @override
  State<WineAddingPage> createState() => _WineAddingPageState();
}

class _WineAddingPageState extends State<WineAddingPage> {
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Auto-close after 30 seconds if no response
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Délai d\'attente dépassé'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ajout à la cave'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<WineLabelBloc>().add(const CancelWineAddingEvent());
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: BlocListener<WineLabelBloc, WineLabelState>(
        listener: (context, state) {
          if (state is WineAddingSuccess) {
            // Refresh cellar to show new wine
            context.read<CellarBloc>().add(const LoadCellarEvent());
            
            // Show success and go back
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is WineLabelError) {
            // Show error and go back
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is WineAddingCancelled) {
            // Go back without message
            Navigator.of(context).pop();
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Paul happy image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/img/Paul_Happy.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Loading text
              const Text(
                'Ajout du vin à votre cave...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'Veuillez patienter',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

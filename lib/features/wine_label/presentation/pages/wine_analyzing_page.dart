import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wine_label_bloc.dart';
import '../bloc/wine_label_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'wine_selection_page.dart';

class WineAnalyzingPage extends StatefulWidget {
  const WineAnalyzingPage({super.key});

  @override
  State<WineAnalyzingPage> createState() => _WineAnalyzingPageState();
}

class _WineAnalyzingPageState extends State<WineAnalyzingPage> {
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgressAnimation();
    
    // Auto-cancel after 45 seconds
    Timer(const Duration(seconds: 45), () {
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

  void _startProgressAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _currentStep < 3) {
        setState(() {
          _currentStep++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analyse en cours'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: BlocListener<WineLabelBloc, WineLabelState>(
        listener: (context, state) {
          if (state is LabelAnalysisSuccess) {
            // Navigate to selection page
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => WineSelectionPage(
                    analysisResult: state.analysisResult,
                    userId: authState.user.id,
                  ),
                ),
              );
            }
          } else if (state is WineLabelError) {
            // Show error and go back
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              SizedBox(height: 32),
              
              // Analyzing text
              Text(
                'Analyse de l\'étiquette...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              
              Text(
                'Paul réfléchit...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              
              // Progress steps
              Column(
                children: [
                  const _ProgressStep(text: '📷 Photo prise', completed: true),
                  if (_currentStep >= 1) const _ProgressStep(text: '⬆️ Upload en cours', completed: true),
                  if (_currentStep >= 2) const _ProgressStep(text: '🤖 Analyse IA', completed: true),
                  if (_currentStep >= 3) const _ProgressStep(text: '🍷 Suggestions', completed: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String text;
  final bool completed;

  const _ProgressStep({
    required this.text,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: completed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: completed ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wine_label_bloc.dart';
import '../bloc/wine_label_event.dart';
import '../bloc/wine_label_state.dart';

class WineAddingPage extends StatefulWidget {
  const WineAddingPage({super.key});

  @override
  State<WineAddingPage> createState() => _WineAddingPageState();
}

class _WineAddingPageState extends State<WineAddingPage> {
  @override
  void initState() {
    super.initState();
    // Auto-close after 30 seconds if no response
    Future.delayed(const Duration(seconds: 30), () {
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading animation
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              SizedBox(height: 32),
              
              // Loading text
              Text(
                'Ajout du vin à votre cave...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              
              Text(
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

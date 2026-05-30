import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../wine_label/presentation/bloc/wine_label_bloc.dart';
import '../../../wine_label/presentation/bloc/wine_label_event.dart';
import '../../../wine_label/presentation/bloc/wine_label_state.dart';
import '../../../wine_label/presentation/pages/wine_analyzing_page.dart';

class ScanBottlePage extends StatelessWidget {
  const ScanBottlePage({super.key});

  Future<void> _takePicture(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null && context.mounted) {
        final bytes = await image.readAsBytes();
        if (!context.mounted) return;
        final authState = context.read<AuthBloc>().state;

        if (authState is AuthAuthenticated) {
          // Trigger upload BEFORE navigation
          context.read<WineLabelBloc>().add(
            UploadLabelPictureEvent(
              userId: authState.user.id,
              fileName: image.name,
              fileBytes: bytes,
            ),
          );

          // Then navigate to analyzing page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const WineAnalyzingPage(),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && context.mounted) {
        final bytes = await image.readAsBytes();
        if (!context.mounted) return;
        final authState = context.read<AuthBloc>().state;

        if (authState is AuthAuthenticated) {
          // Trigger upload BEFORE navigation
          context.read<WineLabelBloc>().add(
            UploadLabelPictureEvent(
              userId: authState.user.id,
              fileName: image.name,
              fileBytes: bytes,
            ),
          );

          // Then navigate to analyzing page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const WineAnalyzingPage(),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Scanner une étiquette'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocListener<WineLabelBloc, WineLabelState>(
        listener: (context, state) {
          if (!context.mounted) return;
          
          if (state is LabelUploadSuccess) {
            // Trigger analysis after successful upload
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated && context.mounted) {
              context.read<WineLabelBloc>().add(
                AnalyzeLabelEvent(state.label.storagePath, authState.user.id),
              );
            }
          } else if (state is WineLabelError) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 60,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Scanner une étiquette de vin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              const Text(
                'Prenez une photo d\'une étiquette de vin pour l\'analyser et obtenir des suggestions de pairings.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Buttons
              Column(
                children: [
                  // Camera button
                  ElevatedButton.icon(
                    onPressed: () => _takePicture(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Prendre une photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Gallery button
                  OutlinedButton.icon(
                    onPressed: () => _pickFromGallery(context),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choisir depuis la galerie'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[700]!),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

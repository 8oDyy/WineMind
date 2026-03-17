import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WinesPage extends StatelessWidget {
  const WinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Vins',
          style: TextStyle(fontSize: 24, color: AppColors.primaryWine),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SettingsPage extends StatelessWidget {
  final UserEntity user;

  const SettingsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryWine,
        elevation: 0,
      ),
      body: _SettingsBody(user: user),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final UserEntity user;

  const _SettingsBody({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      children: [
        _ProfileCard(user: user),
        const SizedBox(height: 32),
        _SectionTitle(title: 'Compte'),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.logout,
          label: 'Se déconnecter',
          iconColor: AppColors.primaryWine,
          onTap: () => _confirmLogout(context),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.delete_forever,
          label: 'Supprimer mon compte',
          iconColor: Colors.red,
          textColor: Colors.red,
          onTap: () => _confirmDelete(context, user.id),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final bloc = context.read<AuthBloc>();
              Navigator.pop(context);
              bloc.add(const LogoutEvent());
            },
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: AppColors.primaryWine),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final bloc = context.read<AuthBloc>();
              Navigator.pop(context);
              bloc.add(DeleteAccountEvent(userId: userId));
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserEntity user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileDetails(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(prenom: user.prenom, nom: user.nom),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.prenom} ${user.nom}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primaryWine,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProfileBottomSheet(user: user),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String prenom;
  final String nom;

  const _Avatar({required this.prenom, required this.nom});

  @override
  Widget build(BuildContext context) {
    final initials =
        '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'
            .toUpperCase();
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primaryWine,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _ProfileBottomSheet extends StatelessWidget {
  final UserEntity user;

  const _ProfileBottomSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _Avatar(prenom: user.prenom, nom: user.nom),
          const SizedBox(height: 16),
          Text(
            '${user.prenom} ${user.nom}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.school_outlined,
            label: 'Niveau',
            value: user.niveau ?? 'Non renseigné',
          ),
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.wine_bar_outlined,
            label: 'Préférence',
            value: user.preference ?? 'Non renseignée',
          ),
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'Objectif',
            value: user.objectif ?? 'Non renseigné',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryWine),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withValues(alpha: 0.5),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary.withValues(alpha: 0.5),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.textColor = AppColors.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textPrimary.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Page d'édition du profil (identité + profil vin).
///
/// Reprend les mêmes options et le même style visuel que l'onboarding
/// (`knowledge_level_page`, `wine_preference_page`, `objective_page`).
/// La préférence est multi-sélection, persistée en une seule chaîne
/// (ex. "Vin Rouge, Vin Blanc") et re-splittée sur ", " à l'affichage.
class EditProfilePage extends StatefulWidget {
  final UserEntity user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // ── Options (identiques à l'onboarding) ──
  static const List<String> _niveaux = ['Débutant', 'Amateur', 'Passionné'];
  static const List<String> _preferences = [
    'Vin Rouge',
    'Vin Rosé',
    'Vin Blanc',
    'Vin Pétillant',
    'Pas de préférence',
  ];
  static const List<String> _objectifs = [
    'Trouver un vin',
    'Découvrir',
    'Apprendre',
    'Gérer ma cave',
  ];

  late final TextEditingController _prenomCtrl;
  late final TextEditingController _nomCtrl;

  String? _niveau;
  String? _objectif;
  final Set<String> _selectedPreferences = {};

  @override
  void initState() {
    super.initState();
    _prenomCtrl = TextEditingController(text: widget.user.prenom);
    _nomCtrl = TextEditingController(text: widget.user.nom);

    // Pré-sélection à partir du profil courant (uniquement si la valeur fait
    // partie des options connues, pour éviter une sélection fantôme).
    final niveau = widget.user.niveau;
    if (niveau != null && _niveaux.contains(niveau)) _niveau = niveau;

    final objectif = widget.user.objectif;
    if (objectif != null && _objectifs.contains(objectif)) {
      _objectif = objectif;
    }

    final pref = widget.user.preference;
    if (pref != null && pref.trim().isNotEmpty) {
      for (final p in pref.split(', ')) {
        final t = p.trim();
        if (_preferences.contains(t)) _selectedPreferences.add(t);
      }
    }
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    super.dispose();
  }

  void _togglePreference(String value) {
    setState(() {
      const noPref = 'Pas de préférence';
      if (value == noPref) {
        _selectedPreferences
          ..clear()
          ..add(noPref);
      } else {
        _selectedPreferences.remove(noPref);
        if (_selectedPreferences.contains(value)) {
          _selectedPreferences.remove(value);
        } else {
          _selectedPreferences.add(value);
        }
      }
    });
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();

    final prenom = _prenomCtrl.text.trim();
    final nom = _nomCtrl.text.trim();
    final preference = _selectedPreferences.join(', ');

    context.read<AuthBloc>().add(UpdateProfileEvent(
          // On envoie toujours l'ensemble des champs : c'est une édition
          // explicite, l'utilisateur décide de l'état final de son profil.
          prenom: prenom.isEmpty ? null : prenom,
          nom: nom.isEmpty ? null : nom,
          niveau: _niveau,
          objectif: _objectif,
          preference: preference.isEmpty ? null : preference,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdateSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(glassSnackBar('Profil mis à jour'));
          Navigator.of(context).pop();
        } else if (state is AuthProfileUpdateFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(glassSnackBar(state.message, isError: true));
        }
      },
      builder: (context, state) {
        final isSaving = state is AuthProfileUpdateInProgress;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: const Text(
              'Modifier le profil',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Identité ──
                        const _SectionLabel('Identité'),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _prenomCtrl,
                          label: 'Prénom',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _nomCtrl,
                          label: 'Nom',
                          icon: Icons.badge_outlined,
                        ),

                        const SizedBox(height: 28),

                        // ── Niveau (choix unique) ──
                        const _SectionLabel('Niveau de connaissance'),
                        const SizedBox(height: 12),
                        ..._niveaux.map((n) => _SingleChoiceTile(
                              label: n,
                              icon: _niveauIcon(n),
                              selected: _niveau == n,
                              onTap: () => setState(() => _niveau = n),
                            )),

                        const SizedBox(height: 28),

                        // ── Préférences (multi) ──
                        const _SectionLabel('Préférences de vin'),
                        const SizedBox(height: 12),
                        ..._preferences.map((p) => _MultiChoiceTile(
                              label: p,
                              icon: _preferenceIcon(p),
                              selected: _selectedPreferences.contains(p),
                              onTap: () => _togglePreference(p),
                            )),

                        const SizedBox(height: 28),

                        // ── Objectif (choix unique) ──
                        const _SectionLabel("Objectif d'utilisation"),
                        const SizedBox(height: 12),
                        ..._objectifs.map((o) => _SingleChoiceTile(
                              label: o,
                              icon: _objectifIcon(o),
                              selected: _objectif == o,
                              onTap: () => setState(() => _objectif = o),
                            )),
                      ],
                    ),
                  ),
                ),

                // ── Bouton Enregistrer ──
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryWine,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primaryWine.withValues(alpha: 0.5),
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Enregistrer',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Icônes alignées sur l'onboarding ──
  IconData _niveauIcon(String n) {
    switch (n) {
      case 'Débutant':
        return Icons.wine_bar_outlined;
      case 'Amateur':
        return Icons.local_bar_outlined;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  IconData _preferenceIcon(String p) {
    switch (p) {
      case 'Vin Rouge':
        return Icons.wine_bar;
      case 'Vin Rosé':
        return Icons.local_bar;
      case 'Vin Blanc':
        return Icons.emoji_food_beverage;
      case 'Vin Pétillant':
        return Icons.bubble_chart_outlined;
      default:
        return Icons.block_outlined;
    }
  }

  IconData _objectifIcon(String o) {
    switch (o) {
      case 'Trouver un vin':
        return Icons.search;
      case 'Découvrir':
        return Icons.explore_outlined;
      case 'Apprendre':
        return Icons.menu_book_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 1,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryWine),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryWine, width: 1.5),
        ),
      ),
    );
  }
}

/// Tuile à choix unique (radio), style onboarding.
class _SingleChoiceTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SingleChoiceTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFDF2F3) : Colors.white,
            border: Border.all(
              color: selected ? AppColors.primaryWine : Colors.grey[300]!,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.primaryWine : Colors.grey[400],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: selected ? AppColors.primaryWine : Colors.black87,
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primaryWine : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryWine,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tuile à choix multiple (checkbox ronde), style onboarding.
class _MultiChoiceTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MultiChoiceTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFDF2F3) : Colors.white,
            border: Border.all(
              color: selected ? AppColors.primaryWine : Colors.grey[300]!,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.primaryWine : Colors.grey[400],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: selected ? AppColors.primaryWine : Colors.black87,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primaryWine : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.primaryWine : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wine_label_bloc.dart';
import '../bloc/wine_label_event.dart';
import '../bloc/wine_label_state.dart';
import '../../domain/entities/wine_analysis_result.dart';
import '../widgets/wine_proposal_card.dart';
import 'wine_adding_page.dart';

class WineSelectionPage extends StatefulWidget {
  final WineAnalysisResult analysisResult;
  final String userId;

  const WineSelectionPage({
    super.key,
    required this.analysisResult,
    required this.userId,
  });

  @override
  State<WineSelectionPage> createState() => _WineSelectionPageState();
}

class _WineSelectionPageState extends State<WineSelectionPage> {
  String? selectedWineId;
  bool isExistingWine = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner le vin'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
          children: [
            // Header with Paul surprised
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/img/paulSurprised.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🍷 Analyse terminée !',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choisissez le vin à ajouter à votre cave :',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Wine proposals
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Existing wine proposal (uniquement si le catalogue a une correspondance)
                    if (widget.analysisResult.existingProposal != null) ...[
                      WineProposalCard(
                        title: 'Option 1 - Vin existant',
                        proposal: widget.analysisResult.existingProposal!,
                        isSelected: selectedWineId ==
                                widget.analysisResult.existingProposal!.id &&
                            isExistingWine,
                        onTap: () {
                          final existingId =
                              widget.analysisResult.existingProposal!.id;
                          if (existingId != null) {
                            setState(() {
                              selectedWineId = existingId;
                              isExistingWine = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // New wine proposal
                    WineProposalCard(
                      title: 'Option 2 - Nouveau vin',
                      proposal: widget.analysisResult.newProposal,
                      isSelected: selectedWineId == widget.analysisResult.newProposal.name && !isExistingWine,
                      onTap: () {
                        setState(() {
                          selectedWineId = widget.analysisResult.newProposal.name;
                          isExistingWine = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Add button
            Container(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<WineLabelBloc, WineLabelState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: selectedWineId != null && state is! WineAddingLoading
                        ? () {
                            // Trigger addition immediately, then navigate
                            if (isExistingWine) {
                              context.read<WineLabelBloc>().add(
                                AddWineToCellarEvent(
                                  userId: widget.userId,
                                  wineId: selectedWineId!,
                                  isExistingWine: true,
                                  stock: 1,
                                ),
                              );
                            } else {
                              context.read<WineLabelBloc>().add(
                                AddWineToCellarEvent(
                                  userId: widget.userId,
                                  wineId: selectedWineId!,
                                  isExistingWine: false,
                                  wineData: widget.analysisResult.newProposal,
                                  stock: 1,
                                ),
                              );
                            }
                            
                            // Navigate to loading page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WineAddingPage(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is WineAddingLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Ajouter à ma cave'),
                  );
                },
              ),
            ),
          ],
      ),
    );
  }
}

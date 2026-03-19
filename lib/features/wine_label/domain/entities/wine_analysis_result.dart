import 'package:equatable/equatable.dart';
import 'wine_proposal.dart';

class WineAnalysisResult extends Equatable {
  final String chatResponse;
  final WineProposal existingProposal;
  final WineProposal newProposal;
  final WineProposal wineAnalysis;

  const WineAnalysisResult({
    required this.chatResponse,
    required this.existingProposal,
    required this.newProposal,
    required this.wineAnalysis,
  });

  @override
  List<Object?> get props => [chatResponse, existingProposal, newProposal, wineAnalysis];
}

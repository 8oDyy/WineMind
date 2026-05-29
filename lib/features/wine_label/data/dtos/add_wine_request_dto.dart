import '../../domain/entities/wine_proposal.dart';

class AddWineRequestDto {
  final String userId;
  final String? wineId;
  final Map<String, dynamic>? wineData;
  final int stock;
  final String? notes;
  final String? location;

  const AddWineRequestDto({
    required this.userId,
    this.wineId,
    this.wineData,
    required this.stock,
    this.notes,
    this.location,
  });

  factory AddWineRequestDto.forExistingWine({
    required String userId,
    required String wineId,
    required int stock,
    String? notes,
    String? location,
  }) {
    return AddWineRequestDto(
      userId: userId,
      wineId: wineId,
      stock: stock,
      notes: notes,
      location: location,
    );
  }

  factory AddWineRequestDto.forNewWine({
    required String userId,
    required WineProposal wineData,
    required int stock,
    String? notes,
    String? location,
  }) {
    return AddWineRequestDto(
      userId: userId,
      wineData: _convertWineProposalToMap(wineData),
      stock: stock,
      notes: notes,
      location: location,
    );
  }

  Map<String, dynamic> toJson() {
    if (wineId != null) {
      // Existing wine
      return {
        'user_id': userId,
        'wine_id': wineId,
        'stock': stock,
        'custom_notes': notes,
        'location': location,
      };
    } else {
      // New wine
      return {
        'user_id': userId,
        'wine_data': wineData,
        'stock': stock,
        'custom_notes': notes,
        'location': location,
      };
    }
  }

  static Map<String, dynamic> _convertWineProposalToMap(WineProposal proposal) {
    return {
      'name': proposal.name,
      'winery': proposal.winery,
      'year': proposal.year,
      'region': proposal.region,
      'country': proposal.country,
      if (proposal.variety != null) 'variety': proposal.variety,
      if (proposal.type != null) 'type': proposal.type,
      if (proposal.alcoholPercentage != null) 'alcohol_percentage': proposal.alcoholPercentage,
      if (proposal.description != null) 'description': proposal.description,
      if (proposal.designation != null) 'designation': proposal.designation,
      if (proposal.province != null) 'province': proposal.province,
      if (proposal.price != null) 'price': proposal.price,
      if (proposal.points != null) 'points': proposal.points,
      if (proposal.bodyLevel != null) 'body_level': proposal.bodyLevel,
      if (proposal.tanninLevel != null) 'tannin_level': proposal.tanninLevel,
      if (proposal.fruitLevel != null) 'fruit_level': proposal.fruitLevel,
      if (proposal.foodPairings != null) 'food_pairings': proposal.foodPairings,
      'confidence': proposal.confidence,
    };
  }

  bool get isValid {
    if (userId.isEmpty) return false;
    if (wineId == null && wineData == null) return false;
    if (wineId != null && wineData != null) return false; // Can't have both
    if (stock <= 0) return false;
    return true;
  }
}

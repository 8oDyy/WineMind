import '../../domain/entities/wine_proposal.dart';

class WineProposalMapper {
  static WineProposal fromJson(Map<String, dynamic> json) {
    return WineProposal(
      id: json['id'] as String?,
      name: json['name'] as String,
      winery: json['winery'] as String,
      year: json['year'] as int,
      region: json['region'] as String,
      country: json['country'] as String,
      variety: json['variety'] as String?,
      type: json['type'] as String?,
      alcoholPercentage: (json['alcohol_percentage'] as num?)?.toDouble(),
      description: json['description'] as String?,
      designation: json['designation'] as String?,
      province: json['province'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      points: json['points'] as int?,
      bodyLevel: (json['body_level'] as num?)?.toDouble(),
      tanninLevel: (json['tannin_level'] as num?)?.toDouble(),
      fruitLevel: (json['fruit_level'] as num?)?.toDouble(),
      foodPairings: (json['food_pairings'] as List<dynamic>?)?.cast<String>(),
      confidence: (json['confidence'] as num).toDouble(),
      matchType: json['match_type'] as String? ?? 'unknown',
      matchConfidence: (json['match_confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static Map<String, dynamic> toJson(WineProposal proposal) {
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
}

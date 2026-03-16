import 'package:flutter/material.dart';

class WineCard extends StatelessWidget {
  final String name;
  final String year;
  final String type;
  final String region;
  final double rating;
  final int points;
  final String apogee;
  final int stock;

  const WineCard({
    super.key,
    required this.name,
    required this.year,
    required this.type,
    required this.region,
    required this.rating,
    required this.points,
    required this.apogee,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre section
          const Text(
            'Dernier vin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7B1A2E),
            ),
          ),
          const SizedBox(height: 12),

          // Image bouteille
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFFF5E6C8),
              child: const Icon(
                Icons.wine_bar,
                size: 100,
                color: Color(0xFF7B1A2E),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nom et année
          Text(
            '$name $year',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 6),

          // Type et région
          Row(
            children: [
              const CircleAvatar(
                radius: 5,
                backgroundColor: Color(0xFF7B1A2E),
              ),
              const SizedBox(width: 6),
              Text(
                '$type • $region',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Note + stock
          Row(
            children: [
              // Étoiles
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating.floor() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '($points pts)',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),

              // Stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'STOCK',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF7B1A2E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF7B1A2E),
                    child: Text(
                      '$stock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Apogée
          Text(
            'APOGÉE : $apogee',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
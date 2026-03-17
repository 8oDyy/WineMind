import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winemind/core/error/failures.dart';
import 'package:winemind/features/wine/domain/entities/wine.dart';
import 'package:winemind/features/wine/domain/repositories/wine_repository.dart';
import 'package:winemind/features/wine/domain/usecases/update_wine_stock.dart';
import 'package:winemind/features/wine/presentation/bloc/wine_detail_bloc.dart';
import 'package:winemind/features/wine/presentation/pages/wine_detail_page.dart';

const tWine = Wine(
  name: 'Château Margaux',
  year: '2015',
  type: 'Rouge',
  region: 'Bordeaux, France',
  subRegion: 'Margaux, Bordeaux',
  rating: 3.5,
  points: 95,
  apogee: '2025 - 2045',
  stock: 3,
  classification: 'PREMIER GRAND CRU CLASSÉ',
  alcohol: 13.5,
  grapes: ['Cab. Sauv', 'Merlot', 'Petit Verdot'],
  location: 'Casier A-12',
  foodPairings: ['Viandes', 'Gibier', 'Fromage'],
  bodyLevel: 0.85,
  tanninLevel: 0.80,
  fruitLevel: 0.70,
);

const tWineMinimal = Wine(
  name: 'Domaine Ott',
  year: '2021',
  type: 'Rosé',
  region: 'Provence, France',
  rating: 4.0,
  points: 89,
  apogee: 'À boire maintenant',
  stock: 5,
);

class FakeWineRepository implements WineRepository {
  final Map<String, int> _stocks = {};

  @override
  Future<Either<Failure, Wine>> getLastWine() async => const Right(tWine);

  @override
  Future<Either<Failure, List<Wine>>> getAllWines() async => const Right([tWine]);

  @override
  Future<Either<Failure, Wine>> updateWineStock(String wineName, int newStock) async {
    _stocks[wineName] = newStock;
    if (wineName == tWine.name) {
      return Right(Wine(
        name: tWine.name,
        year: tWine.year,
        type: tWine.type,
        region: tWine.region,
        subRegion: tWine.subRegion,
        rating: tWine.rating,
        points: tWine.points,
        apogee: tWine.apogee,
        stock: newStock,
        classification: tWine.classification,
        alcohol: tWine.alcohol,
        grapes: tWine.grapes,
        location: tWine.location,
        foodPairings: tWine.foodPairings,
        bodyLevel: tWine.bodyLevel,
        tanninLevel: tWine.tanninLevel,
        fruitLevel: tWine.fruitLevel,
      ));
    }
    return Left(CacheFailure());
  }
}

Widget _buildSubject(Wine wine) {
  final repo = FakeWineRepository();
  final useCase = UpdateWineStock(repo);
  return MaterialApp(
    home: BlocProvider(
      create: (_) => WineDetailBloc(wine: wine, updateWineStock: useCase),
      child: const WineDetailPage(),
    ),
  );
}

void main() {
  group('WineDetailPage', () {
    group('Header', () {
      testWidgets('affiche le nom et l\'année du vin', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.textContaining('Château Margaux'), findsWidgets);
        expect(find.textContaining('2015'), findsWidgets);
      });

      testWidgets('affiche la classification quand présente', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('PREMIER GRAND CRU CLASSÉ'), findsOneWidget);
      });

      testWidgets('n\'affiche pas la classification quand absente',
          (tester) async {
        await tester.pumpWidget(_buildSubject(tWineMinimal));

        expect(find.text('PREMIER GRAND CRU CLASSÉ'), findsNothing);
      });

      testWidgets('affiche la sous-région quand présente', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('Margaux, Bordeaux'), findsOneWidget);
      });
    });

    group('Tags', () {
      testWidgets('affiche le tag région', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('Bordeaux, France'), findsOneWidget);
      });

      testWidgets('affiche le tag type de vin', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('Rouge'), findsOneWidget);
      });
    });

    group('Carte technique', () {
      testWidgets('affiche le taux d\'alcool', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('13.5% vol.'), findsOneWidget);
      });

      testWidgets('affiche les cépages', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('Cab. Sauv, Merlot, Petit Verdot'), findsOneWidget);
      });

      testWidgets('affiche "-" quand pas d\'alcool', (tester) async {
        await tester.pumpWidget(_buildSubject(tWineMinimal));

        expect(find.text('-'), findsWidgets);
      });
    });

    group('Profil gustatif', () {
      testWidgets('affiche les labels Corps, Tanins, Fruit', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('Corps'), findsOneWidget);
        expect(find.text('Tanins'), findsOneWidget);
        expect(find.text('Fruit'), findsOneWidget);
      });

      testWidgets('affiche les barres de progression', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
      });
    });

    group('Accords mets', () {
      testWidgets('affiche les labels des accords mets', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('VIANDES'), findsOneWidget);
        expect(find.text('GIBIER'), findsOneWidget);
        expect(find.text('FROMAGE'), findsOneWidget);
      });

      testWidgets('n\'affiche pas la section si aucun accord', (tester) async {
        await tester.pumpWidget(_buildSubject(tWineMinimal));

        expect(find.text('VIANDES'), findsNothing);
        expect(find.text('ACCORDS METS'), findsNothing);
      });
    });

    group('Gestion du stock', () {
      testWidgets('affiche le stock initial', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('affiche l\'emplacement', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('Emplacement: Casier A-12'), findsOneWidget);
      });

      testWidgets('le bouton + incrémente le stock', (tester) async {
        tester.view.physicalSize = const Size(400, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildSubject(tWine));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.text('4'), findsOneWidget);
      });

      testWidgets('le bouton - décrémente le stock', (tester) async {
        tester.view.physicalSize = const Size(400, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildSubject(tWine));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('le stock ne descend pas en dessous de 0', (tester) async {
        tester.view.physicalSize = const Size(400, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const wineNoStock = Wine(
          name: 'Test',
          year: '2020',
          type: 'Rouge',
          region: 'Bordeaux',
          rating: 4.0,
          points: 90,
          apogee: '2025',
          stock: 0,
        );
        await tester.pumpWidget(_buildSubject(wineNoStock));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(find.text('0'), findsOneWidget);
      });
    });

    group('Boutons d\'action', () {
      testWidgets('affiche le bouton "Ouvrir une bouteille"', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('Ouvrir une bouteille'), findsOneWidget);
      });

      testWidgets('affiche le bouton "Ajouter une note personnelle"',
          (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('Ajouter une note personnelle'), findsOneWidget);
      });

      testWidgets('"Ouvrir une bouteille" décrémente le stock', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        await tester.tap(find.text('Ouvrir une bouteille'));
        await tester.pumpAndSettle();

        expect(find.text('2'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('le bouton retour pop la page', (tester) async {
        final repo = FakeWineRepository();
        final useCase = UpdateWineStock(repo);
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => WineDetailBloc(
                        wine: tWine,
                        updateWineStock: useCase,
                      ),
                      child: const WineDetailPage(),
                    ),
                  ),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.byType(WineDetailPage), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.byType(WineDetailPage), findsNothing);
      });
    });
  });
}

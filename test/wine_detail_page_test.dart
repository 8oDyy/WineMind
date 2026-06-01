import 'package:dartz/dartz.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winemind/features/wine/presentation/widgets/aging_window_chart.dart';
import 'package:winemind/features/wine/presentation/widgets/taste_profile_radar.dart';
import 'package:winemind/core/error/failures.dart';
import 'package:winemind/features/wine/domain/entities/wine.dart';
import 'package:winemind/features/wine/domain/repositories/wine_repository.dart';
import 'package:winemind/features/wine/domain/usecases/enrich_wine.dart';
import 'package:winemind/features/wine/domain/usecases/update_wine_stock.dart';
import 'package:winemind/features/wine/presentation/bloc/wine_detail_bloc.dart';
import 'package:winemind/features/wine/presentation/bloc/wine_detail_event.dart';
import 'package:winemind/features/wine/presentation/bloc/wine_detail_state.dart';
import 'package:winemind/features/wine/presentation/pages/wine_detail_page.dart';

// tWine uses only real Wine fields.
// - cellarId is required for stock +/- (the page guards on cellarId != null).
// - designation replaces old 'classification' (shown as green badge in header).
// - variety replaces old 'grapes' (shown in CÉPAGE technical card cell).
// - winery is shown as a subtitle in the header and in the DOMAINE technical cell.
// - subRegion, classification, alcohol, grapes no longer exist in Wine.
const tWine = Wine(
  id: 'wine-1',
  cellarId: 'cellar-1',
  name: 'Château Margaux',
  year: '2015',
  type: 'Rouge',
  region: 'Bordeaux, France',
  rating: 3.5,
  points: 95,
  apogee: '2025 - 2045',
  stock: 3,
  designation: 'PREMIER GRAND CRU CLASSÉ',
  variety: 'Cab. Sauv, Merlot, Petit Verdot',
  winery: 'Château Margaux',
  location: 'Casier A-12',
  foodPairings: ['Viandes', 'Gibier', 'Fromage'],
  bodyLevel: 0.85,
  tanninLevel: 0.80,
  fruitLevel: 0.70,
  drinkFrom: 2020,
  peakYear: 2030,
  drinkTo: 2045,
);

// Minimal wine: no optional fields, no cellarId (stock buttons do nothing).
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

// FakeWineRepository implements the CURRENT WineRepository interface:
//   getLastWine, getAllWines, addToCellar, removeFromCellar, updateCellarStock.
//
// UpdateWineStock usecase calls repository.updateCellarStock(cellarId, newStock).
// We return Right(null) for valid cellarIds so the bloc emits WineDetailLoaded
// with the updated stock.
class FakeWineRepository implements WineRepository {
  final Map<String, int> _stocks = {};

  @override
  Future<Either<Failure, Wine>> getLastWine() async => const Right(tWine);

  @override
  Future<Either<Failure, List<Wine>>> getAllWines() async =>
      const Right([tWine]);

  @override
  Future<Either<Failure, void>> addToCellar(Wine wine) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> removeFromCellar(String cellarId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateCellarStock(
      String cellarId, int stock) async {
    _stocks[cellarId] = stock;
    return const Right(null);
  }

  @override
  Future<Either<Failure, Wine>> enrichWine(String wineId) async =>
      const Right(tWine);
}

Widget _buildSubject(Wine wine) {
  final repo = FakeWineRepository();
  return MaterialApp(
    home: BlocProvider(
      create: (_) => WineDetailBloc(
        wine: wine,
        updateWineStock: UpdateWineStock(repo),
        enrichWine: EnrichWine(repo),
      ),
      child: const WineDetailPage(),
    ),
  );
}

void main() {
  group('WineDetailPage', () {
    // ─────────────────────────────────────────────
    // HEADER
    // ─────────────────────────────────────────────
    group('Header', () {
      testWidgets('affiche le nom et l\'année du vin', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.textContaining('Château Margaux'), findsWidgets);
        expect(find.textContaining('2015'), findsWidgets);
      });

      // designation replaces old 'classification': shown as a green badge in
      // the FlexibleSpaceBar area when non-null.
      testWidgets('affiche la désignation (badge) quand présente',
          (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('PREMIER GRAND CRU CLASSÉ'), findsOneWidget);
      });

      testWidgets('n\'affiche pas la désignation quand absente', (tester) async {
        await tester.pumpWidget(_buildSubject(tWineMinimal));

        expect(find.text('PREMIER GRAND CRU CLASSÉ'), findsNothing);
      });

      // winery is displayed as a subtitle line below the name/year.
      testWidgets('affiche le domaine (winery) quand présent', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        // winery appears at least once (header subtitle + DOMAINE cell)
        expect(find.textContaining('Château Margaux'), findsWidgets);
      });
    });

    // ─────────────────────────────────────────────
    // TAGS
    // ─────────────────────────────────────────────
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

    // ─────────────────────────────────────────────
    // CARTE TECHNIQUE
    // The technical card now shows: CÉPAGE (variety), DOMAINE (winery),
    // PAYS (country), PRIX (price).
    // Old fields 'alcohol' and 'grapes' no longer exist.
    // ─────────────────────────────────────────────
    group('Carte technique', () {
      testWidgets('affiche le cépage (variety)', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('Cab. Sauv, Merlot, Petit Verdot'), findsOneWidget);
      });

      testWidgets('affiche "-" pour les champs absents (minimal wine)',
          (tester) async {
        await tester.pumpWidget(_buildSubject(tWineMinimal));

        // variety, winery, country, price are all null → each cell shows '-'
        expect(find.text('-'), findsWidgets);
      });
    });

    // ─────────────────────────────────────────────
    // PROFIL GUSTATIF
    // ─────────────────────────────────────────────
    group('Profil gustatif', () {
      testWidgets('affiche le titre de la section', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('PROFIL GUSTATIF'), findsOneWidget);
      });

      testWidgets('affiche le radar quand les 3 niveaux sont présents',
          (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.byType(TasteProfileRadar), findsOneWidget);
        expect(find.byType(RadarChart), findsOneWidget);
      });

      testWidgets('affiche un message quand le profil est absent',
          (tester) async {
        await tester.pumpWidget(_buildSubject(tWineMinimal));

        expect(find.byType(TasteProfileRadar), findsNothing);
        expect(
          find.text('Profil gustatif non disponible pour ce vin.'),
          findsOneWidget,
        );
      });
    });

    // ─────────────────────────────────────────────
    // FENÊTRE DE GARDE (apogée)
    // ─────────────────────────────────────────────
    group('Fenêtre de garde', () {
      testWidgets('affiche le graphique quand les bornes sont présentes',
          (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('FENÊTRE DE GARDE'), findsOneWidget);
        expect(find.byType(AgingWindowChart), findsOneWidget);
      });

      testWidgets(
          'sans bornes numériques mais avec apogée texte : carte + note, pas de graphe',
          (tester) async {
        // tWineMinimal a apogee = 'À boire maintenant' (texte libre user)
        // mais pas de drink_from/peak_year/drink_to.
        await tester.pumpWidget(_buildSubject(tWineMinimal));

        expect(find.text('FENÊTRE DE GARDE'), findsOneWidget);
        expect(find.byType(AgingWindowChart), findsNothing); // pas de graphe
        expect(find.text('À boire maintenant'), findsOneWidget); // note user
      });

      testWidgets('aucune donnée d\'apogée : section masquée', (tester) async {
        const wineNoAging = Wine(
          name: 'Sans apogée',
          year: '2021',
          type: 'Blanc',
          region: 'Loire',
          rating: 3.0,
          points: 85,
          apogee: '',
          stock: 1,
        );
        await tester.pumpWidget(_buildSubject(wineNoAging));

        expect(find.text('FENÊTRE DE GARDE'), findsNothing);
        expect(find.byType(AgingWindowChart), findsNothing);
      });

      testWidgets('affiche la phase selon l\'année injectée (apogée)',
          (tester) async {
        // tWine : drinkFrom 2020 / peakYear 2030 / drinkTo 2045.
        final repo = FakeWineRepository();
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (_) => WineDetailBloc(
                wine: tWine,
                updateWineStock: UpdateWineStock(repo),
                enrichWine: EnrichWine(repo),
              ),
              child: const WineDetailPage(currentYear: 2030),
            ),
          ),
        );

        expect(find.textContaining('À son apogée'), findsOneWidget);
      });

      test('isValid rejette les bornes nulles ou désordonnées', () {
        expect(AgingWindowChart.isValid(null, 2030, 2045), isFalse);
        expect(AgingWindowChart.isValid(2040, 2030, 2045), isFalse);
        expect(AgingWindowChart.isValid(2020, 2030, 2045), isTrue);
      });

      test('phaseFor classe correctement selon l\'année', () {
        expect(AgingWindowChart.phaseFor(2018, 2020, 2030, 2045),
            AgingPhase.young);
        expect(AgingWindowChart.phaseFor(2030, 2020, 2030, 2045),
            AgingPhase.peak);
        expect(AgingWindowChart.phaseFor(2035, 2020, 2030, 2045),
            AgingPhase.decline);
        expect(AgingWindowChart.phaseFor(2050, 2020, 2030, 2045),
            AgingPhase.past);
      });
    });

    // ─────────────────────────────────────────────
    // ACCORDS METS
    // ─────────────────────────────────────────────
    group('Accords mets', () {
      testWidgets('affiche les labels des accords mets', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        expect(find.text('VIANDES'), findsOneWidget);
        expect(find.text('GIBIER'), findsOneWidget);
        expect(find.text('FROMAGE'), findsOneWidget);
      });

      testWidgets('affiche une annotation lisible des accords', (tester) async {
        await tester.pumpWidget(_buildSubject(tWine));

        // L'énumération FR apparaît dans le RichText d'annotation.
        expect(
          find.textContaining('Viandes, Gibier et Fromage', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.textContaining('Ce vin se marie bien avec', findRichText: true),
          findsOneWidget,
        );
      });

      testWidgets('n\'affiche pas la section si aucun accord', (tester) async {
        await tester.pumpWidget(_buildSubject(tWineMinimal));

        expect(find.text('VIANDES'), findsNothing);
        expect(find.text('ACCORDS METS'), findsNothing);
      });
    });

    // ─────────────────────────────────────────────
    // GESTION DU STOCK
    // Stock +/- works only when wine.cellarId != null (page guard).
    // tWine has cellarId = 'cellar-1'; tWineMinimal has none.
    // ─────────────────────────────────────────────
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
        tester.view.physicalSize = const Size(400, 2600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildSubject(tWine));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byIcon(Icons.add));
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.text('4'), findsOneWidget);
      });

      testWidgets('le bouton - décrémente le stock', (tester) async {
        tester.view.physicalSize = const Size(400, 2600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildSubject(tWine));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byIcon(Icons.remove));
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('le stock ne descend pas en dessous de 0', (tester) async {
        tester.view.physicalSize = const Size(400, 2600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // cellarId set so the guard passes; stock starts at 0.
        const wineNoStock = Wine(
          cellarId: 'cellar-zero',
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
        await tester.ensureVisible(find.byIcon(Icons.remove));
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(find.text('0'), findsOneWidget);
      });
    });

    // ─────────────────────────────────────────────
    // BOUTONS D'ACTION
    // ─────────────────────────────────────────────
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

    // ─────────────────────────────────────────────
    // NAVIGATION
    // ─────────────────────────────────────────────
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
                        enrichWine: EnrichWine(repo),
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

    // ─────────────────────────────────────────────
    // ENRICHISSEMENT (#13)
    // ─────────────────────────────────────────────
    group('Enrichissement', () {
      // Vin catalogue « pauvre » : id présent, mais profil/accords/apogée
      // absents et enrichedAt null → éligible à l'enrichissement.
      const poorCatalogWine = Wine(
        id: 'wine-poor',
        cellarId: 'cellar-poor',
        name: 'Vin à enrichir',
        year: '2018',
        type: 'Rouge',
        region: 'Rhône',
        rating: 0,
        points: 0,
        apogee: '',
        stock: 2,
      );

      // Vin enrichi renvoyé par l'endpoint (forme catalogue).
      const enrichedWine = Wine(
        id: 'wine-poor',
        name: 'Vin à enrichir',
        year: '2018',
        type: 'Rouge',
        region: 'Rhône',
        rating: 0,
        points: 0,
        apogee: '',
        stock: 0,
        bodyLevel: 0.7,
        tanninLevel: 0.6,
        fruitLevel: 0.8,
        foodPairings: ['Viandes'],
        drinkFrom: 2022,
        peakYear: 2028,
        drinkTo: 2035,
        enrichedAt: '2026-06-01T00:00:00Z',
      );

      test('vin pauvre catalogue : enrichWine appelé, état mis à jour',
          () async {
        var called = 0;
        final bloc = WineDetailBloc(
          wine: poorCatalogWine,
          updateWineStock: UpdateWineStock(FakeWineRepository()),
          enrichWine: EnrichWine(_StubEnrichRepo(() {
            called++;
            return const Right(enrichedWine);
          })),
        );

        bloc.add(const EnrichWineEvent());
        // loading puis vin enrichi
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<WineDetailLoaded>()
                .having((s) => s.isEnriching, 'isEnriching', true),
            isA<WineDetailLoaded>()
                .having((s) => s.isEnriching, 'isEnriching', false)
                .having((s) => s.wine.bodyLevel, 'bodyLevel', 0.7)
                .having((s) => s.wine.stock, 'stock préservé', 2),
          ]),
        );
        expect(called, 1);
        await bloc.close();
      });

      test('vin custom (id null) : pas d\'enrichissement', () async {
        var called = 0;
        final bloc = WineDetailBloc(
          wine: tWineMinimal, // pas d'id
          updateWineStock: UpdateWineStock(FakeWineRepository()),
          enrichWine: EnrichWine(_StubEnrichRepo(() {
            called++;
            return const Right(enrichedWine);
          })),
        );

        bloc.add(const EnrichWineEvent());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(called, 0);
        await bloc.close();
      });

      test('vin déjà enrichi : pas d\'enrichissement', () async {
        var called = 0;
        final bloc = WineDetailBloc(
          wine: enrichedWine.copyWith(cellarId: 'c1'),
          updateWineStock: UpdateWineStock(FakeWineRepository()),
          enrichWine: EnrichWine(_StubEnrichRepo(() {
            called++;
            return const Right(enrichedWine);
          })),
        );

        bloc.add(const EnrichWineEvent());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(called, 0);
        await bloc.close();
      });

      test('échec d\'enrichissement : enrichmentFailed = true', () async {
        final bloc = WineDetailBloc(
          wine: poorCatalogWine,
          updateWineStock: UpdateWineStock(FakeWineRepository()),
          enrichWine: EnrichWine(
            _StubEnrichRepo(() => Left(ServerFailure('boom'))),
          ),
        );

        bloc.add(const EnrichWineEvent());
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<WineDetailLoaded>()
                .having((s) => s.isEnriching, 'isEnriching', true),
            isA<WineDetailLoaded>()
                .having((s) => s.isEnriching, 'isEnriching', false)
                .having((s) => s.enrichmentFailed, 'enrichmentFailed', true),
          ]),
        );
        await bloc.close();
      });
    });
  });
}

/// Repo de test minimal pour l'enrichissement : délègue `enrichWine` à un
/// callback configurable, le reste lève (non utilisé dans ces tests).
class _StubEnrichRepo implements WineRepository {
  final Either<Failure, Wine> Function() onEnrich;
  _StubEnrichRepo(this.onEnrich);

  @override
  Future<Either<Failure, Wine>> enrichWine(String wineId) async => onEnrich();

  @override
  Future<Either<Failure, void>> addToCellar(Wine wine) async =>
      const Right(null);
  @override
  Future<Either<Failure, List<Wine>>> getAllWines() async => const Right([]);
  @override
  Future<Either<Failure, Wine>> getLastWine() async => const Right(tWine);
  @override
  Future<Either<Failure, void>> removeFromCellar(String cellarId) async =>
      const Right(null);
  @override
  Future<Either<Failure, void>> updateCellarStock(
          String cellarId, int stock) async =>
      const Right(null);
}

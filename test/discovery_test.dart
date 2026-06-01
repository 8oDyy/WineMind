import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winemind/core/error/failures.dart';
import 'package:winemind/features/wine/data/models/wine_category_model.dart';
import 'package:winemind/features/wine/domain/entities/wine_category.dart';
import 'package:winemind/features/wine/domain/usecases/add_wine_to_cellar.dart';
import 'package:winemind/features/wine/domain/usecases/enrich_wine.dart';
import 'package:winemind/features/wine/domain/usecases/get_discovery.dart';
import 'package:winemind/features/wine/domain/usecases/update_wine_stock.dart';
import 'package:winemind/features/wine/domain/entities/wine.dart';
import 'package:winemind/features/wine/domain/repositories/wine_repository.dart';
import 'package:winemind/features/wine/presentation/bloc/discovery_bloc.dart';
import 'package:winemind/features/wine/presentation/bloc/discovery_event.dart';
import 'package:winemind/features/wine/presentation/bloc/discovery_state.dart';
import 'package:winemind/features/wine/presentation/bloc/wine_detail_bloc.dart';
import 'package:winemind/features/wine/presentation/bloc/wine_detail_event.dart';
import 'package:winemind/features/wine/presentation/bloc/wine_detail_state.dart';

/// Repo de test paramétrable : chaque méthode délègue à un champ optionnel,
/// avec un défaut neutre. Couvre le contrat WineRepository complet.
class _FakeRepo implements WineRepository {
  Either<Failure, List<WineCategory>> Function()? onDiscovery;
  Either<Failure, void> Function(Wine)? onAddToCellar;
  int addCalls = 0;

  @override
  Future<Either<Failure, List<WineCategory>>> getDiscovery({
    int limitPerCategory = 12,
  }) async =>
      onDiscovery?.call() ?? const Right([]);

  @override
  Future<Either<Failure, void>> addToCellar(Wine wine) async {
    addCalls++;
    return onAddToCellar?.call(wine) ?? const Right(null);
  }

  @override
  Future<Either<Failure, Wine>> enrichWine(String wineId) async =>
      Left(ServerFailure('unused'));
  @override
  Future<Either<Failure, List<Wine>>> getAllWines() async => const Right([]);
  @override
  Future<Either<Failure, Wine>> getLastWine() async =>
      Left(ServerFailure('unused'));
  @override
  Future<Either<Failure, void>> removeFromCellar(String cellarId) async =>
      const Right(null);
  @override
  Future<Either<Failure, void>> updateCellarStock(
          String cellarId, int stock) async =>
      const Right(null);
}

void main() {
  group('WineCategoryModel.fromJson', () {
    test('parse une catégorie avec des rows wines brutes (fromCatalogJson)', () {
      final json = {
        'key': 'for_you',
        'title': 'Pour vous',
        'subtitle': "D'après vos goûts",
        'wines': [
          {
            'id': 'w1',
            'name': 'Château Test',
            'year': 2018,
            'type': 'Rouge',
            'region': 'Bordeaux',
            'price': 25,
            'food_pairings': ['Viandes'],
            'body_level': 0.8,
          },
        ],
      };

      final model = WineCategoryModel.fromJson(json);

      expect(model.key, 'for_you');
      expect(model.title, 'Pour vous');
      expect(model.subtitle, "D'après vos goûts");
      expect(model.wines, hasLength(1));
      final wine = model.wines.first;
      expect(wine.id, 'w1');
      expect(wine.name, 'Château Test');
      expect(wine.year, '2018'); // year normalisé en String
      expect(wine.cellarId, isNull); // row catalogue → pas de cellarId
      expect(wine.foodPairings, ['Viandes']);
      expect(wine.bodyLevel, 0.8);
    });

    test('subtitle null et wines absent sont tolérés', () {
      final model = WineCategoryModel.fromJson({
        'key': 'k',
        'title': 'T',
      });
      expect(model.subtitle, isNull);
      expect(model.wines, isEmpty);
    });
  });

  group('DiscoveryBloc', () {
    test('succès : Loading puis Loaded avec les catégories', () async {
      final repo = _FakeRepo()
        ..onDiscovery = () => const Right([
              WineCategory(key: 'k', title: 'T', wines: []),
            ]);
      final bloc = DiscoveryBloc(getDiscovery: GetDiscovery(repo));

      bloc.add(const LoadDiscoveryEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<DiscoveryLoading>(),
          isA<DiscoveryLoaded>()
              .having((s) => s.categories, 'categories', hasLength(1)),
        ]),
      );
      await bloc.close();
    });

    test('échec : Loading puis Error', () async {
      final repo = _FakeRepo()
        ..onDiscovery = () => Left(ServerFailure('boom'));
      final bloc = DiscoveryBloc(getDiscovery: GetDiscovery(repo));

      bloc.add(const LoadDiscoveryEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<DiscoveryLoading>(),
          isA<DiscoveryError>(),
        ]),
      );
      await bloc.close();
    });
  });

  group('WineDetailBloc — ajout à la cave (contexte Découvertes)', () {
    const recoWine = Wine(
      id: 'w-reco',
      name: 'Vin reco',
      year: '2019',
      type: 'Rouge',
      region: 'Rhône',
      rating: 0,
      points: 0,
      apogee: '',
      stock: 0,
      enrichedAt: '2026-01-01T00:00:00Z', // déjà enrichi → pas d'enrich auto
    );

    WineDetailBloc buildBloc(_FakeRepo repo) => WineDetailBloc(
          wine: recoWine,
          updateWineStock: UpdateWineStock(repo),
          enrichWine: EnrichWine(repo),
          addWineToCellar: AddWineToCellar(repo),
        );

    test('succès : isAddingToCellar puis addedToCellar, stock 1 envoyé',
        () async {
      Wine? sent;
      final repo = _FakeRepo()
        ..onAddToCellar = (w) {
          sent = w;
          return const Right(null);
        };
      final bloc = buildBloc(repo);

      bloc.add(const AddToCellarEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<WineDetailLoaded>()
              .having((s) => s.isAddingToCellar, 'isAddingToCellar', true),
          isA<WineDetailLoaded>()
              .having((s) => s.isAddingToCellar, 'isAddingToCellar', false)
              .having((s) => s.addedToCellar, 'addedToCellar', true),
        ]),
      );
      expect(repo.addCalls, 1);
      expect(sent?.stock, 1); // ajout depuis reco → stock initial 1
      expect(sent?.id, 'w-reco');
      await bloc.close();
    });

    test('échec : addToCellarError renseigné, addedToCellar reste false',
        () async {
      final repo = _FakeRepo()
        ..onAddToCellar = (w) => Left(ServerFailure('boom'));
      final bloc = buildBloc(repo);

      bloc.add(const AddToCellarEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<WineDetailLoaded>()
              .having((s) => s.isAddingToCellar, 'isAddingToCellar', true),
          isA<WineDetailLoaded>()
              .having((s) => s.addedToCellar, 'addedToCellar', false)
              .having((s) => s.addToCellarError, 'addToCellarError',
                  isNotNull),
        ]),
      );
      await bloc.close();
    });

    test('vin déjà en cave (cellarId != null) : ajout ignoré', () async {
      final repo = _FakeRepo();
      final bloc = WineDetailBloc(
        wine: recoWine.copyWith(cellarId: 'c1'),
        updateWineStock: UpdateWineStock(repo),
        enrichWine: EnrichWine(repo),
        addWineToCellar: AddWineToCellar(repo),
      );

      bloc.add(const AddToCellarEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(repo.addCalls, 0);
      await bloc.close();
    });
  });
}

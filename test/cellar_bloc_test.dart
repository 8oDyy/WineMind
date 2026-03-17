import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winemind/core/error/failures.dart';
import 'package:winemind/core/usecases/usecase.dart';
import 'package:winemind/features/wine/domain/entities/wine.dart';
import 'package:winemind/features/wine/domain/usecases/get_all_wines.dart';
import 'package:winemind/features/wine/presentation/bloc/cellar_bloc.dart';
import 'package:winemind/features/wine/presentation/bloc/cellar_event.dart';
import 'package:winemind/features/wine/presentation/bloc/cellar_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';

import 'cellar_bloc_test.mocks.dart';

@GenerateMocks([GetAllWines])
void main() {
  late CellarBloc bloc;
  late MockGetAllWines mockGetAllWines;

  setUp(() {
    mockGetAllWines = MockGetAllWines();
    bloc = CellarBloc(getAllWines: mockGetAllWines);
  });

  tearDown(() {
    bloc.close();
  });

  const tWines = [
    Wine(
      name: 'Château Margaux',
      year: '2015',
      type: 'Rouge',
      region: 'Bordeaux, France',
      rating: 3.5,
      points: 95,
      apogee: '2025 - 2045',
      stock: 3,
    ),
    Wine(
      name: 'Domaine Ott',
      year: '2021',
      type: 'Rosé',
      region: 'Provence, France',
      rating: 4.0,
      points: 89,
      apogee: 'À boire maintenant',
      stock: 12,
    ),
    Wine(
      name: 'Puligny-Montrachet',
      year: '2019',
      type: 'Blanc',
      region: 'Bourgogne, France',
      rating: 4.5,
      points: 93,
      apogee: '2022 - 2030',
      stock: 5,
    ),
  ];

  group('CellarBloc', () {
    test('initial state is CellarInitial', () {
      expect(bloc.state, equals(const CellarInitial()));
    });

    group('LoadCellarEvent', () {
      blocTest<CellarBloc, CellarState>(
        'emits [CellarLoading, CellarLoaded] when getAllWines succeeds',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        act: (bloc) => bloc.add(const LoadCellarEvent()),
        expect: () => [
          const CellarLoading(),
          CellarLoaded(
            allWines: tWines,
            filteredWines: tWines,
            selectedType: 'Tous',
            searchQuery: '',
          ),
        ],
        verify: (_) {
          verify(mockGetAllWines(NoParams()));
        },
      );

      blocTest<CellarBloc, CellarState>(
        'emits [CellarLoading, CellarError] when getAllWines fails',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => Left(CacheFailure()));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        act: (bloc) => bloc.add(const LoadCellarEvent()),
        expect: () => [
          const CellarLoading(),
          const CellarError('Impossible de charger les vins.'),
        ],
      );
    });

    group('FilterWinesByTypeEvent', () {
      blocTest<CellarBloc, CellarState>(
        'filters wines by type Rouge',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        seed: () => CellarLoaded(
          allWines: tWines,
          filteredWines: tWines,
          selectedType: 'Tous',
          searchQuery: '',
        ),
        act: (bloc) => bloc.add(const FilterWinesByTypeEvent('Rouge')),
        expect: () => [
          CellarLoaded(
            allWines: tWines,
            filteredWines: [tWines[0]],
            selectedType: 'Rouge',
            searchQuery: '',
          ),
        ],
      );

      blocTest<CellarBloc, CellarState>(
        'filters wines by type Blanc',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        seed: () => CellarLoaded(
          allWines: tWines,
          filteredWines: tWines,
          selectedType: 'Tous',
          searchQuery: '',
        ),
        act: (bloc) => bloc.add(const FilterWinesByTypeEvent('Blanc')),
        expect: () => [
          CellarLoaded(
            allWines: tWines,
            filteredWines: [tWines[2]],
            selectedType: 'Blanc',
            searchQuery: '',
          ),
        ],
      );

      blocTest<CellarBloc, CellarState>(
        'shows all wines when type is Tous',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        seed: () => CellarLoaded(
          allWines: tWines,
          filteredWines: [tWines[0]],
          selectedType: 'Rouge',
          searchQuery: '',
        ),
        act: (bloc) => bloc.add(const FilterWinesByTypeEvent('Tous')),
        expect: () => [
          CellarLoaded(
            allWines: tWines,
            filteredWines: tWines,
            selectedType: 'Tous',
            searchQuery: '',
          ),
        ],
      );
    });

    group('SearchWinesEvent', () {
      blocTest<CellarBloc, CellarState>(
        'filters wines by search query (name)',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        seed: () => CellarLoaded(
          allWines: tWines,
          filteredWines: tWines,
          selectedType: 'Tous',
          searchQuery: '',
        ),
        act: (bloc) => bloc.add(const SearchWinesEvent('Margaux')),
        expect: () => [
          CellarLoaded(
            allWines: tWines,
            filteredWines: [tWines[0]],
            selectedType: 'Tous',
            searchQuery: 'Margaux',
          ),
        ],
      );

      blocTest<CellarBloc, CellarState>(
        'filters wines by search query (year)',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        seed: () => CellarLoaded(
          allWines: tWines,
          filteredWines: tWines,
          selectedType: 'Tous',
          searchQuery: '',
        ),
        act: (bloc) => bloc.add(const SearchWinesEvent('2021')),
        expect: () => [
          CellarLoaded(
            allWines: tWines,
            filteredWines: [tWines[1]],
            selectedType: 'Tous',
            searchQuery: '2021',
          ),
        ],
      );

      blocTest<CellarBloc, CellarState>(
        'search is case insensitive',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        seed: () => CellarLoaded(
          allWines: tWines,
          filteredWines: tWines,
          selectedType: 'Tous',
          searchQuery: '',
        ),
        act: (bloc) => bloc.add(const SearchWinesEvent('domaine')),
        expect: () => [
          CellarLoaded(
            allWines: tWines,
            filteredWines: [tWines[1]],
            selectedType: 'Tous',
            searchQuery: 'domaine',
          ),
        ],
      );

      blocTest<CellarBloc, CellarState>(
        'returns empty list when no match',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        seed: () => CellarLoaded(
          allWines: tWines,
          filteredWines: tWines,
          selectedType: 'Tous',
          searchQuery: '',
        ),
        act: (bloc) => bloc.add(const SearchWinesEvent('xyz')),
        expect: () => [
          CellarLoaded(
            allWines: tWines,
            filteredWines: [],
            selectedType: 'Tous',
            searchQuery: 'xyz',
          ),
        ],
      );

      blocTest<CellarBloc, CellarState>(
        'clears search when query is empty',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        seed: () => CellarLoaded(
          allWines: tWines,
          filteredWines: [tWines[0]],
          selectedType: 'Tous',
          searchQuery: 'Margaux',
        ),
        act: (bloc) => bloc.add(const SearchWinesEvent('')),
        expect: () => [
          CellarLoaded(
            allWines: tWines,
            filteredWines: tWines,
            selectedType: 'Tous',
            searchQuery: '',
          ),
        ],
      );
    });

    group('Combined filters', () {
      blocTest<CellarBloc, CellarState>(
        'applies both type filter and search query',
        build: () {
          when(mockGetAllWines(any))
              .thenAnswer((_) async => const Right(tWines));
          return CellarBloc(getAllWines: mockGetAllWines);
        },
        seed: () => CellarLoaded(
          allWines: tWines,
          filteredWines: tWines,
          selectedType: 'Tous',
          searchQuery: '',
        ),
        act: (bloc) {
          bloc.add(const FilterWinesByTypeEvent('Rouge'));
          bloc.add(const SearchWinesEvent('2015'));
        },
        expect: () => [
          CellarLoaded(
            allWines: tWines,
            filteredWines: [tWines[0]],
            selectedType: 'Rouge',
            searchQuery: '',
          ),
          CellarLoaded(
            allWines: tWines,
            filteredWines: [tWines[0]],
            selectedType: 'Rouge',
            searchQuery: '2015',
          ),
        ],
      );
    });
  });
}

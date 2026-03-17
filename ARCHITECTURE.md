# Architecture WineMind

## Vue d'ensemble

WineMind suit une **Clean Architecture** organisée par **feature**, avec **Bloc** comme state management.

```
Presentation → Domain ← Data
```

La couche **Domain** est le centre : elle ne dépend de rien d'externe (ni Flutter, ni API, ni base de données).

---

## Structure du projet

```
lib/
├── main.dart                    # Point d'entrée, init DI + runApp
├── app.dart                     # MaterialApp, thème, MainScreen (navigation)
├── injection_container.dart     # Configuration get_it (dependency injection)
│
├── core/
│   ├── error/
│   │   ├── failures.dart        # Failure abstraite + ServerFailure, CacheFailure
│   │   └── exceptions.dart      # ServerException, CacheException
│   ├── usecases/
│   │   └── usecase.dart         # UseCase<Output, Params> abstrait + NoParams
│   ├── theme/
│   │   ├── app_colors.dart      # Constantes de couleurs
│   │   └── app_theme.dart       # ThemeData Material 3
│   └── widgets/
│       └── bottom_nav_bar.dart  # Navigation bar partagée entre features
│
└── features/
    └── wine/
        ├── domain/
        │   ├── entities/
        │   │   └── wine.dart            # Entité métier Wine (Equatable)
        │   ├── repositories/
        │   │   └── wine_repository.dart # Contrat abstrait du repository
        │   └── usecases/
        │       ├── get_last_wine.dart   # Récupérer le dernier vin
        │       └── get_all_wines.dart   # Récupérer tous les vins
        ├── data/
        │   ├── models/
        │   │   └── wine_model.dart              # WineModel (fromJson/toJson)
        │   ├── datasources/
        │   │   └── wine_local_data_source.dart  # Source locale (mock pour l'instant)
        │   └── repositories/
        │       └── wine_repository_impl.dart    # Implémentation du repository
        └── presentation/
            ├── bloc/
            │   ├── wine_bloc.dart       # BLoC principal
            │   ├── wine_event.dart      # Événements (GetLastWine, GetAllWines)
            │   └── wine_state.dart      # États (Initial, Loading, Loaded, Error)
            ├── pages/
            │   └── home_page.dart       # Page d'accueil avec BlocBuilder
            └── widgets/
                └── wine_last_card.dart  # Carte du dernier vin
```

---

## Les 3 couches

### Domain (logique métier pure)

| Élément      | Rôle                                                    |
|--------------|---------------------------------------------------------|
| **Entity**   | Objet métier immutable (Equatable), aucune dépendance   |
| **Repository** (abstrait) | Contrat que la couche Data doit implémenter |
| **UseCase**  | Une action métier = une classe, une méthode `call()`    |

Le Domain **ne connaît** ni Flutter, ni JSON, ni Supabase, ni aucune API.

### Data (accès aux données)

| Élément          | Rôle                                                |
|------------------|-----------------------------------------------------|
| **Model**        | Étend l'entité, ajoute `fromJson` / `toJson`        |
| **DataSource**   | Contrat + implémentation d'accès aux données         |
| **Repository Impl** | Implémente le contrat du Domain, gère les erreurs |

### Presentation (UI + state)

| Élément    | Rôle                                           |
|------------|------------------------------------------------|
| **Bloc**   | Reçoit des Events, émet des States via UseCases |
| **Pages**  | Écrans complets avec `BlocBuilder`              |
| **Widgets**| Composants UI réutilisables                     |

---

## Dependency Injection

Fichier : `lib/injection_container.dart`

On utilise **get_it** pour enregistrer toutes les dépendances au démarrage :

```
DataSource → Repository → UseCase → Bloc
```

Chaque Bloc est un `Factory` (nouvelle instance par écran).
Les UseCases, Repositories et DataSources sont des `LazySingleton`.

---

## Flux de données

```
UI (Event) → Bloc → UseCase → Repository (abstrait)
                                     ↓
                              RepositoryImpl → DataSource
                                     ↓
                              Either<Failure, Data>
                                     ↓
                              Bloc → State → UI
```

Le type `Either<Failure, T>` (package `dartz`) permet de gérer les erreurs de manière fonctionnelle, sans try/catch dans le Bloc.

---

## Conventions

- **1 feature = 1 dossier** sous `lib/features/`
- **1 use case = 1 fichier**
- Les entités sont **immutables** et utilisent **Equatable**
- Les couleurs et thèmes sont centralisés dans `core/theme/`
- Les widgets partagés entre features vont dans `core/widgets/`

---

## Dépendances

| Package        | Usage                        |
|----------------|------------------------------|
| `flutter_bloc` | State management (BLoC)      |
| `equatable`    | Comparaison d'objets par valeur |
| `get_it`       | Injection de dépendances     |
| `dartz`        | Type `Either` (gestion d'erreurs fonctionnelle) |

---

## Ajouter une nouvelle feature

1. Créer `lib/features/<nom>/domain/entities/` — entité métier
2. Créer `lib/features/<nom>/domain/repositories/` — contrat abstrait
3. Créer `lib/features/<nom>/domain/usecases/` — cas d'usage
4. Créer `lib/features/<nom>/data/models/` — modèle avec sérialisation
5. Créer `lib/features/<nom>/data/datasources/` — source de données
6. Créer `lib/features/<nom>/data/repositories/` — implémentation
7. Créer `lib/features/<nom>/presentation/bloc/` — événements, états, bloc
8. Créer `lib/features/<nom>/presentation/pages/` — écrans
9. Créer `lib/features/<nom>/presentation/widgets/` — composants UI
10. Enregistrer les dépendances dans `injection_container.dart`

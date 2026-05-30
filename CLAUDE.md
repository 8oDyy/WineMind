# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

WineMind est une application **Flutter** (cave à vin + assistant IA) ciblant **iOS en priorité**. Réponses et commentaires en français.

## ⚠️ Mode de travail (À RESPECTER IMPÉRATIVEMENT)

- **Déléguer toute tâche à des sous-agents.** Claude principal agit comme **chef d'orchestre** : il découpe le travail, lance les sous-agents, puis synthétise — il n'édite/n'implémente pas lui-même.
- **Paralléliser au maximum** : lancer les sous-agents indépendants **dans un seul message** (plusieurs appels `Agent`) pour qu'ils tournent en même temps.
- **Toujours utiliser le modèle `sonnet`** pour les sous-agents (`model: "sonnet"`).
- **Toute remarque pertinente DOIT être ajoutée à ce `CLAUDE.md`** (décision d'archi, piège récurrent, convention, info backend, etc.) — c'est la mémoire partagée du projet.
- **Vérification après chaque grande modification de code** : l'orchestrateur lance l'agent `app-tester` (`.claude/agents/app-tester.md`, Sonnet) pour confirmer que l'app marche toujours (analyse + tests + build iOS + smoke-test simulateur) et remonter les régressions. Cet agent **diagnostique et rapporte, ne corrige pas** — l'orchestrateur décide des suites. « Grande modification » = touche à un datasource/repository/bloc/usecase, ajout/refactor de feature, changement du DI (`injection_container.dart`) ou de la navigation. Inutile pour de la doc, un commentaire, un renommage trivial.
- **Travail front-end / UI délégué** : dès qu'une tâche concerne l'interface (écran/page, widget, layout, navigation/routing, thème/styles, animations, widget tests), l'orchestrateur la délègue à l'agent `flutter-frontend` (`.claude/agents/flutter-frontend.md`, Sonnet), qui s'appuie sur les skills `flutter-*` et `frontend-design` et respecte la Clean Architecture + BLoC (UI dans `presentation/` uniquement, jamais d'accès données dans les widgets).

## Commandes

```bash
flutter pub get                 # Installer les dépendances
flutter run                     # Lancer l'app (device/simulateur iOS sélectionné)
flutter analyze                 # Lint statique (flutter_lints)
flutter test                    # Tous les tests
flutter test test/cellar_bloc_test.dart   # Un seul fichier de test
flutter test --name "nom du test"          # Un test par son nom

# Régénérer les mocks Mockito (après modif d'une interface mockée)
dart run build_runner build --delete-conflicting-outputs
```

Les fichiers `*.mocks.dart` (ex. `test/cellar_bloc_test.mocks.dart`) sont générés par `build_runner` à partir des annotations `@GenerateMocks`. Ne pas les éditer à la main.

## Architecture

**Clean Architecture organisée par feature**, avec le flux de dépendances `Presentation → Domain ← Data`. La couche **Domain** est pure (aucune dépendance à Flutter, JSON, Supabase ou HTTP).

Chaque feature sous `lib/features/<nom>/` suit la même structure :

- `domain/` — `entities/` (objets métier immutables, `Equatable`), `repositories/` (contrats abstraits), `usecases/` (1 action = 1 classe avec `call()`).
- `data/` — `models/` ou `dtos/` (sérialisation `fromJson`/`toJson`), `datasources/` (accès Supabase ou HTTP), `repositories/` (impl. du contrat Domain, transforme exceptions → `Failure`), parfois `mappers/`.
- `presentation/` — `bloc/` (Event → Bloc → State via UseCases), `pages/` (écrans), `widgets/` (composants UI).

Features existantes : `auth`, `ai` (chat), `wine` (cave + détail), `wine_label` (scan étiquette + ajout), `dishpicture` (analyse de plat), `home`, `settings`, `splash`.

### Conventions transverses

- **Gestion d'erreur fonctionnelle** : les repositories renvoient `Either<Failure, T>` (package `dartz`). Le Bloc fait `.fold(...)` sur le résultat ; **pas de `try/catch` dans le Bloc**. Les DataSources lèvent des exceptions (`ServerException`, `CacheException` dans `core/error/`), converties en `Failure` par le RepositoryImpl.
- **State management** : `flutter_bloc`. Les Blocs sont des `Factory` (instance par écran/provider) ; UseCases, Repositories et DataSources sont des `LazySingleton`.
- **Code partagé** : `core/` contient `theme/` (`AppColors`, `AppTheme` Material 3), `error/`, `usecases/` (base `UseCase<Output, Params>` + `NoParams`) et `widgets/` (ex. `BottomNavBar`).

### Injection de dépendances

Tout est câblé dans `lib/injection_container.dart` (get_it, alias `sl`), appelé via `di.init()` dans `main.dart` avant `runApp`. Ordre d'enregistrement par feature : DataSource → Repository → UseCases → Bloc. Pour **ajouter une feature**, créer l'arborescence ci-dessus puis enregistrer les dépendances dans ce fichier ; brancher le Bloc dans le `MultiBlocProvider` de `lib/app.dart`.

### Démarrage & navigation

`main.dart` initialise Supabase puis `di.init()`. `lib/app.dart` monte le `MultiBlocProvider` global et `SplashGate`, qui vérifie/rafraîchit la session Supabase et route vers `AuthChoicePage` (déconnecté) ou `MainScreen`. `MainScreen` utilise un `IndexedStack` + `BottomNavBar` à 4 onglets : Home, Wines, Cellar, Settings.

## Backends

L'app parle à **deux** backends :

1. **Supabase** — auth et données vin. URL + `anonKey` en dur dans `main.dart`, client exposé via get_it (`SupabaseClient`).
2. **API HTTP** (FastAPI, IA + analyse d'images : chat, étiquettes, plats) — **`baseUrl` codé en dur** dans `lib/injection_container.dart` (chat IA, wine_label, dishpicture) et comme défaut dans `lib/features/ai/data/datasources/ai_remote_data_source.dart`.
   - **Prod** : `https://winemind.fr` (health `/health`, doc `/docs`). Le `baseUrl` est centralisé dans `lib/core/config/app_config.dart` (`AppConfig.apiBaseUrl`) — **source de vérité unique**, ne plus jamais coder d'IP/URL en dur ailleurs.
   - **Code source du backend** (repo séparé, hors de ce projet Flutter) : `/Users/boulicaut/PycharmProjects/Wind-Mind_back` (FastAPI, `app/main.py`, Docker). À consulter pour connaître les endpoints, leurs payloads/réponses, ou diagnostiquer une erreur côté API.

### État du routage API

- **Via l'API** : chat (`POST /chat`), analyse plat (`POST /api/wine-pairing`), analyse étiquette (`POST /api/wine-label-analysis`), ajout via étiquette (`POST /api/wine-label-add`), **CRUD cave** (`GET/POST /api/cellar`, `GET /api/cellar/last`, `DELETE /api/cellar/{id}`, `PATCH /api/cellar/{id}/stock`) et **profil** (`PATCH /api/profile`, `DELETE /api/account`).
- **Endpoints JWT** : cave, profil, **et `wine-label-analysis`/`wine-label-add`** envoient le **JWT Supabase** dans le header `Authorization: Bearer <accessToken>` (via `supabase.auth.currentSession?.accessToken`). Le backend déduit l'`user_id` du token — **ne jamais passer d'`user_id` dans le body**. La spec backend de référence est `docs/backend-spec-cave-profil.md`.
- **Endpoints publics (sans JWT)** : `POST /chat` (ai) et `POST /api/wine-pairing` (analyse plat).
- **Reste légitimement côté client (Supabase direct)** : Supabase Auth uniquement — `register`/`login`/`logout`/`getCurrentUser` dans `auth_remote_data_source.dart`, et le refresh de session dans `app.dart`.
- ⚠️ **Hors périmètre / à surveiller** : les uploads d'images (`wine_label`, `dishpicture`) écrivent toujours en direct dans Supabase Storage + table de métadonnées (non migré vers l'API).
- Note : `WineAnalysisResult.existingProposal` est **nullable** (`null` = aucune correspondance catalogue) ; la page `wine_selection_page` masque alors la carte « Option 1 - Vin existant ».

### Tests

⚠️ `test/wine_detail_page_test.dart` est **cassé et pré-existant** : il référence des champs d'entité `Wine` qui n'existent plus (`subRegion`, `classification`, `alcohol`, `grapes`) et un fake `WineRepository` incomplet. Tant qu'il n'est pas corrigé, `flutter test` ne compile pas. À réparer ou retirer indépendamment.

⚠️ L'API vient d'être déployée mais les `baseUrl` pointent encore vers des **IP de réseau local** (ex. `http://10.74.16.212:8000`) qui changent. En cas d'erreur réseau sur le chat / l'analyse, **vérifier et mettre à jour ces `baseUrl`** (chercher `baseUrl:` dans `injection_container.dart`). À terme, centraliser dans une config plutôt que de les dupliquer.

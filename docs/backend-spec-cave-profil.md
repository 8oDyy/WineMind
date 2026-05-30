# Spec backend — Endpoints Cave + Profil (à implémenter)

> Destinataire : agent backend du repo `Wind-Mind_back` (FastAPI, Python 3.13).
> Objectif : ajouter les endpoints permettant à l'app Flutter d'arrêter d'accéder à
> Supabase en direct pour les **données métier** (cave + profil). L'authentification
> Supabase (login/signup/session) reste côté client — elle n'est PAS concernée.
>
> **Décision produit déjà prise :** périmètre = Cave + Profil ; sécurité = vérification du **JWT Supabase**.

---

## 0. Principe directeur (IMPORTANT)

L'app Flutter parse déjà les rows Supabase via des mappers existants. **Pour minimiser le refactor Flutter et le risque, les endpoints de lecture doivent renvoyer EXACTEMENT la même forme JSON que les rows Supabase actuelles** (row `user_cellar` avec l'objet `wines` imbriqué). Ainsi le parser Flutter `WineModel.fromCellarJson` reste identique : seul l'appel réseau change (HTTP au lieu du SDK Supabase).

Concrètement, un élément de cave renvoyé par l'API doit avoir cette forme (clés snake_case identiques à la table) :

```json
{
  "id": "<uuid user_cellar>",
  "user_id": "<uuid>",
  "wine_id": "<uuid|null>",
  "stock": 3,
  "rating": 0.0,
  "apogee": "",
  "notes": null,
  "location": null,
  "purchase_date": null,
  "purchase_price": null,
  "custom_name": null,
  "custom_year": null,
  "custom_type": null,
  "custom_region": null,
  "custom_points": null,
  "custom_description": null,
  "custom_price": null,
  "custom_variety": null,
  "custom_winery": null,
  "created_at": "2026-05-29T...",
  "wines": {
    "id": "...", "name": "...", "year": 2018, "type": "Rouge", "region": "...",
    "points": 90, "description": "...", "designation": "...", "price": 25.0,
    "province": "...", "country": "...", "variety": "...", "winery": "...",
    "food_pairings": ["..."], "body_level": 0.6, "tannin_level": 0.5,
    "fruit_level": 0.4, "image_url": "..."
  }
}
```

`wines` vaut `null` pour un vin "custom" (entrée de cave sans `wine_id`, les infos sont dans les champs `custom_*`).

---

## 1. Authentification : dépendance `get_current_user` (JWT Supabase)

Aucun endpoint n'est protégé aujourd'hui, et `pyjwt`/`python-jose` ne sont pas installés. À faire :

1. Ajouter `pyjwt` à `requirements.txt`.
2. Ajouter dans `.env` (et `.env.example`) : `SUPABASE_JWT_SECRET` (Dashboard Supabase → Settings → API → JWT Secret).
3. Créer `app/dependencies/auth.py` :
   - Dépendance `get_current_user_id(creds = Depends(HTTPBearer()))`.
   - Décode le JWT avec `jwt.decode(token, SUPABASE_JWT_SECRET, algorithms=["HS256"], audience="authenticated")`.
   - Retourne `sub` (UUID de l'utilisateur) — type `UUID`.
   - Lève `HTTPException(401)` si token absent/invalide/expiré.

**Règle de sécurité (non négociable) :** pour TOUS les nouveaux endpoints, l'`user_id` provient **uniquement du JWT**, jamais du body ni de la query. Toute opération sur `user_cellar`/`profiles` est filtrée par cet `user_id`. Une ressource (`cellar_id`) qui n'appartient pas à l'utilisateur → `404`.

> Note (hors périmètre, à signaler) : les endpoints existants `/api/wine-label-*` et `/api/wine-label-add` prennent `user_id` dans le body et ne sont pas authentifiés. À terme ils devraient être migrés sur `get_current_user_id` (et retirer `user_id` du body). Non bloquant pour cette tâche.

---

## 2. Endpoints à créer

Tous sous le prefix existant `/api`, JWT requis (header `Authorization: Bearer <supabase_access_token>`).

### 2.1 `GET /api/cellar` — lister la cave
- **Auth :** JWT. **Body :** aucun.
- **Logique :** `SELECT *, wines(*) FROM user_cellar WHERE user_id = <jwt.sub> ORDER BY created_at DESC`.
- **Réponse 200 :** **liste** d'objets au format §0 (row `user_cellar` + `wines` imbriqué). Liste vide `[]` si aucune entrée.
- **Remplace (Flutter) :** `WineRemoteDataSource.getUserCellar()`.

### 2.2 `GET /api/cellar/last` — dernier vin ajouté
- **Auth :** JWT. **Body :** aucun.
- **Logique :** idem 2.1 avec `LIMIT 1`.
- **Réponse 200 :** un objet au format §0, ou **`404`** si la cave est vide (le Flutter traite l'absence comme `CacheFailure`, voir note refactor §4).
- **Remplace :** `getLastCellarWine()`.

### 2.3 `POST /api/cellar` — ajouter un vin à la cave
- **Auth :** JWT. **Body (JSON)** — supporte 2 cas (vin catalogue OU vin custom) :

```jsonc
{
  "wine_id": "<uuid|null>",        // présent => vin du catalogue ; null/absent => vin custom
  "stock": 1,                       // requis, >= 0
  "rating": 0.0,                    // optionnel, défaut 0.0
  "apogee": "",                     // optionnel, défaut ""
  "notes": null,                    // optionnel
  "location": null,                 // optionnel
  "purchase_date": null,            // optionnel (string ISO)
  "purchase_price": null,           // optionnel (float)
  // Champs custom_* uniquement si wine_id absent :
  "custom_name": "...",
  "custom_year": "...",            // string
  "custom_type": "...",
  "custom_region": "...",
  "custom_points": 0                // int
}
```
- **Logique :** `INSERT` dans `user_cellar` avec `user_id = jwt.sub`. ⚠️ Le service existant `add_to_user_cellar()` ne gère QUE `user_id, wine_id, stock, notes, location` — il faut **l'étendre** pour accepter `rating, apogee, purchase_date, purchase_price` et les `custom_*`, et autoriser `wine_id = null`.
- **Réponse 201 :** l'entrée créée au format §0 (re-SELECT avec `wines(*)` pour cohérence).
- **Remplace :** `addToCellar(WineModel)` (voir map `toCellarInsert` dans la spec Flutter §3).

### 2.4 `DELETE /api/cellar/{cellar_id}` — retirer un vin
- **Auth :** JWT. **Path :** `cellar_id` (UUID).
- **Logique :** `DELETE FROM user_cellar WHERE id = cellar_id AND user_id = jwt.sub`. Si 0 ligne supprimée → `404`.
- **Réponse :** `204 No Content`.
- **Remplace :** `removeFromCellar(cellarId)`.

### 2.5 `PATCH /api/cellar/{cellar_id}/stock` — mettre à jour le stock
- **Auth :** JWT. **Path :** `cellar_id`. **Body :** `{ "stock": <int >= 0> }`.
- **Logique :** `UPDATE user_cellar SET stock = ... WHERE id = cellar_id AND user_id = jwt.sub`. 0 ligne → `404`.
- **Réponse 200 :** l'entrée mise à jour (format §0) — ou `204` (au choix, voir §4 : Flutter n'utilise pas le retour aujourd'hui).
- **Remplace :** `updateCellarStock(cellarId, stock)`.

### 2.6 `PATCH /api/profile` — mettre à jour le profil
- **Auth :** JWT. **Body (JSON, tous optionnels)** :
```json
{ "niveau": "...", "preference": "...", "objectif": "..." }
```
- **Logique :** `UPDATE profiles SET <champs non-null> WHERE id = jwt.sub`. Si body vide, no-op (200). ⚠️ Le backend ne touche **jamais** `profiles` aujourd'hui → créer un petit service `app/services/profile.py`.
- **Réponse 200 :** le profil à jour `{ id, email, prenom, nom, niveau, preference, objectif }` (clés identiques à `UserModel.fromJson`).
- **Remplace :** `AuthRemoteDataSource.updateProfile(...)`.

### 2.7 `DELETE /api/account` — suppression de compte (vraie suppression)
- **Auth :** JWT.
- **Logique :** c'est LA valeur ajoutée du backend (impossible côté client) :
  1. `DELETE FROM profiles WHERE id = jwt.sub`.
  2. Supprimer le compte auth via l'API admin service_role : `supabase.auth.admin.delete_user(jwt.sub)`.
  3. (optionnel) nettoyer `user_cellar` de l'utilisateur si pas de cascade FK.
- **Réponse :** `204 No Content`.
- **Remplace :** `deleteAccount(...)` (qui aujourd'hui ne supprime que la row `profiles`, pas le compte auth).

---

## 3. Référence colonnes (confirmé par le code existant)

- **`user_cellar`** : `id`, `user_id`, `wine_id`, `stock`, `rating`, `apogee`, `location`, `notes`, `purchase_date`, `purchase_price`, `custom_name`, `custom_year`, `custom_type`, `custom_region`, `custom_points`, `custom_description`, `custom_price`, `custom_variety`, `custom_winery`, `created_at`.
- **`wines`** (catalogue, lecture seule via jointure) : `id`, `name`, `year`, `type`, `region`, `points`, `description`, `designation`, `price`, `province`, `country`, `variety`, `winery`, `food_pairings`, `body_level`, `tannin_level`, `fruit_level`, `image_url`.
- **`profiles`** : `id`, `email`, `prenom`, `nom`, `niveau`, `preference`, `objectif`.

---

## 4. Conventions à respecter (alignées sur l'existant)

- Routers `APIRouter(prefix="/api", tags=[...])`, handlers `async def`, `logger = logging.getLogger(__name__)`.
- Schémas Pydantic par feature dans `app/schemas/` (Request/Response/Error ; `Error` = `{error: str, detail: str}`).
- Client Supabase : pattern `_get_client()` avec `SUPABASE_SERVICE_ROLE_KEY` (déjà en place dans `app/services/`). Réutiliser/étendre `app/services/wine_cellar.py` ; créer `app/services/profile.py`.
- `HTTPException` avec messages FR ; 401 (auth), 404 (ressource non possédée/absente), 400 (validation métier), 422 (Pydantic), 500/502 (Supabase/LLM down).
- Enregistrer les nouveaux routers dans `app/main.py` (`include_router`).

## 5. Definition of Done
- [ ] `pyjwt` ajouté, `SUPABASE_JWT_SECRET` documenté dans `.env.example`.
- [ ] `app/dependencies/auth.py` avec `get_current_user_id` (HS256, audience `authenticated`).
- [ ] 7 endpoints des §2 implémentés, tous protégés par JWT, `user_id` jamais lu du body.
- [ ] Réponses de lecture au format §0 (row `user_cellar` + `wines` imbriqué) — vérifié contre le parser Flutter.
- [ ] `add_to_user_cellar` étendu (custom_*, rating, apogee, purchase_*, wine_id nullable).
- [ ] `/docs` (OpenAPI) expose les nouveaux endpoints ; testés sur `https://winemind.fr`.

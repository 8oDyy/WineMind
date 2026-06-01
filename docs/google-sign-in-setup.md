# Guide de configuration — « Se connecter avec Google » (iOS)

Mode d'emploi pas-à-pas pour activer la connexion Google dans WineMind.
Le **code Flutter est déjà prêt** (flow natif `signInWithIdToken`). Il ne manque
plus que **3 configurations manuelles** à faire dans cet ordre :

1. **Google Cloud Console** → créer le projet + les clients OAuth (ce guide).
2. **Supabase** → activer le provider Google (Web client ID + secret).
3. **Projet Flutter** → coller les client IDs dans `app_config.dart` + `Info.plist`.

> ℹ️ **Bundle ID** : le projet iOS utilise le bundle ID **`fr.winemind.app`** (toutes
> configurations de build). C'est cette valeur **exacte** qu'il faudra déclarer dans le
> client OAuth iOS (Étape 4). Le client iOS Google **doit correspondre** à ce bundle ID,
> sinon la connexion native échoue.

---

## Étape 1 — Créer / sélectionner le projet Google Cloud

1. Aller sur https://console.cloud.google.com/.
2. En haut, ouvrir le sélecteur de projet → **New Project** (ou réutiliser un projet existant).
3. Nom : `WineMind` (libre). Créer, puis **sélectionner** ce projet.

## Étape 2 — Configurer l'écran de consentement OAuth (obligatoire avant de créer un client)

1. Menu ☰ → **APIs & Services** → **OAuth consent screen**.
2. **User Type** : **External** → Create.
3. Renseigner :
   - **App name** : `WineMind`
   - **User support email** : votre email
   - **Developer contact information** : votre email
4. **Scopes** : laisser les scopes par défaut (`email`, `profile`, `openid` sont suffisants — c'est ce que le code demande). Pas de scope sensible à ajouter.
5. **Test users** : tant que l'app est en mode « Testing », **ajouter votre adresse Google** ici, sinon la connexion sera refusée. (Passer en « Production » plus tard pour ouvrir à tous.)
6. Sauvegarder.

## Étape 3 — Créer le client OAuth **Web** (utilisé par Supabase + `serverClientId`)

> C'est le client le plus important : son ID est l'**audience** que Supabase et le code Flutter (`serverClientId`) attendent. Sans lui, `signInWithIdToken` échoue.

1. **APIs & Services** → **Credentials** → **+ Create Credentials** → **OAuth client ID**.
2. **Application type** : **Web application**.
3. **Name** : `WineMind Web (Supabase)`.
4. **Authorized redirect URIs** → **Add URI** :
   ```
   https://ibjnyfvihtdbpdtieegr.supabase.co/auth/v1/callback
   ```
   (C'est l'URL du callback Supabase du projet WineMind — domaine `ibjnyfvihtdbpdtieegr.supabase.co`.)
5. **Create**.
6. **Récupérer et noter** :
   - 🔑 **Client ID** (finit par `.apps.googleusercontent.com`) → c'est le **Web client ID**.
   - 🔑 **Client secret** → le **Web secret**.

## Étape 4 — Créer le client OAuth **iOS**

1. **APIs & Services** → **Credentials** → **+ Create Credentials** → **OAuth client ID**.
2. **Application type** : **iOS**.
3. **Name** : `WineMind iOS`.
4. **Bundle ID** : `fr.winemind.app` (valeur exacte, sans espace ni faute).
5. **Create**.
6. **Récupérer et noter** :
   - 🔑 **iOS Client ID** (finit par `.apps.googleusercontent.com`).
   - 🔑 **iOS URL scheme** (= **reversed client ID**) : Google l'affiche directement sous le client iOS. Format : `com.googleusercontent.apps.XXXXXXXX-xxxxxxxx`. C'est simplement l'iOS Client ID **à l'envers** (les segments séparés par points inversés).

---

## Récapitulatif des valeurs à récupérer et où elles servent

| Valeur | Où la trouver | Où elle sert ensuite |
|---|---|---|
| **Web client ID** | Client OAuth **Web** (Étape 3) | ① Supabase (Auth > Providers > Google, champ « Client ID ») ② Flutter `AppConfig.googleWebClientId` (= `serverClientId`) |
| **Web secret** | Client OAuth **Web** (Étape 3) | Supabase (Auth > Providers > Google, champ « Client Secret ») — **uniquement côté Supabase, jamais dans le code Flutter** |
| **iOS client ID** | Client OAuth **iOS** (Étape 4) | Flutter `AppConfig.googleIosClientId` |
| **iOS reversed client ID** (URL scheme) | Client OAuth **iOS** (Étape 4) | `ios/Runner/Info.plist` → `CFBundleURLTypes` / `CFBundleURLSchemes` |

> ⚠️ **Ne jamais committer le Web secret dans le dépôt Flutter.** Il ne sert qu'à Supabase.

---

## Étapes suivantes (hors Google Cloud, faites par l'équipe)

Une fois les 4 valeurs récupérées, transmettez-les pour :

### A. Supabase (provider Google)
Dashboard Supabase → **Authentication** → **Providers** → **Google** :
- **Enable** ✅
- **Client ID** = Web client ID
- **Client Secret** = Web secret
- **Skip nonce checks** = **ON** (activé) — le code Flutter ne passe pas de nonce (flow natif `google_sign_in` v7), donc Supabase doit désactiver sa vérification de nonce, sinon le token est rejeté.
- Sauvegarder.

### B. Flutter — `lib/core/config/app_config.dart`
Remplacer les placeholders :
```dart
static const String googleIosClientId = '<iOS client ID>.apps.googleusercontent.com';
static const String googleWebClientId = '<Web client ID>.apps.googleusercontent.com';
```
(Le getter `isGoogleSignInConfigured` repassera automatiquement à `true` et débloquera le bouton.)

### C. Flutter — `ios/Runner/Info.plist`
Ajouter le bloc `CFBundleURLTypes` avec le **reversed client ID** :
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.XXXXXXXX-xxxxxxxx</string>
    </array>
  </dict>
</array>
```

---

## Notes / pièges

- **Mode « Testing » vs « Production »** : tant que l'OAuth consent screen est en *Testing*, seuls les *test users* déclarés (Étape 2.5) peuvent se connecter. Passer en *Production* pour ouvrir au public (peut déclencher une revue Google si des scopes sensibles sont demandés — ici non, donc instantané en général).
- **Le Web client ID est bien celui passé à `serverClientId`** côté Flutter (pas l'iOS client ID) : c'est l'identité que Supabase valide comme audience du token Google. Inverser les deux = erreur `Invalid audience`.
- **Bundle ID** : le client iOS Google doit déclarer exactement `fr.winemind.app`, sinon la connexion native échoue.
- **Nonce** : le code Flutter **ne passe pas de nonce** (flow natif `google_sign_in` v7). Côté Supabase, le provider Google doit donc avoir **« Skip nonce checks » = ON** (cf. section A). Rien à configurer côté Google Cloud pour ça.
- **Délai de propagation** : après création/modif dans Google Cloud, compter quelques minutes avant que ce soit actif.

# Module Utilisateurs - Documentation Implémentation

## 📋 Vue d'ensemble

Le module utilisateurs a été complètement implémenté pour le frontend Flutter, suivant l'architecture DDD (Domain-Driven Design) cohérente avec les autres modules du projet.

**Important**: L'application mobile est UNIQUEMENT pour les clients. Les rôles supportés sont:
- `paroissien` - Peut voir son profil
- `ancien` - Peut voir son profil et celui des autres membres
- `pasteur` - Peut voir tous les membres de son église (CRUD)
- `secrétaire` - Peut voir les membres de son église
- `trésorier` - Peut voir les membres de son église
- ~~`administrateur`~~ - NON SUPPORTÉ (application web séparée)

## 🏗️ Architecture Implémentée

### Structure des fichiers
```
features/users/
├── data/
│   └── models/
│       └── user_model.dart          (Conversion JSON)
├── domain/
│   └── entities/
│       └── user_entity.dart         (Entité domaine)
└── presentation/
    ├── providers/
    │   └── users_provider.dart      (État & logique métier)
    └── screens/
        ├── users_screen.dart        (Liste des utilisateurs)
        ├── user_detail_screen.dart  (Détails & édition)
        └── my_profile_screen.dart   (Mon profil)
```

## 📦 Composants Implémentés

### 1. **Users Provider** (`users_provider.dart`)

#### DataSource
```dart
class UsersDataSource {
  Future<List<UserEntity>> getUsers({int page = 1, Map<String, dynamic>? filters})
  Future<UserEntity> getUser(int id)
  Future<UserEntity> updateUser(int id, Map<String, dynamic> data)
  Future<String> uploadPhoto(int id, String filePath)
}
```

#### État et Notifiers
- **UsersListState**: Gère la liste paginée des utilisateurs
- **UsersListNotifier**: Actions: `load()`, `loadMore()`, `search()`, `refresh()`
- **UserDetailState**: Gère les détails d'un utilisateur
- **UserDetailNotifier**: Actions: `loadUser()`, `updateUser()`, `uploadPhoto()`

#### Providers
```dart
final usersListProvider         // Liste paginée
final userDetailProvider        // Détails & actions
final usersDataSourceProvider   // Accès aux données
```

### 2. **Écrans (Screens)**

#### UsersScreen
- **Affichage**: Liste paginée des utilisateurs (pagination infinie)
- **Recherche**: Filtre par nom, email, rôle
- **Navigation**: Tap sur une fiche → UserDetailScreen
- **Permissions**: Affichage basé sur le rôle de l'utilisateur

#### UserDetailScreen
- **Vue**: Affichage complet du profil avec:
  - Avatar (avec upload photo possible)
  - Infos générales (nom, email, rôle, église, statut)
  - Infos personnelles (téléphone, profession, groupe, origines)
  
- **Édition**: Mode éditable si:
  - Utilisateur regarde son propre profil
  - Utilisateur est pasteur (peut éditer les membres de son église)
  
- **Actions**:
  - Upload photo de profil
  - Éditer informations personnelles
  - Sauvegarder les modifications

#### MyProfileScreen
- Alias pour `UserDetailScreen(userId: currentUser.id)`
- Accès rapide au profil personnel depuis la navigation

### 3. **Entités et Modèles**

#### UserEntity
```dart
class UserEntity {
  final int id;
  final String nom;
  final String email;
  final String role;
  final int? churchId;
  final String? churchNom;
  final String? photoUrl;
  final String? telephone;
  final bool actif;
  final bool estDeService;
  final String? groupe;
  final String? profession;
  final String? originaireDe;
  
  String get roleLabel  // Labels lisibles en français
}
```

#### UserModel
Gère la sérialisation/désérialisation JSON depuis l'API Laravel:
```dart
factory UserModel.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
```

## 🔌 Intégration Backend

Les endpoints API utilisés:

```
GET    /api/v1/users              - Liste paginée (pasteur/secrétaire)
GET    /api/v1/users/{id}         - Détails utilisateur
PUT    /api/v1/users/{id}         - Mettre à jour profil
POST   /api/v1/users/{id}/photo   - Upload photo
```

**Permissions d'accès** (côté backend):
```
GET /api/v1/users
  └─ Requiert: role:pasteur,secretaire
  └─ Retourne: membres de l'église de l'utilisateur

GET /api/v1/users/{id}
  └─ Accès: tout utilisateur authentifié (sauf admin)
  └─ Sécurité: vérification d'appartenance à la même église

PUT /api/v1/users/{id}
  └─ Accès: admin, pasteur, ou l'utilisateur lui-même
  
POST /api/v1/users/{id}/photo
  └─ Accès: admin, pasteur, secrétaire, ou l'utilisateur lui-même
```

## ✨ Fonctionnalités

### Liste des utilisateurs
- ✅ Affichage paginer (50 éléments par page)
- ✅ Recherche en temps réel (nom, email, rôle)
- ✅ Rafraîchissement via pull-to-refresh
- ✅ Indicateur de chargement
- ✅ Message "Aucun utilisateur" vide
- ✅ Shimmer loading

### Détails utilisateur
- ✅ Affichage complet des infos
- ✅ Upload photo depuis galerie
- ✅ Édition du profil (conditionnelle selon permissions)
- ✅ Validation des champs
- ✅ Messages d'erreur/succès
- ✅ Indicateurs d'état (actif/inactif, en service)

### Permissions
- ✅ Affichage basé sur le rôle
- ✅ Édition conditionnelle (propre profil ou pasteur)
- ✅ Upload photo contrôlé
- ✅ Filtrage des données côté frontend

## 🎨 UI/UX

### Cohérence visuelle
- ✅ Même design que les autres modules (signatures, rapports, anciens)
- ✅ Utilisation des couleurs du thème (`AppColors`)
- ✅ Police Google Fonts (Poppins)
- ✅ Espacements et radius cohérents (12px)

### Composants réutilisés
- ✅ `AppShimmerBox` pour le loading
- ✅ `AppColors` pour les couleurs
- ✅ `InputDecoration` standardisée
- ✅ Écrans de base (AppBar, Scaffold)

## 🧪 Tests Recommandés

### Scénarios de test
1. **Pasteur** voit liste complet de ses membres ✓
2. **Ancien** voit son profil ✓
3. **Paroissien** voit son profil ✓
4. **Upload photo** depuis galerie ✓
5. **Édition profil** - seul propriétaire ou pasteur ✓
6. **Recherche** filtre correctement ✓
7. **Pagination** infinie charge plus d'éléments ✓
8. **Pull-to-refresh** rafraîchit la liste ✓
9. **Offline** - gère les erreurs réseau ✓

## 📱 Points d'intégration

### Routes recommandées
```dart
// Ajouter à votre GoRouter configuration:
GoRoute(
  path: '/users',
  builder: (context, state) => const UsersScreen(),
),
GoRoute(
  path: '/users/:userId',
  builder: (context, state) {
    final userId = int.parse(state.pathParameters['userId']!);
    return UserDetailScreen(userId: userId);
  },
),
GoRoute(
  path: '/profile',
  builder: (context, state) => const MyProfileScreen(),
),
```

### Intégration Menu Principal
```dart
// Ajouter dans le menu ou navigation:
if (userRole == 'pasteur') {
  NavItem(
    icon: Icons.people_rounded,
    label: 'Utilisateurs',
    route: '/users',
  );
}
```

## 🔒 Sécurité

- ✅ Vérification du rôle avant d'afficher les actions
- ✅ Vérification d'appartenance à l'église
- ✅ Tokens Sanctum gérés par `DioClient`
- ✅ Pas de données sensibles en logs
- ✅ Validation des entrées utilisateur

## 📝 Notes

- Le module n'affiche JAMAIS les administrateurs
- Les rôles sont toujours vérifiés côté backend
- Les filtres côté frontend sont pour l'UX uniquement
- Les photos sont uploadées via Cloudinary (backend)
- Le formulaire d'édition est simple (pas de validation complexe)

## ✅ Statut

**Module complètement implémenté et prêt à l'emploi!**

Tout compile sans erreurs et suit le même pattern que les autres modules (signatures, rapports, anciens).

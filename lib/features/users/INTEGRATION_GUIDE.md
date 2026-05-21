# Guide d'Intégration Module Utilisateurs

## 📱 Architecture Respectée

✅ **Clean Architecture + Feature-Based** 
- ✅ `/data/models/` - Sérialisation JSON
- ✅ `/domain/entities/` - Modèles métier
- ✅ `/presentation/providers/` - État (Riverpod StateNotifier)
- ✅ `/presentation/screens/` - UI

✅ **Validation Backend Uniquement**
- ✅ Frontend: juste récupération + affichage des erreurs
- ✅ Backend: toute validation métier (email, téléphone, etc.)

✅ **Gestion des Images**
- ✅ Upload via `MultipartFile` (Dio FormData)
- ✅ Cloudinary gère le stockage (retourne URL)
- ✅ Frontend affiche NetworkImage depuis URL

## 🔌 Points d'Intégration dans Votre App

### 1. Ajouter les Routes GoRouter

```dart
// Ajouter dans votre go_router configuration:
GoRoute(
  path: '/users',
  builder: (context, state) => const UsersScreen(),
  // Optionnel: guards pour pasteur/secrétaire seulement
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

### 2. Ajouter au Menu Principal

```dart
// Dans votre navigation principale:
if (currentUser?.role == 'pasteur' || currentUser?.role == 'secretaire') {
  NavItem(
    icon: Icons.people_rounded,
    label: 'Utilisateurs',
    route: '/users',
  );
}

// Menu utilisateur:
NavItem(
  icon: Icons.person_rounded,
  label: 'Mon Profil',
  route: '/profile',
),
```

### 3. Providers à Utiliser

```dart
// Liste paginée des utilisateurs:
final usersState = ref.watch(usersListProvider);
ref.read(usersListProvider.notifier).search(query);
ref.read(usersListProvider.notifier).loadMore();
ref.read(usersListProvider.notifier).refresh();

// Détail utilisateur:
final userState = ref.watch(userDetailProvider);
ref.read(userDetailProvider.notifier).loadUser(userId);
ref.read(userDetailProvider.notifier).updateUser(userId, data);
ref.read(userDetailProvider.notifier).uploadPhoto(userId, filePath);
```

## 🎯 Endpoints Utilisés

| Endpoint | Méthode | Rôles | Description |
|----------|---------|-------|-------------|
| `/api/v1/users` | GET | pasteur, secretaire | Liste des membres de l'église |
| `/api/v1/users/{id}` | GET | tous (sauf admin) | Détails d'un utilisateur |
| `/api/v1/users/{id}` | PUT | admin, pasteur, ou soi-même | Mettre à jour le profil |
| `/api/v1/users/{id}/photo` | POST | admin, pasteur, secrétaire, ou soi-même | Upload photo de profil |

## 🔐 Contrôle d'Accès Frontend

```dart
// Auto-gérés dans UserDetailScreen:
final canEdit = currentUser?.id == userId ||
                currentUser?.role == 'administrateur' ||
                currentUser?.role == 'pasteur';

if (canEdit) {
  // Afficher bouton éditer
  // Afficher button upload photo
}
```

## 📊 État et Données

### UsersListProvider
```dart
final state = ref.watch(usersListProvider);
state.users              // List<UserEntity>
state.filtered           // Résultats de recherche
state.isLoading          // bool
state.hasMore            // bool (pagination)
state.page               // int (page actuelle)
state.error              // String? (message d'erreur)
state.searchQuery        // String (requête de recherche)
```

### UserDetailProvider
```dart
final state = ref.watch(userDetailProvider);
state.user               // UserEntity?
state.isLoading          // bool (chargement initial)
state.isUpdating         // bool (mise à jour en cours)
state.isUploadingPhoto   // bool (upload en cours)
state.error              // String? (message d'erreur)
state.success            // String? (message de succès)
```

## 🎨 UI Components

### UsersScreen
- Liste paginée infinie
- SearchBar en haut
- Tap sur fiche → UserDetailScreen
- Pull-to-refresh

### UserDetailScreen
- Avatar clickable (upload photo)
- Vue de tous les champs
- Mode édition (si permissions)
- Formulaire simple sans validation complexe
- Messages d'erreur/succès

### MyProfileScreen
- Affiche le UserDetailScreen du profil actuel
- Pas d'identifiant à passer (utilise currentUser)

## ✅ Flux d'Utilisation

### Voir la liste des utilisateurs (Pasteur)
1. Tap "Utilisateurs" → UsersScreen
2. Voit la liste de son église
3. Tap sur un utilisateur → UserDetailScreen

### Voir mon profil
1. Tap "Mon Profil" → MyProfileScreen
2. Affiche UserDetailScreen avec son ID
3. Peut éditer/upload photo

### Éditer le profil d'un member (Pasteur)
1. UsersScreen → UserDetailScreen d'un member
2. Tap "Éditer"
3. Modifie les champs (validation backend)
4. Tap "Enregistrer"
5. Backend valide → SnackBar succès/erreur

### Upload photo
1. UserDetailScreen (mode édition)
2. Tap sur avatar
3. Choisir photo galerie
4. Upload vers Cloudinary
5. State met à jour photoUrl localement
6. Image réaffichée

## 🐛 Debugging

### Erreurs Possibles

**"Utilisateur non trouvé"**
- Backend retourne 404
- Vérifier que l'ID existe et est accessible

**"Vous n'avez pas accès à ce membre"**
- Utilisateur pas dans la même église
- Ou rôle insuffisant (pasteur/secrétaire requis)

**"Photo non uploadée"**
- Fichier trop gros (max 5MB backend)
- Format invalide (pas une image)
- Problème réseau

## 📝 Notes Importantes

1. **Validation**: TOUT au backend, frontend juste affiche les erreurs
2. **Images**: Via Cloudinary, frontend reçoit URL à afficher
3. **Permissions**: Vérifiées backend, frontend affiche UI conditionnelle
4. **Offline**: DioClient gère les erreurs réseau
5. **Pagination**: Infinie, charge 50 items par page
6. **Search**: Frontend filtre localement (pas requête backend)

## ✨ Cas d'Usage

### Paroissien
- ✅ Voit son profil
- ✅ Peut éditer son profil  
- ✅ Peut upload sa photo
- ❌ Ne voit pas la liste des autres

### Ancien
- ✅ Voit son profil
- ✅ Peut éditer son profil
- ✅ Peut upload sa photo
- ❌ Ne voit pas la liste des autres

### Secrétaire/Trésorier
- ✅ Voit son profil
- ✅ Peut éditer son profil
- ✅ Peut upload sa photo
- ✅ Voit la liste de l'église
- ✅ Peut voir détails des membres
- ❌ Ne peut pas éditer les autres

### Pasteur
- ✅ Voit son profil
- ✅ Peut éditer son profil
- ✅ Peut upload sa photo
- ✅ Voit la liste de l'église
- ✅ Peut voir détails des membres
- ✅ **Peut éditer les profils de son église**
- ✅ **Peut upload photos des membres**

### Administrateur
- ❌ **Complètement bloqué** (application web séparée)

## 🚀 Déploiement

Le module est **prêt à l'emploi**:
- ✅ Zéro erreur de compilation
- ✅ Respecte votre architecture clean
- ✅ Pas de validation frontend inutile
- ✅ Images gérées via Cloudinary
- ✅ Permissions au backend

Just integrate the routes and you're good to go! 🎉

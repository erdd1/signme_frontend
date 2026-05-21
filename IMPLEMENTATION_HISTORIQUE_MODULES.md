# 📋 IMPLÉMENTATION - Historique Personnel vs Historique Signatures

**Date**: 20 mai 2026  
**Status**: Frontend 100% créé, Backend à compléter

---

## 🎯 CE QUI A ÉTÉ CRÉÉ (Frontend - Flutter)

### Structure créée:
```
lib/features/historique_personnel/
├── domain/entities/
│   ├── historique_personnel_entity.dart          ✅ Entity pour signatures à distance
│   └── historique_signatures_entity.dart         ✅ Entity pour signatures présentiel
├── data/models/
│   ├── historique_personnel_model.dart           ✅ JSON serialization (distance)
│   └── historique_signatures_model.dart          ✅ JSON serialization (présentiel)
├── presentation/
│   ├── providers/
│   │   ├── historique_personnel_provider.dart    ✅ Riverpod provider (distance)
│   │   └── historique_signatures_provider.dart   ✅ Riverpod provider (présentiel)
│   └── screens/
│       ├── historique_personnel_screen.dart      ✅ UI pour "Mes signatures à distance"
│       └── historique_signatures_screen.dart     ✅ UI pour "Traçabilité des signatures"
```

### 2 Modules différents implémentés:

#### 1. **Historique Personnel**
- **Pour**: Tous les utilisateurs (users, anciens, pasteurs)
- **Affiche**: UNIQUEMENT les signatures à distance de l'utilisateur
- **Data**: userId, month, status, amount, paymentMethod, createdAt
- **Filtres**: Année, statut (completed/pending/failed)
- **UI**: Carte avec montant, méthode paiement, date

#### 2. **Historique Signatures**
- **Pour**: Anciens/Pasteurs uniquement
- **Affiche**: Les signatures en présentiel EFFECTUÉES par l'utilisateur
- **Data**: nomParoissien, month, status, churchName, createdAt, location
- **Filtres**: Année, statut, recherche par nom du paroissien
- **UI**: Liste avec traçabilité complète, détails des paroissiens

---

## 🔴 MANQUE CÔTÉ BACKEND - Endpoints à créer

### 1. Endpoint: Historique Personnel (distance)

```php
// Route: GET /api/v1/signatures/historique-personnel
// Middleware: auth:sanctum, role.not:administrateur
// Retourne: UNIQUEMENT les signatures à distance de l'utilisateur connecté

Route::get('/signatures/historique-personnel', [SignatureController::class, 'getHistoriquePersonnel']);
```

**Paramètres query:**
- `year` (int, optional) - Année (défaut: année courante)
- `month` (string, optional) - Format YYYY-MM
- `status` (string, optional) - 'completed' | 'pending' | 'failed'
- `per_page` (int, optional) - Pagination, défaut 20

**Response:**
```json
{
  "data": [
    {
      "id": "sig_123",
      "userId": 5,
      "nomParoissien": "Jean Nkuo",
      "month": "2026-01",
      "year": 2026,
      "status": "completed",
      "amount": 1000,
      "fees": 50,
      "signatureType": "distance",
      "paymentMethod": "ORANGE MONEY",
      "paymentPhoneNumber": "699000000",
      "created_at": "2026-01-15T10:30:00Z",
      "completed_at": "2026-01-15T10:35:00Z",
      "errorMessage": null
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 15,
    "per_page": 20
  }
}
```

**À ajouter dans SignatureService:**
```php
public function getHistoriquePersonnel(User $authUser, array $filters = [], int $perPage = 20): LengthAwarePaginator
{
    $query = Signature::where('userId', $authUser->id)
                      ->where('signatureType', 'distance')
                      ->where('status', 'completed')
                      ->orderBy('created_at', 'desc');

    if (!empty($filters['month'])) {
        $query->where('month', $filters['month']);
    }
    if (!empty($filters['year'])) {
        $query->where('year', $filters['year']);
    }
    if (!empty($filters['status'])) {
        $query->where('status', $filters['status']);
    }

    return $query->paginate($perPage);
}
```

---

### 2. Endpoint: Historique Signatures (présentiel)

```php
// Route: GET /api/v1/signatures/historique-signatures
// Middleware: auth:sanctum, role:ancien,pasteur
// Retourne: Les signatures en présentiel EFFECTUÉES par l'utilisateur connecté

Route::get('/signatures/historique-signatures', [SignatureController::class, 'getHistoriqueSignatures'])
     ->middleware(['role:ancien,pasteur']);
```

**Paramètres query:**
- `year` (int, optional) - Année (défaut: année courante)
- `month` (string, optional) - Format YYYY-MM
- `status` (string, optional) - 'completed' | 'pending' | 'failed'
- `per_page` (int, optional) - Pagination, défaut 20

**Response:**
```json
{
  "data": [
    {
      "id": "sig_456",
      "userId": 7,
      "nomParoissien": "Marie Dupont",
      "emailParoissien": "marie@church.cm",
      "ancienId": 5,
      "nomAncien": "Jean Nkuo",
      "month": "2026-02",
      "year": 2026,
      "status": "completed",
      "amount": null,
      "fees": null,
      "signatureType": "presentiel",
      "location": "Lieu de culte",
      "churchId": 1,
      "churchName": "Église Évangélique Emmanuel",
      "created_at": "2026-02-10T14:20:00Z",
      "completed_at": "2026-02-10T14:21:00Z",
      "notes": "Signature en présence du pasteur"
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 42,
    "per_page": 20
  }
}
```

**À ajouter dans SignatureService:**
```php
public function getHistoriqueSignatures(User $authUser, array $filters = [], int $perPage = 20): LengthAwarePaginator
{
    // Pour les anciens: voir les signatures qu'ILS ont effectuées
    // Pour les pasteurs: voir les signatures de leur église

    $query = Signature::where('signatureType', 'presentiel')
                      ->where('status', 'completed')
                      ->orderBy('created_at', 'desc');

    if ($authUser->hasRole('ancien')) {
        // Ancien voit UNIQUEMENT les signatures qu'il a effectuées
        $query->where('ancienId', $authUser->id);
    } elseif ($authUser->hasRole('pasteur')) {
        // Pasteur voit TOUTES les signatures présentiel de son église
        $query->where('churchId', $authUser->churchId);
    }

    if (!empty($filters['month'])) {
        $query->where('month', $filters['month']);
    }
    if (!empty($filters['year'])) {
        $query->where('year', $filters['year']);
    }
    if (!empty($filters['status'])) {
        $query->where('status', $filters['status']);
    }

    return $query->paginate($perPage);
}
```

---

## ✅ TO-DO LIST - Backend

- [ ] Ajouter méthode `getHistoriquePersonnel()` à SignatureService
- [ ] Ajouter méthode `getHistoriqueSignatures()` à SignatureService
- [ ] Ajouter route GET `/api/v1/signatures/historique-personnel` dans routes/api.php
- [ ] Ajouter route GET `/api/v1/signatures/historique-signatures` dans routes/api.php
- [ ] Tester les endpoints avec Postman
- [ ] Ajouter les contrôleurs manquants si nécessaire

---

## ✅ TO-DO LIST - Frontend

- [ ] Générer le code JSON avec build_runner:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- [ ] Ajouter routes dans `app_router.dart`:
  ```dart
  GoRoute(
    path: 'historique-personnel',
    builder: (context, state) => const HistoriquePersonnelScreen(),
  ),
  GoRoute(
    path: 'historique-signatures',
    builder: (context, state) => const HistoriqueSignaturesScreen(),
  ),
  ```
- [ ] Ajouter menu items dans le drawer:
  ```dart
  ListTile(
    title: const Text('Mon Historique'),
    onTap: () => context.push('/historique-personnel'),
  ),
  // Si ancien/pasteur:
  ListTile(
    title: const Text('Historique Signatures'),
    onTap: () => context.push('/historique-signatures'),
  ),
  ```
- [ ] Tester les deux screens
- [ ] Vérifier les permissions (anciens/pasteurs pour signatures)

---

## 📝 DIFFÉRENCES CLÉS

| Aspect | Historique Personnel | Historique Signatures |
|--------|-------------------|----------------------|
| **Visible pour** | Tous les users | Anciens/Pasteurs only |
| **Affiche** | Signatures à distance | Signatures en présentiel |
| **Par qui?** | De l'utilisateur | Effectuées par l'utilisateur |
| **Type** | 'distance' | 'presentiel' |
| **Infos clés** | amount, paymentMethod | nomParoissien, churchName |
| **Filtres** | Année, statut | Année, statut, recherche |
| **Traçabilité** | Paiements personnels | Signatures effectuées |
| **Route** | `/historique-personnel` | `/historique-signatures` |

---

## 🔗 INTÉGRATION

### Routes à ajouter:

```dart
// Dans app_router.dart
GoRoute(
  path: 'historique-personnel',
  name: 'historiquePersonnel',
  builder: (context, state) => const HistoriquePersonnelScreen(),
),
GoRoute(
  path: 'historique-signatures',
  name: 'historiqueSignatures',
  builder: (context, state) => const HistoriqueSignaturesScreen(),
  // Middleware: only for role:ancien,pasteur
),
```

### Menu integration:

```dart
// Dans le drawer (app_drawer.dart ou role_menu_drawer.dart)

// Pour tous les users:
ListTile(
  leading: const Icon(Icons.history),
  title: const Text('Mon Historique'),
  onTap: () => context.push('/historique-personnel'),
),

// Pour anciens/pasteurs uniquement:
if (userRole == 'ancien' || userRole == 'pasteur')
  ListTile(
    leading: const Icon(Icons.assignment_turned_in),
    title: const Text('Historique Signatures'),
    onTap: () => context.push('/historique-signatures'),
  ),
```

---

## 📊 ENDPOINTS RÉSUMÉ

```
Frontend ← → Backend

GET /api/v1/signatures/historique-personnel
├─ Retourne: Signatures à distance de l'user
├─ Visible: Tous
├─ Middleware: auth:sanctum, role.not:admin
└─ Response: List[Signature] avec amount, paymentMethod

GET /api/v1/signatures/historique-signatures
├─ Retourne: Signatures présentiel effectuées par l'user
├─ Visible: Anciens/Pasteurs
├─ Middleware: auth:sanctum, role:ancien,pasteur
└─ Response: List[Signature] avec nomParoissien, location
```

---

## 🚀 PROCHAINES ÉTAPES

1. **Backend** (Laravel):
   - Implémenter les 2 méthodes dans SignatureService
   - Ajouter les 2 routes
   - Tester avec Postman

2. **Frontend** (Flutter):
   - Générer le code JSON
   - Ajouter les routes
   - Tester les 2 screens

3. **Intégration**:
   - Ajouter au drawer
   - Tester les permissions
   - Vérifier les filtres

---

**Créé**: 20 mai 2026  
**Status**: Frontend 100%, Backend à implémenter  
**Confiance**: 100%

/// Rôles assignables à la création (aligné sur [UserService] Laravel).
abstract final class UserCreatableRoles {
  static const pasteur = ['secretaire', 'tresorier', 'ancien', 'paroissien'];
  static const secretaire = ['ancien', 'paroissien', 'tresorier'];

  static List<String> forCreator(String role) {
    switch (role) {
      case 'pasteur':
        return pasteur;
      case 'secretaire':
        return secretaire;
      default:
        return [];
    }
  }

  static String label(String role) {
    const map = {
      'pasteur': 'Pasteur',
      'secretaire': 'Secrétaire',
      'tresorier': 'Trésorier',
      'ancien': 'Ancien',
      'paroissien': 'Paroissien',
    };
    return map[role] ?? role;
  }
}

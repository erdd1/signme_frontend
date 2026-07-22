/// Toutes les chaînes de caractères de l'application EEC SignCard
abstract final class AppStrings {

  // ── App ─────────────────────────────────────────────────────────────────
  static const appName     = 'SignMe';
  static const appTagline  = 'Application de signature de documents';



  // ── Auth ─────────────────────────────────────────────────────────────────
  static const welcome         = 'Bienvenue';
  static const welcome2        = 'Bonjour,';
  static const loginSubtitle   = 'Bienvenu, veuillez vous connecter pour continuer';
  static const email           = 'Adresse Email';
  static const emailHint       = 'user@example.com';
  static const password        = 'Mot de passe';
  static const passwordHint    = 'Entrez votre mot de passe';
  static const forgotPassword  = 'Mot de passe oublié?';
  static const loginBtn        = 'Se connecter';
  static const rememberMe      = 'Se souvenir de moi';
  static const sessionExpired  =
      'Votre session a expiré. Veuillez vous reconnecter.';
  static const logout          = 'Déconnexion';
  static const resetPassword   = 'Réinitialiser\nle mot de passe';
  static const resetSubtitle   = 'Entrez votre email pour recevoir un code permettant la réinitialisation du mot de passe.';
  static const sendResetLink   = 'ENVOYER UN CODE';
  static const backToLogin     = 'RETOUR À LA CONNEXION';

  // ── Validation ────────────────────────────────────────────────────────────
  static const requiredField = 'Ce champ est obligatoire';
  static const invalidEmail  = 'Email invalide';
  static const minPassword   = 'Minimum 6 caractères';

  // ── Navigation ───────────────────────────────────────────────────────────
  static const home       = 'Accueil';
  static const finances   = 'Finances';
  static const historique = 'Historique';
  static const maCarte    = 'Ma Carte';
  static const profile    = 'Profil';

  // ── Home ─────────────────────────────────────────────────────────────────
  static const newsFeed        = 'Actualités';
  static const noPublication   = 'Aucune publication disponible';

  // ── Finances ─────────────────────────────────────────────────────────────
  static const financesTitle   = 'Finances';
  static const rapportAnnuel   = 'Rapport Annuel';
  static const comparaison     = 'Comparaison';
  static const resumeAnnuel    = 'RÉSUMÉ ANNUEL';
  static const moisCol         = 'Mois';
  static const signatures      = 'Signatures';
  static const montantFcfa     = 'Montant (F)';
  static const signaturesEnregistrees = 'signatures enregistrées';
  static const aucuneSignature = 'Aucune signature pour';
  static const detailsMois     = 'Voir le détail par mois';
  static const accessDenied    = 'Accès restreint';
  static const accessDeniedSub = 'Ce module est réservé aux responsables financiers.';

  // ── Historique ────────────────────────────────────────────────────────────
  static const historiqueTitle = 'Historique';
  static const noHistorique    = 'Aucune signature enregistrée';
  static const tousMembres     = 'Tous les membres';
  static const monHistorique   = 'Mon historique';
  static const presentiel      = 'Présentiel';
  static const distance        = 'Distance';

  // ── Ma Carte ─────────────────────────────────────────────────────────────
  static const maCarteTitle    = 'Ma Carte Sainte Cène';
  static const maCarteSainte   = 'Carte Sainte Cène';
  static const signaturePending= 'Vous avez une signature en attente';
  static const signatureOk     = 'Statut de vos signatures';
  static const signerBtn       = 'Signer';
  static const offrandes       = 'SIGNATURES PAR MOIS';
  static const noSign          = '–';

  // ── Signer ────────────────────────────────────────────────────────────────
  static const signerTitle      = 'Nouvelle Signature';
  static const signerDistTitle  = 'Signature à Distance';
  static const signerPresTitle  = 'Signature Présentielle';
  static const confirmerPaiement= 'CONFIRMER ET PAYER';
  static const confirmerPres    = 'ENREGISTRER LA SIGNATURE';
  static const pushSent         = 'Une notification de paiement a été envoyée sur votre téléphone. Validez sur votre application Mobile Money.';
  static const orangeMoney      = 'ORANGE MONEY';
  static const mtnMoney         = 'MTN MOBILE MONEY';
  static const selectMember     = 'Sélectionner le membre';
  static const searchMember     = 'Rechercher un paroissien…';

  // ── Profil ────────────────────────────────────────────────────────────────
  static const editProfile      = 'Modifier le profil';
  static const changePassword   = 'Changer le mot de passe';
  static const changePasswordHint =
      'Pour votre sécurité, vous serez déconnecté après la modification.';
  static const currentPassword  = 'Mot de passe actuel';
  static const newPassword      = 'Nouveau mot de passe';
  static const newPasswordHint  = 'Minimum 8 caractères';
  static const confirmNewPassword = 'Confirmer le nouveau mot de passe';
  static const confirmPasswordHint = 'Répétez le nouveau mot de passe';
  static const savePassword     = 'Enregistrer le mot de passe';
  static const minPassword8     = 'Minimum 8 caractères';
  static const newPasswordMustDiffer =
      'Le nouveau mot de passe doit être différent';
  static const passwordMismatch = 'Les mots de passe ne correspondent pas';
  static const appVersion       = 'Version';

  // ── Mois ─────────────────────────────────────────────────────────────────
  static const List<String> moisFull = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  static const List<String> moisShort = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
    'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
  ];

  // ── Labels rôles ─────────────────────────────────────────────────────────
  static const Map<String, String> roleLabels = {
    'pasteur':        'PASTEUR',
    'secretaire':     'SECRÉTAIRE',
    'tresorier':      'TRÉSORIER',
    'ancien':         'ANCIEN',
    'paroissien':     'PAROISSIEN',
  };

  // ── Régions du Cameroun (originaireDe) ──────────────────────────────────
  // Doit rester identique à App\Models\User::REGIONS côté backend.
  static const List<String> regionsCameroun = [
    'Adamaoua',
    'Centre',
    'Est',
    'Extrême-Nord',
    'Littoral',
    'Nord',
    'Nord-Ouest',
    'Ouest',
    'Sud',
    'Sud-Ouest',
  ];
}

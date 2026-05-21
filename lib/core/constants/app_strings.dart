/// Toutes les chaînes de caractères de l'application EEC SignCard
abstract final class AppStrings {

  // ── App ─────────────────────────────────────────────────────────────────
  static const appName     = 'EEC SIGNCARD';
  static const appTagline  = 'Système de signature — Église Évangélique du Cameroun';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const welcome         = 'Bienvenue';
  static const welcome2        = 'Bonjour,';
  static const loginSubtitle   = 'Connectez-vous à votre espace EEC SignCard';
  static const email           = 'Adresse email';
  static const emailHint       = 'votre@email.com';
  static const password        = 'Mot de passe';
  static const passwordHint    = '••••••••';
  static const forgotPassword  = 'Mot de passe oublié ?';
  static const loginBtn        = 'SE CONNECTER';
  static const logout          = 'Déconnexion';
  static const resetPassword   = 'Réinitialiser\nle mot de passe';
  static const resetSubtitle   = 'Entrez votre email pour recevoir un lien de réinitialisation.';
  static const sendResetLink   = 'ENVOYER LE LIEN';
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
    'administrateur': 'ADMINISTRATEUR',
    'pasteur':        'PASTEUR',
    'secretaire':     'SECRÉTAIRE',
    'tresorier':      'TRÉSORIER',
    'ancien':         'ANCIEN',
    'paroissien':     'PAROISSIEN',
  };
}

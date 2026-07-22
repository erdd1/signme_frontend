/// Statuts de filtrage pour l'écran "Gérer les événements" — constantes
/// partagées entre le provider (presentation) et la synchronisation de
/// préchargement (SyncService), pour éviter de dupliquer ces deux valeurs.

/// L'onglet "Actifs" inclut aussi les événements PLANIFIE (programmés mais
/// pas encore publiés/visibles de tous), pour que le pasteur/secrétaire
/// puisse les suivre et les annuler avant publication.
const String kEvenementsGestionActifs = 'actif,planifie';

/// Filtre statut de l'onglet "Archivés" : regroupe TERMINE (pas encore
/// quitté le fil d'actualité, en attente d'archivage auto 3 jours après) et
/// ARCHIVE (déjà archivé), car du point de vue gestion les deux sont "clos".
const String kEvenementsGestionArchives = 'termine,archive';

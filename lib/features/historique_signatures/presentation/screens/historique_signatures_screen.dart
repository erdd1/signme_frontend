import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../historique_signatures/presentation/providers/historique_signatures_provider.dart';

/// Historique Signatures Screen
/// Affiche UNIQUEMENT les signatures en présentiel effectuées PAR l'utilisateur connecté (ancien/pasteur)
/// C'est pour la traçabilité des signatures qu'on a effectuées
/// Visible UNIQUEMENT pour les anciens/pasteurs
class HistoriqueSignaturesScreen extends ConsumerStatefulWidget {
  const HistoriqueSignaturesScreen({super.key});

  @override
  ConsumerState<HistoriqueSignaturesScreen> createState() =>
      _HistoriqueSignaturesScreenState();
}

class _HistoriqueSignaturesScreenState extends ConsumerState<HistoriqueSignaturesScreen> {
  late String _selectedYear = DateTime.now().year.toString();
  String _searchQuery = '';

  // ✅ FIX: Créer les filters HORS du build pour éviter de relancer le provider à chaque setState
  late final Map<String, dynamic> _filters = {
    'year': _selectedYear,  // ✅ FIX: Keep as String for HTTP query parameters
    'status': 'completed',
    'per_page': 20,
  };

  @override
  Widget build(BuildContext context) {
    // ✅ Mettre à jour les filters seulement si l'année a changé (not on search)
    _filters['year'] = _selectedYear;  // ✅ Keep as String

    final historiqueAsync = ref.watch(historiqueSignaturesProvider(_filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique Signatures'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ─── Barre de recherche ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par nom du paroissien...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // ─── Filtres ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              children: [
                // Filtre par année
                DropdownButton<String>(
                  value: _selectedYear,
                  isExpanded: true,
                  items: List.generate(5, (i) {
                    final year = (DateTime.now().year - 2 + i).toString();
                    return DropdownMenuItem(
                      value: year,
                      child: Text('Année $year'),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedYear = value);
                    }
                  },
                ),
                const SizedBox(height: 0), // Pas de filtre de statut - affiche uniquement complétées
              ],
            ),
          ),
          // ─── Liste ──────────────────────────────────────────────────────
          Expanded(
            child: historiqueAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Erreur: $error'),
                  ],
                ),
              ),
              data: (historique) {
                // Filtrer par recherche si nécessaire
                final filtered = _searchQuery.isEmpty
                    ? historique
                    : historique
                        .where((s) => s.nomParoissien
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Aucune signature trouvée'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final sig = filtered[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── En-tête avec statut et nom ──────────────────────────
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sig.nomParoissien,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        sig.churchName,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (sig.amount != null)
                                  Text(
                                    '${sig.amount} FCFA',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.teal,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // ─── Détails ────────────────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailItem('Statut', sig.statusFr),
                                      _buildDetailItem('Date', sig.formattedDate),
                                      _buildDetailItem('Type', 'Présentiel'),
                                      if (sig.fees != null)
                                        _buildDetailItem('Frais', '${sig.fees} FCFA'),
                                      if (sig.location != null)
                                        _buildDetailItem('Lieu', sig.location ?? ''),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // ─── Bouton détails ─────────────────────────────────────
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _showDetail(context, sig),
                                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                                label: const Text('Détails'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, dynamic sig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Signature - ${sig.nomParoissien}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Paroissien:', sig.nomParoissien),
              _detailRow('Email:', sig.emailParoissien, fontSize: 11),
              _detailRow('Mois:', sig.month),
              _detailRow('Statut:', sig.statusFr),
              _detailRow('Église:', sig.churchName),
              if (sig.location != null) _detailRow('Lieu:', sig.location),
              _detailRow('Date:', sig.formattedDate, fontSize: 11),
              if (sig.notes != null)
                _detailRow('Notes:', sig.notes, fontSize: 11),
              if (sig.isFailed)
                _detailRow('Erreur:', 'Signature échouée', color: Colors.red),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String? value, {
    Color? color,
    double fontSize = 12,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(fontSize: fontSize, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

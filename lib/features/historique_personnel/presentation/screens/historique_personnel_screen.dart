import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/historique_personnel_provider.dart';

/// Historique Personnel Screen
/// Affiche UNIQUEMENT les signatures à distance de l'utilisateur connecté
/// C'est l'historique personnel de mes paiements/signatures à distance
class HistoriquePersonnelScreen extends ConsumerStatefulWidget {
  const HistoriquePersonnelScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoriquePersonnelScreen> createState() =>
      _HistoriquePersonnelScreenState();
}

class _HistoriquePersonnelScreenState extends ConsumerState<HistoriquePersonnelScreen> {
  late String _selectedYear = DateTime.now().year.toString();

  // ✅ FIX: Créer les filters HORS du build pour éviter de relancer le provider à chaque setState
  late final Map<String, dynamic> _filters = {
    'year': _selectedYear,  // ✅ FIX: Keep as String for HTTP query parameters
    'status': 'completed',
    'per_page': 20,
  };

  @override
  Widget build(BuildContext context) {
    // ✅ Mettre à jour les filters seulement si l'année a changé
    _filters['year'] = _selectedYear;  // ✅ Keep as String

    final historiqueAsync = ref.watch(historiquePersonnelProvider(_filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Historique'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ─── Filtres ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Erreur: $error'),
                  ],
                ),
              ),
              data: (historique) {
                if (historique.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('Aucune signature trouvée'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: historique.length,
                  itemBuilder: (context, index) {
                    final sig = historique[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          sig.isCompleted
                              ? Icons.check_circle
                              : sig.isPending
                                  ? Icons.schedule
                                  : Icons.error,
                          color: sig.isCompleted
                              ? Colors.green
                              : sig.isPending
                                  ? Colors.orange
                                  : Colors.red,
                          size: 32,
                        ),
                        title: Text(
                          sig.month,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Statut: ${sig.statusFr}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              sig.formattedDate,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            if (sig.paymentMethod != null)
                              Text(
                                'Paiement: ${sig.paymentMethod}',
                                style: const TextStyle(fontSize: 11),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${sig.amount} FCFA',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (sig.fees != null)
                              Text(
                                'Frais: ${sig.fees}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                          ],
                        ),
                        onTap: () => _showDetail(context, sig),
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
        title: Text('Signature - ${sig.month}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Statut:', sig.statusFr),
            _detailRow('Montant:', '${sig.amount} FCFA'),
            if (sig.fees != null) _detailRow('Frais:', '${sig.fees} FCFA'),
            _detailRow('Type:', sig.signatureType),
            if (sig.paymentMethod != null) _detailRow('Paiement:', sig.paymentMethod),
            _detailRow('Date:', sig.formattedDate),
            if (sig.errorMessage != null)
              _detailRow('Erreur:', sig.errorMessage, color: Colors.red),
          ],
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

  Widget _detailRow(String label, String? value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

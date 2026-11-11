import '../../domain/entities/contribution_entity.dart';

class ContributionModel {
  const ContributionModel({
    required this.uuid,
    required this.montant,
    required this.frais,
    required this.montantTotal,
    required this.statut,
    this.note,
    this.paymentMethod,
    this.paymentOperator,
    this.paymentNumber,
    this.paymentReference,
    this.checkoutUrl,
    this.contributeurId,
    this.contributeurNom,
    this.contributeurGroupeNom,
    this.evenementTitre,
    required this.createdAt,
    this.isTerminal = false,
    this.pollIntervalMs = 3000,
  });

  final String uuid;
  final int montant;
  final int frais;
  final int montantTotal;
  final String statut;
  final String? note;
  final String? paymentMethod;
  final String? paymentOperator;
  final String? paymentNumber;
  final String? paymentReference;
  final String? checkoutUrl;
  final int? contributeurId;
  final String? contributeurNom;
  final String? contributeurGroupeNom;
  final String? evenementTitre;
  final DateTime createdAt;
  final bool isTerminal;
  final int pollIntervalMs;

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    final contributeur = json['contributeur'] as Map<String, dynamic>?;
    final evenement = json['evenement'] as Map<String, dynamic>?;

    return ContributionModel(
      uuid: json['uuid'].toString(),
      montant: _asInt(json['montant']),
      frais: _asInt(json['frais']),
      montantTotal: _asInt(json['montantTotal']),
      statut: (json['statut'] ?? 'pending').toString(),
      note: json['note']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      paymentOperator: json['paymentOperator']?.toString(),
      paymentNumber: json['paymentNumber']?.toString(),
      paymentReference: json['paymentReference']?.toString(),
      checkoutUrl: json['checkoutUrl']?.toString(),
      contributeurId: contributeur?['id'] == null ? null : _asInt(contributeur?['id']),
      contributeurNom: contributeur?['nom']?.toString(),
      contributeurGroupeNom: (contributeur?['groupe'] as Map<String, dynamic>?)?['nom']?.toString(),
      evenementTitre: evenement?['titre']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isTerminal: json['isTerminal'] == true,
      pollIntervalMs: json['pollIntervalMs'] == null ? 3000 : _asInt(json['pollIntervalMs']),
    );
  }

  ContributionEntity toEntity() => ContributionEntity(
        uuid: uuid,
        montant: montant,
        frais: frais,
        montantTotal: montantTotal,
        statut: statut,
        note: note,
        paymentMethod: paymentMethod,
        paymentOperator: paymentOperator,
        paymentNumber: paymentNumber,
        paymentReference: paymentReference,
        checkoutUrl: checkoutUrl,
        contributeurId: contributeurId,
        contributeurNom: contributeurNom,
        contributeurGroupeNom: contributeurGroupeNom,
        evenementTitre: evenementTitre,
        createdAt: createdAt,
        isTerminal: isTerminal,
        pollIntervalMs: pollIntervalMs,
      );
}

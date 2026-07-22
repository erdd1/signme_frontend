/// Statut de signature d'un membre pour un mois donné.
class MemberSignatureStatus {
  const MemberSignatureStatus({required this.status, this.message});

  final String status;
  final String? message;

  bool get isSigned => status == 'signé' || status == 'signe';

  factory MemberSignatureStatus.fromJson(Map<String, dynamic> json) {
    return MemberSignatureStatus(
      status: json['status']?.toString() ?? 'non_signé',
      message: json['message']?.toString(),
    );
  }
}

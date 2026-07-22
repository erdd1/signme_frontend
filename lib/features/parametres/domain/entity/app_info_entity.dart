class AppInfoEntity {
  final String appName;
  final String appVersion;
  final String appBuild;
  final String privacyPolicy;
  final String termsOfService;
  final String supportEmail;

  AppInfoEntity({
    required this.appName,
    required this.appVersion,
    required this.appBuild,
    required this.privacyPolicy,
    required this.termsOfService,
    required this.supportEmail,
  });
}

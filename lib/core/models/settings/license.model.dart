class LicenseModel {
  final String? domain;
  final List<String>? allowedPackages;
  final List<String>? allowedFeatures;

  LicenseModel({
    this.domain,
    this.allowedPackages,
    this.allowedFeatures,
  });

  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    // Local override for testing
    // To test specific packages, you can modify this list directly
    List<String> overridePackages = [
      // 'emp-requests',
      'emp-payroll',
      'emp-evaluation',
      'emp-reports',
      'emp-approval-system',
      // 'fingerprint-sys',
      'cv-hub'
    ];

    return LicenseModel(
      domain: json['domain'],
      allowedPackages: overridePackages, // OVERRIDDEN LOCALLY
      // allowedPackages: json['allowed_packages'] != null ? List<String>.from(json['allowed_packages']) : [],
      allowedFeatures: json['allowed_features'] != null ? List<String>.from(json['allowed_features']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'domain': domain,
      'allowed_packages': allowedPackages,
      'allowed_features': allowedFeatures,
    };
  }
}

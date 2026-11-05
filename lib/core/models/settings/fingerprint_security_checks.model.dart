enum FingerprintCheckLevel {
  mandatory,
  optional,
  disabled;

  bool get isMandatory => this == FingerprintCheckLevel.mandatory;
  bool get isOptional => this == FingerprintCheckLevel.optional;
  bool get isDisabled => this == FingerprintCheckLevel.disabled;
  bool get isEnabled => this != FingerprintCheckLevel.disabled;

  static FingerprintCheckLevel fromValue(dynamic value) {
    if (value == null) return FingerprintCheckLevel.disabled;
    if (value is FingerprintCheckLevel) return value;
    // Only the backend values are accepted: disabled / mandatory / optional. Anything else => disabled.
    switch (value.toString().toLowerCase().trim()) {
      case 'mandatory':
        return FingerprintCheckLevel.mandatory;
      case 'optional':
        return FingerprintCheckLevel.optional;
      default:
        return FingerprintCheckLevel.disabled;
    }
  }

  String toValue() {
    switch (this) {
      case FingerprintCheckLevel.mandatory:
        return 'mandatory';
      case FingerprintCheckLevel.optional:
        return 'optional';
      case FingerprintCheckLevel.disabled:
        return 'disabled';
    }
  }
}

class FingerprintSecurityChecksModel {
  final FingerprintCheckLevel blockFingerprintOnDeveloperMode;
  final FingerprintCheckLevel fingerprintBlockOnRootOrJailbreak;
  final FingerprintCheckLevel fingerprintBlockOnFakeGps;
  final FingerprintCheckLevel fingerprintBlockOnVpn;
  final FingerprintCheckLevel fingerprintVerifyTimeDrift;
  final FingerprintCheckLevel fingerprintVerifyGpsNetworkComparison;
  final FingerprintCheckLevel fingerprintVerifyGpsTimestampOffline;
  final FingerprintCheckLevel fingerprintLivenessChallengesEnabled;
  final FingerprintCheckLevel fingerprintFaceProfileVerificationEnabled;
  final FingerprintCheckLevel fingerprintUploadFaceImageToBackend;
  final FingerprintCheckLevel fingerprintSendNoteReportToApi;
  final FingerprintCheckLevel fpScanSteps;
  final FingerprintCheckLevel branchesDoubleCheck;

  const FingerprintSecurityChecksModel({
    this.blockFingerprintOnDeveloperMode = FingerprintCheckLevel.disabled,
    this.fingerprintBlockOnRootOrJailbreak = FingerprintCheckLevel.disabled,
    this.fingerprintBlockOnFakeGps = FingerprintCheckLevel.disabled,
    this.fingerprintBlockOnVpn = FingerprintCheckLevel.disabled,
    this.fingerprintVerifyTimeDrift = FingerprintCheckLevel.disabled,
    this.fingerprintVerifyGpsNetworkComparison = FingerprintCheckLevel.disabled,
    this.fingerprintVerifyGpsTimestampOffline = FingerprintCheckLevel.disabled,
    this.fingerprintLivenessChallengesEnabled = FingerprintCheckLevel.disabled,
    this.fingerprintFaceProfileVerificationEnabled = FingerprintCheckLevel.disabled,
    this.fingerprintUploadFaceImageToBackend = FingerprintCheckLevel.disabled,
    this.fingerprintSendNoteReportToApi = FingerprintCheckLevel.disabled,
    this.fpScanSteps = FingerprintCheckLevel.disabled,
    this.branchesDoubleCheck = FingerprintCheckLevel.disabled,
  });

  factory FingerprintSecurityChecksModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FingerprintSecurityChecksModel();
    }
    return FingerprintSecurityChecksModel(
      blockFingerprintOnDeveloperMode: FingerprintCheckLevel.fromValue(
        json['block_fingerprint_on_developer_mode'],
      ),
      fingerprintBlockOnRootOrJailbreak: FingerprintCheckLevel.fromValue(
        json['fingerprint_block_on_root_or_jailbreak'],
      ),
      fingerprintBlockOnFakeGps: FingerprintCheckLevel.fromValue(
        json['fingerprint_block_on_fake_gps'],
      ),
      fingerprintBlockOnVpn: FingerprintCheckLevel.fromValue(
        json['fingerprint_block_on_vpn'],
      ),
      fingerprintVerifyTimeDrift: FingerprintCheckLevel.fromValue(
        json['fingerprint_verify_time_drift'],
      ),
      fingerprintVerifyGpsNetworkComparison: FingerprintCheckLevel.fromValue(
        json['fingerprint_verify_gps_network_comparison'],
      ),
      fingerprintVerifyGpsTimestampOffline: FingerprintCheckLevel.fromValue(
        json['fingerprint_verify_gps_timestamp_offline'],
      ),
      fingerprintLivenessChallengesEnabled: FingerprintCheckLevel.fromValue(
        json['fingerprint_liveness_challenges_enabled'],
      ),
      fingerprintFaceProfileVerificationEnabled: FingerprintCheckLevel.fromValue(
        json['fingerprint_face_profile_verification_enabled'],
      ),
      fingerprintUploadFaceImageToBackend: FingerprintCheckLevel.fromValue(
        json['fingerprint_upload_face_image_to_backend'],
      ),
      fingerprintSendNoteReportToApi: FingerprintCheckLevel.fromValue(
        json['fingerprint_send_note_report_to_api'],
      ),
      fpScanSteps: FingerprintCheckLevel.fromValue(
        json['fp_scan_steps'],
      ),
      branchesDoubleCheck: FingerprintCheckLevel.fromValue(json['branchesDoubleCheck']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'block_fingerprint_on_developer_mode': blockFingerprintOnDeveloperMode.toValue(),
      'fingerprint_block_on_root_or_jailbreak': fingerprintBlockOnRootOrJailbreak.toValue(),
      'fingerprint_block_on_fake_gps': fingerprintBlockOnFakeGps.toValue(),
      'fingerprint_block_on_vpn': fingerprintBlockOnVpn.toValue(),
      'fingerprint_verify_time_drift': fingerprintVerifyTimeDrift.toValue(),
      'fingerprint_verify_gps_network_comparison': fingerprintVerifyGpsNetworkComparison.toValue(),
      'fingerprint_verify_gps_timestamp_offline': fingerprintVerifyGpsTimestampOffline.toValue(),
      'fingerprint_liveness_challenges_enabled': fingerprintLivenessChallengesEnabled.toValue(),
      'fingerprint_face_profile_verification_enabled': fingerprintFaceProfileVerificationEnabled.toValue(),
      'fingerprint_upload_face_image_to_backend': fingerprintUploadFaceImageToBackend.toValue(),
      'fingerprint_send_note_report_to_api': fingerprintSendNoteReportToApi.toValue(),
      'fp_scan_steps': fpScanSteps.toValue(),
      'branchesDoubleCheck': branchesDoubleCheck.toValue(),
    };
  }
}

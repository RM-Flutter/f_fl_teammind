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
    final str = value.toString().toLowerCase().trim();
    switch (str) {
      case 'mandatory':
      case 'required':
        return FingerprintCheckLevel.mandatory;
      case 'optional':
        return FingerprintCheckLevel.optional;
      case 'disabled':
      case 'disable':
      case 'none':
        return FingerprintCheckLevel.disabled;
      case 'true':
      case '1':
        return FingerprintCheckLevel.mandatory;
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
  final FingerprintCheckLevel fingerprintFaceChallengeEnabled;
  final FingerprintCheckLevel fingerprintFaceProfileVerificationEnabled;
  final FingerprintCheckLevel fingerprintUploadFaceImageToBackend;
  final FingerprintCheckLevel fingerprintSendNoteReportToApi;
  final FingerprintCheckLevel fpScanSteps;

  const FingerprintSecurityChecksModel({
    this.blockFingerprintOnDeveloperMode = FingerprintCheckLevel.disabled,
    this.fingerprintBlockOnRootOrJailbreak = FingerprintCheckLevel.disabled,
    this.fingerprintBlockOnFakeGps = FingerprintCheckLevel.disabled,
    this.fingerprintBlockOnVpn = FingerprintCheckLevel.disabled,
    this.fingerprintVerifyTimeDrift = FingerprintCheckLevel.disabled,
    this.fingerprintVerifyGpsNetworkComparison = FingerprintCheckLevel.disabled,
    this.fingerprintVerifyGpsTimestampOffline = FingerprintCheckLevel.disabled,
    this.fingerprintLivenessChallengesEnabled = FingerprintCheckLevel.disabled,
    this.fingerprintFaceChallengeEnabled = FingerprintCheckLevel.disabled,
    this.fingerprintFaceProfileVerificationEnabled = FingerprintCheckLevel.disabled,
    this.fingerprintUploadFaceImageToBackend = FingerprintCheckLevel.disabled,
    this.fingerprintSendNoteReportToApi = FingerprintCheckLevel.disabled,
    this.fpScanSteps = FingerprintCheckLevel.disabled,
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
      fingerprintFaceChallengeEnabled: FingerprintCheckLevel.fromValue(
        json['fingerprint_face_challenge_enabled'],
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
    );
  }

  /// تحويل قائمة قديمة من أسماء المفاتيح (fingerprintChecks array) إلى موديل
  factory FingerprintSecurityChecksModel.fromLegacyArray(List<dynamic> list) {
    bool contains(String key) => list.any((e) => e?.toString() == key);
    return FingerprintSecurityChecksModel(
      blockFingerprintOnDeveloperMode: contains('block_fingerprint_on_developer_mode')
          ? FingerprintCheckLevel.mandatory
          : FingerprintCheckLevel.disabled,
      fingerprintBlockOnRootOrJailbreak: contains('fingerprint_block_on_root_or_jailbreak')
          ? FingerprintCheckLevel.mandatory
          : FingerprintCheckLevel.disabled,
      fingerprintBlockOnFakeGps: contains('fingerprint_block_on_fake_gps')
          ? FingerprintCheckLevel.mandatory
          : FingerprintCheckLevel.disabled,
      fingerprintBlockOnVpn: contains('fingerprint_block_on_vpn')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
      fingerprintVerifyTimeDrift: contains('fingerprint_verify_time_drift')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
      fingerprintVerifyGpsNetworkComparison: contains('fingerprint_verify_gps_network_comparison')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
      fingerprintVerifyGpsTimestampOffline: contains('fingerprint_verify_gps_timestamp_offline')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
      fingerprintLivenessChallengesEnabled: contains('fingerprint_liveness_challenges_enabled')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
      fingerprintFaceChallengeEnabled: contains('fingerprint_face_challenge_enabled')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
      fingerprintFaceProfileVerificationEnabled: contains('fingerprint_face_profile_verification_enabled')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
      fingerprintUploadFaceImageToBackend: contains('fingerprint_upload_face_image_to_backend')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
      fingerprintSendNoteReportToApi: contains('fingerprint_send_note_report_to_api')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
      fpScanSteps: contains('fp_scan_steps')
          ? FingerprintCheckLevel.optional
          : FingerprintCheckLevel.disabled,
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
      'fingerprint_face_challenge_enabled': fingerprintFaceChallengeEnabled.toValue(),
      'fingerprint_face_profile_verification_enabled': fingerprintFaceProfileVerificationEnabled.toValue(),
      'fingerprint_upload_face_image_to_backend': fingerprintUploadFaceImageToBackend.toValue(),
      'fingerprint_send_note_report_to_api': fingerprintSendNoteReportToApi.toValue(),
      'fp_scan_steps': fpScanSteps.toValue(),
    };
  }
}

class TrainerModel {
  final String trainerId;
  final String name;
  final String username;
  final String mobileNumber;
  final String emailAddress;
  final String branchId;

  TrainerModel({
    required this.trainerId,
    required this.name,
    required this.username,
    required this.mobileNumber,
    required this.emailAddress,
    required this.branchId,
  });

  static String _unwrapScalar(dynamic raw) {
    if (raw is Map && raw['\$numberLong'] != null) {
      return raw['\$numberLong'].toString();
    }
    return raw?.toString() ?? '';
  }

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      trainerId: json['trainerId']?.toString() ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      mobileNumber: _unwrapScalar(json['mobileNumber']),
      emailAddress: json['emailAddress'] ?? '',
      branchId: json['branchId']?.toString() ?? '',
    );
  }
}

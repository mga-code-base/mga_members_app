class Grievance {
  final String id;
  final String branchId;
  final String memberId;
  final String issueType;
  final String title;
  final String description;
  final String status;
  final String? resolution;
  final String? closureDate;

  Grievance({
    required this.id,
    required this.branchId,
    required this.memberId,
    required this.issueType,
    required this.title,
    required this.description,
    required this.status,
    this.resolution,
    this.closureDate,
  });

  factory Grievance.fromJson(Map<String, dynamic> json) {
    return Grievance(
      id: json['id']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      issueType: json['issueType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'UNKNOWN',
      resolution: json['resolution'],
      closureDate: json['closureDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'memberId': memberId,
      'issueType': issueType,
      'title': title,
      'description': description,
    };
  }
}

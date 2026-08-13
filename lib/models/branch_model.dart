class BranchResponse {
  final List<BranchItem> allBranches;

  BranchResponse({required this.allBranches});

  factory BranchResponse.fromJson(Map<String, dynamic> json) {
    return BranchResponse(
      allBranches: (json['allBranches'] as List? ?? [])
          .map((b) => BranchItem.fromJson(b))
          .toList(),
    );
  }
}

class BranchItem {
  final String branchId;
  final String name;
  final List<String> adminId;
  final int pincode;
  final String address;
  final String city;
  final List<EquipmentItem> equipments;

  BranchItem({
    required this.branchId,
    required this.name,
    required this.adminId,
    required this.pincode,
    required this.address,
    required this.city,
    required this.equipments,
  });

  factory BranchItem.fromJson(Map<String, dynamic> json) {
    return BranchItem(
      branchId: json['branchId']?.toString() ?? '',
      name: json['name'] ?? '',
      adminId: List<String>.from(json['adminId'] ?? []),
      pincode: json['pincode'] as int? ?? 0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      equipments: (json['equipments'] as List? ?? [])
          .map((e) => EquipmentItem.fromJson(e))
          .toList(),
    );
  }
}

class EquipmentItem {
  final String name;
  final String exerciseName;
  final String targetMuscle;
  final bool isInWorkingCondition;

  EquipmentItem({
    required this.name,
    required this.exerciseName,
    required this.targetMuscle,
    required this.isInWorkingCondition,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      name: json['name'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      targetMuscle: json['targetMuscle'] ?? '',
      isInWorkingCondition: json['isInWorkingCondition'] == true,
    );
  }
}

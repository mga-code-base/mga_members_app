import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';
import '../../models/grievance_model.dart';
import '../../services/auth_cache_service.dart';
import '../../services/resource_api_service.dart';

class ReportIssuePopup extends StatefulWidget {
  const ReportIssuePopup({super.key});

  static void show(BuildContext context, VoidCallback onRefreshNeeded) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.white10),
      ),
      builder: (context) => const ReportIssuePopup(),
    ).then((_) => onRefreshNeeded());
  }

  @override
  State<ReportIssuePopup> createState() => _ReportIssuePopupState();
}

class _ReportIssuePopupState extends State<ReportIssuePopup> {
  final ResourceApiService _grievanceService = ResourceApiService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedBranchId;
  String? _selectedIssueType;
  String? _cachedMemberId;
  List<Map<String, String>> _branches = [];
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  final List<String> _issueTypes = ["Membership", "Branch", "Equipment", "Trainer"];

  @override
  void initState() {
    super.initState();
    _loadInitializationData();
  }

  Future<void> _loadInitializationData() async {
    try {
      final fetchedBranches = await ResourceApiService.fetchAllBranchNames();
      final cachedId = await AuthCacheService.getCachedMemberId();

      setState(() {
        _branches = fetchedBranches;
        _cachedMemberId = cachedId ?? "UNKNOWN_MEMBER";
        _isLoadingData = false;
      });
    } catch (_) {
      setState(() {
        _cachedMemberId = "ERROR_FETCHING_ID";
        _isLoadingData = false;
      });
    }
  }

  void _submitIssue() async {
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    if (_selectedBranchId == null || _selectedIssueType == null || title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all mandatory fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final newGrievance = Grievance(
      id: '',
      status: 'PENDING',
      branchId: _selectedBranchId!,
      memberId: _cachedMemberId!,
      title: title,
      issueType: _selectedIssueType!,
      description: description,
    );

    final bool success = await _grievanceService.createGrievance(newGrievance);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue reported successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission failed. Please try again.'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: ThemeData.dark().copyWith(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
          filled: true,
          fillColor: AppColors.background,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.crimson, width: 1.5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.02,
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          bottom: MediaQuery.of(context).viewInsets.bottom + screenHeight * 0.02,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Report New Issue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white60), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(color: Colors.white10),
              SizedBox(height: screenHeight * 0.015),
              _isLoadingData
                  ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: AppColors.crimson)))
                  : DropdownButtonFormField<String>(
                      value: _selectedBranchId,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      hint: const Text('Select Location Branch', style: TextStyle(color: Colors.white38)),
                      decoration: const InputDecoration(labelText: 'Branch Location *'),
                      items: _branches.map((branch) {
                        return DropdownMenuItem<String>(
                          value: branch['id'],
                          child: Text(branch['name'] ?? '', style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedBranchId = value),
                    ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(labelText: 'Short Description *'),
              ),
              SizedBox(height: screenHeight * 0.02),
              DropdownButtonFormField<String>(
                value: _selectedIssueType,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                hint: const Text('Select Issue Category', style: TextStyle(color: Colors.white38)),
                decoration: const InputDecoration(labelText: 'Issue Type *'),
                items: _issueTypes.map((String type) {
                  return DropdownMenuItem<String>(value: type, child: Text(type, style: const TextStyle(color: Colors.white)));
                }).toList(),
                onChanged: (value) => setState(() => _selectedIssueType = value),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(labelText: 'Detailed Explanation *', alignLabelWithHint: true),
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.crimson,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting || _isLoadingData ? null : _submitIssue,
                  child: _isSubmitting
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Submit Request Ticket', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

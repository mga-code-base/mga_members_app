import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_theme.dart';
import '../../models/grievance_model.dart';
import '../../services/auth_cache_service.dart';
import '../../services/resource_api_service.dart';
import 'report_issue_popup.dart';

class GrievanceScreen extends StatefulWidget {
  const GrievanceScreen({super.key});

  @override
  State<GrievanceScreen> createState() => _GrievanceScreenState();
}

class _GrievanceScreenState extends State<GrievanceScreen> {
  final ResourceApiService _grievanceService = ResourceApiService();
  bool _showActive = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_showActive ? 'Active Grievances' : 'Grievance History'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.accent),
          actions: [
            TextButton(
              onPressed: () => setState(() => _showActive = !_showActive),
              child: Text(
                _showActive ? 'View Inactive' : 'View Active',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: FutureBuilder<String?>(
          future: AuthCacheService.getCachedMemberId(),
          builder: (context, cacheSnapshot) {
            if (cacheSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }

            final String memberId = cacheSnapshot.data ?? "UNKNOWN_MEMBER";

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_comment_rounded, color: Colors.black),
                      label: const Text('Report New Issue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        ReportIssuePopup.show(context, () {
                          setState(() {});
                        });
                      },
                    ),
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                Expanded(
                  child: FutureBuilder<List<Grievance>>(
                    future: _showActive
                        ? _grievanceService.fetchActiveGrievances(memberId)
                        : _grievanceService.fetchInactiveGrievances(memberId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading requests: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            _showActive ? 'No open grievances active.' : 'No closed ticket history found.',
                            style: const TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                        );
                      }

                      final tickets = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final item = tickets[index];
                          return Card(
                            color: AppColors.surface,
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppColors.accent.withOpacity(0.6), width: 1.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 0.5),
                                        ),
                                        child: Text(item.issueType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                                      ),
                                      Text(
                                        item.status,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _showActive ? AppColors.accent : Colors.greenAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 6),
                                  Text(item.description, style: const TextStyle(color: AppColors.lightGrey, fontSize: 13, height: 1.4)),
                                  if (!_showActive && item.resolution != null) ...[
                                    const Divider(color: Colors.white10, height: 24),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green.withOpacity(0.2), width: 0.5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Resolution: ${item.resolution}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.greenAccent)),
                                          const SizedBox(height: 6),
                                          Text('Closed On: ${item.closureDate}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                                        ],
                                      ),
                                    )
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

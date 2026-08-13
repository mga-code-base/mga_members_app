import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_routes.dart';
import '../../core/config/app_theme.dart';
import '../../services/auth_cache_service.dart';

const Set<String> _alwaysActiveRoutes = {
  AppRoutes.logWorkout,
  AppRoutes.grievances,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<bool?> _isActiveFuture;

  @override
  void initState() {
    super.initState();
    _isActiveFuture = AuthCacheService.getIsActive();
  }

  void _executeLogoutSequence(BuildContext context) async {
    await AuthCacheService.clearSessionCache();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session cache cleared. Logged out successfully.'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  void _showInactiveAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Account Inactive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Please renew Membership or Contact Admin',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Okay 😢", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'My Records & Details', 'icon': Icons.assignment, 'route': AppRoutes.logWorkout},
      {'title': 'My Trainer', 'icon': Icons.person, 'route': AppRoutes.myTrainer},
      {'title': 'Branches', 'icon': Icons.store, 'route': AppRoutes.branches},
      {'title': 'My Trainer Bot', 'icon': Icons.smart_toy, 'route': AppRoutes.trainerBot},
      {'title': 'My Posture Training', 'icon': Icons.videocam, 'route': AppRoutes.posture},
      {'title': 'My Grievances', 'icon': Icons.report_problem, 'route': AppRoutes.grievances},
    ];
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: AppTheme.dark,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MGA Member Terminal'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: 'Log Out Session',
              onPressed: () => _executeLogoutSequence(context),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: FutureBuilder<bool?>(
          future: _isActiveFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }

            final bool isAccountInactive = snapshot.data == false;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: menuItems.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemBuilder: (context, index) {
                          final item = menuItems[index];
                          final bool isLocked = isAccountInactive && !_alwaysActiveRoutes.contains(item['route']);

                          return Card(
                            color: AppColors.surface,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: (isLocked ? Colors.white24 : AppColors.accent).withOpacity(0.6), width: 1.5),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (item['route'] == null) return;
                                if (isLocked) {
                                  _showInactiveAccountDialog(context);
                                } else {
                                  Navigator.pushNamed(context, item['route']);
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Opacity(
                                opacity: isLocked ? 0.4 : 1.0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(item['icon'], size: 42, color: AppColors.accent),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        item['title'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.offWhite,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
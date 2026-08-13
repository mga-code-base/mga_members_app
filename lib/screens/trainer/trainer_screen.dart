import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_theme.dart';
import '../../models/trainer_model.dart';
import '../../services/auth_cache_service.dart';
import '../../services/people_api_service.dart';

class MyTrainerScreen extends StatefulWidget {
  const MyTrainerScreen({super.key});

  @override
  State<MyTrainerScreen> createState() => _MyTrainerScreenState();
}

class _MyTrainerScreenState extends State<MyTrainerScreen> {
  TrainerModel? _trainer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrainerProfile();
  }

  Future<void> _loadTrainerProfile() async {
    try {
      final cachedId = await AuthCacheService.getCachedTrainerId();
      if (cachedId == null || cachedId.isEmpty) {
        setState(() {
          _error = "No assigned trainer reference found in current session cache.";
          _isLoading = false;
        });
        return;
      }

      final profile = await PeopleApiService.fetchTrainerDetails(cachedId);
      setState(() {
        _trainer = profile;
        if (profile == null) _error = "Trainer profile records could not be fetched.";
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = "An error occurred while linking trainer session parameters.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Trainer Details'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.accent),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Center(child: _buildTrainerCard()),
      ),
    );
  }

  Widget _buildTrainerCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          color: AppColors.surface,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.accent.withOpacity(0.6), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1F1E2A),
                  child: Icon(Icons.assignment_ind, size: 55, color: AppColors.accent),
                ),
                const SizedBox(height: 16),
                Text(_trainer!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("@${_trainer!.username}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const Divider(color: AppColors.accent, height: 40, thickness: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: AppColors.accent),
                  title: const Text('Email Address', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(_trainer!.emailAddress, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.offWhite)),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.accent),
                  title: const Text('Mobile Number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(_trainer!.mobileNumber, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.offWhite)),
                ),
                ListTile(
                  leading: const Icon(Icons.business, color: AppColors.accent),
                  title: const Text('Assigned Branch Location ID', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(_trainer!.branchId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.offWhite)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

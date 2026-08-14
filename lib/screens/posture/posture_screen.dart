import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_theme.dart';
import '../../services/posture_api_service.dart';

class PostureScreen extends StatefulWidget {
  const PostureScreen({super.key});

  @override
  State<PostureScreen> createState() => _PostureScreenState();
}

class _PostureScreenState extends State<PostureScreen> with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  XFile? _selectedVideo;
  final ImagePicker _picker = ImagePicker();

  bool _hasAnalyzed = false;
  String _messageStatus = "No analysis processed yet. Record or upload a video clip of your workout.";

  String _detectedExercise = "Squat";
  int _repsCounted = 0;
  num _deepestKneeAngle = 0;
  num _maxForwardLeanAngle = 0;
  String _coachFeedback = "";

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _processingTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _showResourceLimitNotice());
  }

  void _showResourceLimitNotice() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text(
          'This AI service Runs on a Limited Resource Cloud Platform, it could be Slow!',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Okay', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _processingTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      _processingTimer?.cancel();

      setState(() {
        _isProcessing = true;
        _hasAnalyzed = false;
        _messageStatus = "Opening media system capture window...";
      });
      _pulseController.repeat(reverse: true);

      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 3),
      );

      if (video == null) {
        setState(() {
          _isProcessing = false;
          _messageStatus = "No analysis processed yet. Record or upload a video clip of your workout.";
        });
        _pulseController.stop();
        return;
      }

      setState(() {
        _selectedVideo = video;
        _messageStatus = "Uploading and analyzing file: ${video.name}...";
      });

      _processingTimer = Timer(const Duration(seconds: 40), () {
        if (mounted && _isProcessing) {
          setState(() {
            _messageStatus = "Almost There! Thank you for your Patience";
          });
        }
      });

      Map<String, dynamic> responseMap = await PostureApiService.uploadPostureVideo(video.path);
      _processingTimer?.cancel();

      setState(() {
        _isProcessing = false;
        _pulseController.stop();
        if (responseMap['success'] == true) {
          _hasAnalyzed = true;
          _detectedExercise = responseMap['detectedExercise'] ?? 'Squat';
          _repsCounted = responseMap['repsCounted'] ?? 0;
          _deepestKneeAngle = responseMap['deepestKneeAngle'] ?? 0;
          _maxForwardLeanAngle = responseMap['maxForwardLeanAngle'] ?? 0;
          _coachFeedback = responseMap['feedback'] ?? '';
          _messageStatus = "Analysis completed successfully.";
        } else {
          _hasAnalyzed = false;
          _messageStatus = responseMap['feedback'] ?? "Failed to analyze video posture.";
        }
      });
    } catch (e) {
      _processingTimer?.cancel();
      setState(() {
        _hasAnalyzed = false;
        _messageStatus = "An error occurred while accessing media storage: $e";
        _isProcessing = false;
      });
      _pulseController.stop();
    }
  }

  void _showSourceSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.white10),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.videocam, color: AppColors.accent),
                ),
                title: const Text('Record Live Video with Camera', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.video_library, color: AppColors.accent),
                ),
                title: const Text('Choose Existing Clip from Gallery', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: AppTheme.dark,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Posture Evaluation'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.accent),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Recommendation: Please add Video with at least 6 to 7 repetitions and at least 15 seconds long",
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                height: screenHeight * 0.065,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isProcessing ? null : _showSourceSelectionSheet,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 20, color: Colors.black),
                  label: const Text('Select Workout Video Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              if (_selectedVideo != null) ...[
                Text(
                  'Active File Path: ${_selectedVideo!.path}',
                  style: const TextStyle(fontSize: 11, color: Colors.white30, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.015),
              ],
              const Text('Feedback Report Matrix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.accent)),
              SizedBox(height: screenHeight * 0.015),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent.withOpacity(0.6), width: 1.5),
                  ),
                  child: _isProcessing
                      ? Center(
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.08), shape: BoxShape.circle),
                                  child: const CircularProgressIndicator(strokeWidth: 3, color: AppColors.accent),
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    _messageStatus.contains('File') || _messageStatus.contains('media') || _messageStatus.contains('Patience')
                                        ? _messageStatus
                                        : "Processing file stream via AI...",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppColors.accent, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Analyzing joint kinematics & biomechanics",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _hasAnalyzed
                          ? ListView(
                              children: [
                                _buildMetricRow("Detected Activity", "🏋️ $_detectedExercise", Colors.cyanAccent),
                                _buildMetricRow("Reps Counted (Not always Accurate)", "🔢 $_repsCounted reps", Colors.purpleAccent),
                                _buildMetricRow("Deepest Knee Angle", "📐 ${_deepestKneeAngle.toStringAsFixed(1)}°", Colors.orangeAccent),
                                _buildMetricRow("Max Forward Lean", "📈 ${_maxForwardLeanAngle.toStringAsFixed(1)}°", Colors.tealAccent),
                                const Divider(color: Colors.white10, height: 32),
                                const Text("Biomechanical Evaluation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.accent)),
                                const SizedBox(height: 8),
                                Text(
                                  _coachFeedback,
                                  style: const TextStyle(color: Colors.lightGreen, fontSize: 13, height: 1.4),
                                ),
                              ],
                            )
                          : Center(
                              child: Text(
                                _messageStatus,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white38, fontSize: 14),
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.clip,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

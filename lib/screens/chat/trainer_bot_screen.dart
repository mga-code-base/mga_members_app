import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_theme.dart';
import '../../models/chat_model.dart';
import '../../models/workout_model.dart';
import '../../services/auth_cache_service.dart';
import '../../services/chat_api_service.dart';
import '../../services/resource_api_service.dart';

class ChatCacheService {
  static final List<ChatMessage> _cachedMessages = [];
  static final List<String> _cachedWorkoutFocus = [];

  static List<ChatMessage> getMessages() => _cachedMessages;

  static List<String> getCachedFocus() => _cachedWorkoutFocus;

  static void cacheMessage(ChatMessage message) {
    _cachedMessages.add(message);
  }

  static void cacheWorkoutFocus(List<String> focusList) {
    _cachedWorkoutFocus.clear();
    _cachedWorkoutFocus.addAll(focusList);
  }

  static void initializeCacheWithSystemMessage(ChatMessage systemMessage) {
    if (_cachedMessages.isEmpty) {
      _cachedMessages.add(systemMessage);
    }
  }

  static void clearSessionCache() {
    _cachedMessages.clear();
    _cachedWorkoutFocus.clear();
  }
}

class TrainerBotScreen extends StatefulWidget {
  const TrainerBotScreen({super.key});

  @override
  State<TrainerBotScreen> createState() => _TrainerBotScreenState();
}

class _TrainerBotScreenState extends State<TrainerBotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _modes = ["Nice", "Rude"];
  final List<String> _muscleOptions = ['Chest', 'Shoulder', 'Back', 'Bicep', 'Tricep', 'Legs', 'Abs', 'Cardio', 'None'];
  final List<String> _selectedMuscles = [];

  String _selectedMode = "Nice";
  bool _isChatUnlocked = false;
  bool _isTyping = false;
  bool _isSharingLogs = false;

  @override
  void initState() {
    super.initState();

    final existingFocusList = ChatCacheService.getCachedFocus();
    if (existingFocusList.isNotEmpty) {
      _selectedMuscles.addAll(existingFocusList);
      _isChatUnlocked = true;
    }

    ChatCacheService.initializeCacheWithSystemMessage(ChatMessage(
      text: "System initialized. Choose a personality mode above, or tap the attachment icon to share your workout logs with me for real-time analysis!",
      isUser: false,
      timestamp: DateTime.now(),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animate: false));
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  void _toggleMuscleSelection(String muscle) {
    setState(() {
      if (_selectedMuscles.contains(muscle)) {
        _selectedMuscles.remove(muscle);
      } else {
        if (_selectedMuscles.length < 3) {
          _selectedMuscles.add(muscle);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select a maximum of 3 target muscles.'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      }
    });
  }

  void _unlockAndPrimeChatSession() {
    if (_selectedMuscles.isEmpty || _selectedMuscles.length > 3) return;

    ChatCacheService.cacheWorkoutFocus(_selectedMuscles);

    final String muscleString = _selectedMuscles.join(', ');
    setState(() {
      _isChatUnlocked = true;
    });

    _dispatchBotQueryFlow(
      userDisplayMessage: "🎯 Today's workout setup: $muscleString",
      actualBackendPayload: "Today's workout $muscleString",
    );
  }

  Future<void> _sharePerformanceLogsWithBot() async {
    setState(() => _isSharingLogs = true);

    final String? cachedId = await AuthCacheService.getCachedMemberId();
    if (cachedId == null || cachedId.isEmpty) {
      _showSnack('Session identity expired. Please re-login.', isError: true);
      setState(() => _isSharingLogs = false);
      return;
    }

    final ProgressRecords? history = await ResourceApiService.fetchProgressReport(cachedId);
    setState(() => _isSharingLogs = false);

    if (history == null) {
      _showSnack('No historical log profiles found to analyze.', isError: true);
      return;
    }

    final buffer = StringBuffer();
    buffer.write("Analyze my recent training data log entry blocks. Here is my current progress tracker blueprint:\n");
    if (history.chestRecords.isNotEmpty) buffer.write("- Chest focus routines logged: ${history.chestRecords.length} records\n");
    if (history.shoulderRecords.isNotEmpty) buffer.write("- Shoulder focus routines logged: ${history.shoulderRecords.length} records\n");
    if (history.backRecords.isNotEmpty) buffer.write("- Back focus routines logged: ${history.backRecords.length} records\n");
    if (history.bicepRecords.isNotEmpty) buffer.write("- Bicep focus routines logged: ${history.bicepRecords.length} records\n");
    if (history.tricepRecords.isNotEmpty) buffer.write("- Tricep focus routines logged: ${history.tricepRecords.length} records\n");
    if (history.absRecords.isNotEmpty) buffer.write("- Abs focus routines logged: ${history.absRecords.length} records\n");
    if (history.legsRecords.isNotEmpty) buffer.write("- Legs focus routines logged: ${history.legsRecords.length} records\n");
    if (history.cardioRecords.isNotEmpty) buffer.write("- Cardio focus routines logged: ${history.cardioRecords.length} records\n");

    _dispatchBotQueryFlow(
      userDisplayMessage: "📊 Shared my workout progress logs summary for real-time analysis.",
      actualBackendPayload: buffer.toString(),
    );
  }

  Future<void> _handleSubmittedTextPrompt() async {
    final String text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _dispatchBotQueryFlow(userDisplayMessage: text, actualBackendPayload: text);
  }

  Future<void> _dispatchBotQueryFlow({required String userDisplayMessage, required String actualBackendPayload}) async {
    final userMsg = ChatMessage(text: userDisplayMessage, isUser: true, timestamp: DateTime.now());

    setState(() {
      ChatCacheService.cacheMessage(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    final botResponse = await ChatApiService.askTrainerBot(
      message: actualBackendPayload,
      mode: _selectedMode,
    );

    final botMsg = ChatMessage(
      text: botResponse ?? "Error linking with bot. Verify connection configurations.",
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isTyping = false;
      ChatCacheService.cacheMessage(botMsg);
    });
    _scrollToBottom();
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.redAccent : Colors.green),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final cachedMessagesList = ChatCacheService.getMessages();

    return Theme(
      data: AppTheme.dark,
      child: Scaffold(
        appBar: AppBar(
          title: Text(!_isChatUnlocked ? 'Session Gateway Initialization' : 'AI Trainer Bot'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.accent),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.012),
                color: AppColors.surface,
                child: Row(
                  children: [
                    const Text("Bot Style:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70)),
                    const SizedBox(width: 8),
                    ..._modes.map((mode) {
                      final bool isSelected = _selectedMode == mode;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(mode, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white38)),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.background,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSelected ? AppColors.accent : Colors.white10),
                          ),
                          onSelected: (bool selected) {
                            if (selected) setState(() => _selectedMode = mode);
                          },
                        ),
                      );
                    }).toList(),
                    const Spacer(),
                    if (_isChatUnlocked)
                      _isSharingLogs
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                          : TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.accent.withOpacity(0.12),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: AppColors.accent.withOpacity(0.4)),
                                ),
                              ),
                              onPressed: _isTyping ? null : _sharePerformanceLogsWithBot,
                              icon: const Icon(Icons.analytics_outlined, color: AppColors.accent, size: 16),
                              label: const Text('Share Logs', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              Expanded(
                child: !_isChatUnlocked
                    ? _buildGatewayVerificationPortal(screenWidth, screenHeight)
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                              itemCount: cachedMessagesList.length,
                              itemBuilder: (context, index) => _buildChatBubble(cachedMessagesList[index], screenWidth),
                            ),
                          ),
                          if (_isTyping)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 8.0),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
                                  const SizedBox(width: 12),
                                  Text("Trainer processing [$_selectedMode] response...", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                            ),
                          _buildMessageInputField(screenWidth, screenHeight),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGatewayVerificationPortal(double screenWidth, double screenHeight) {
    final String dynamicButtonName = _selectedMode == "Nice" ? "Chat with sweet Sweetie" : "Chat with harsh Harsh";

    return Center(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 16),
        shrinkWrap: true,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(Icons.fitness_center_rounded, size: 40, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          const Text(
            'Target Muscle Selection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Select 1 to 3 muscle anatomy groups you intend to train today.',
            style: TextStyle(fontSize: 13, color: Colors.white38),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ..._muscleOptions.map((String muscle) {
            final bool isChecked = _selectedMuscles.contains(muscle);
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isChecked ? AppColors.accent : Colors.white10, width: 1),
              ),
              child: CheckboxListTile(
                title: Text(muscle, style: const TextStyle(fontSize: 14, color: Colors.white)),
                value: isChecked,
                activeColor: AppColors.accent,
                checkColor: Colors.black,
                controlAffinity: ListTileControlAffinity.trailing,
                onChanged: (_) => _toggleMuscleSelection(muscle),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white10,
                disabledForegroundColor: Colors.white24,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _selectedMuscles.isEmpty ? null : _unlockAndPrimeChatSession,
              child: Text(dynamicButtonName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, double screenWidth) {
    final bool isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: screenWidth * 0.76),
        decoration: BoxDecoration(
          color: isUser ? AppColors.accent.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(color: isUser ? AppColors.accent.withOpacity(0.4) : Colors.white10, width: 1),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? AppColors.offWhite : AppColors.lightGrey, fontSize: 14, height: 1.3),
        ),
      ),
    );
  }

  Widget _buildMessageInputField(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.only(left: screenWidth * 0.04, right: screenWidth * 0.04, top: 8, bottom: 16),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: screenHeight * 0.06,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Type a prompt to your trainer bot...",
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _handleSubmittedTextPrompt(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: screenHeight * 0.055,
            width: screenHeight * 0.055,
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
              onPressed: _handleSubmittedTextPrompt,
              tooltip: 'Send Prompt',
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/chat_message.dart';
import '../../models/user_profile.dart';
import '../../models/health_event.dart';
import '../../services/database_service.dart';
import '../../services/ai_chat_service.dart';
import '../../services/symptom_rule_engine.dart';
import '../../widgets/disclaimer_banner.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isOnline = true;
  UserProfile? _profile;

  final _aiService = AiChatService();
  final _ruleEngine = SymptomRuleEngine();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadMessages();
    _checkConnectivity();
    _addWelcomeMessage();
  }

  void _loadProfile() {
    final db = DatabaseService();
    final data = db.getUserProfile();
    if (data != null) {
      _profile = UserProfile.fromJson(data);
    }
  }

  void _loadMessages() {
    final db = DatabaseService();
    final data = db.getChatMessages();
    setState(() {
      _messages.clear();
      _messages.addAll(data.map((e) => ChatMessage.fromJson(e)));
    });
  }

  void _addWelcomeMessage() {
    if (_messages.isEmpty) {
      _messages.insert(
        0,
        ChatMessage(
          id: 'welcome',
          text: 'Hello${_profile != null ? ', ${_profile!.name}' : ''}! 👋\n\n'
              'I\'m Healix AI, your health assistant. You can describe your symptoms '
              'and I\'ll help you understand possible causes and recommended actions.\n\n'
              'For example, try saying:\n'
              '• "I have a headache and fever"\n'
              '• "My stomach hurts after eating"\n'
              '• "I feel dizzy and tired"',
          isUser: false,
        ),
      );
    }
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = !result.contains(ConnectivityResult.none);
    });

    Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isOnline = !result.contains(ConnectivityResult.none);
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.chatGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Healix AI', style: AppTypography.titleLarge),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOnline
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isOnline ? 'Online' : 'Offline Mode',
                      style: AppTypography.bodySmall.copyWith(
                        color: _isOnline
                            ? AppColors.success
                            : AppColors.warning,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer
          const DisclaimerBanner(compact: true),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, index);
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(0),
                        _buildDot(1),
                        _buildDot(2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                  top: BorderSide(
                      color: AppColors.glassBorder, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: AppColors.glassBorder),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: AppTypography.bodyLarge,
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Describe your symptoms...',
                          hintStyle: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textTertiary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textTertiary,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .fadeIn(delay: Duration(milliseconds: index * 200))
        .then()
        .fadeOut(delay: 400.ms);
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.chatGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.glassBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isOffline)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Offline',
                            style: TextStyle(
                                color: AppColors.warning, fontSize: 9),
                          ),
                        ),
                      Text(
                        _formatTime(message.timestamp),
                        style: AppTypography.bodySmall
                            .copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _textController.clear();

    // Add user message
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });

    _scrollToBottom();

    // Save user message
    final db = DatabaseService();
    await db.addChatMessage(userMsg.toJson());

    // Get AI response
    String response;
    bool isOffline = false;

    if (_isOnline) {
      try {
        String? userContext;
        if (_profile != null) {
          userContext =
              'Age: ${_profile!.age}, Gender: ${_profile!.gender}, '
              'Blood Group: ${_profile!.bloodGroup}, '
              'Allergies: ${_profile!.allergies.join(", ")}, '
              'Conditions: ${_profile!.chronicConditions.join(", ")}';
        }
        response = await _aiService.sendMessage(text, userContext: userContext);
      } catch (e) {
        // Fallback to offline
        response = _ruleEngine.analyzeSymptoms(text);
        isOffline = true;
      }
    } else {
      response = _ruleEngine.analyzeSymptoms(text);
      isOffline = true;
    }

    // Add AI response
    final aiMsg = ChatMessage(
      id: const Uuid().v4(),
      text: response,
      isUser: false,
      isOffline: isOffline,
    );

    setState(() {
      _messages.add(aiMsg);
      _isLoading = false;
    });

    await db.addChatMessage(aiMsg.toJson());

    // Add to health history
    await db.addHealthEvent(HealthEvent(
      id: const Uuid().v4(),
      title: 'Symptom Check: $text',
      description: 'AI consultation${isOffline ? " (offline)" : ""}',
      type: HealthEventType.symptom,
      date: DateTime.now(),
    ).toJson());

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Chat', style: AppTypography.headlineMedium),
        content: Text('Delete all chat messages?',
            style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService().clearChat();
      setState(() {
        _messages.clear();
        _addWelcomeMessage();
      });
    }
  }
}

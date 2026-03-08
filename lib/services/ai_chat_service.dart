import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class AiChatService {
  static final AiChatService _instance = AiChatService._internal();
  factory AiChatService() => _instance;
  AiChatService._internal();

  List<Map<String, String>> _messages = [];

  final String _systemInstruction = '''
You are Healix AI, a caring and knowledgeable health assistant. Your role is to:

1. Analyze symptoms described by users
2. Provide possible causes in simple language
3. Suggest precautionary actions and home remedies
4. Recommend visiting a doctor when necessary
5. Be empathetic and supportive

IMPORTANT RULES:
- Always start responses with a brief empathetic acknowledgment
- Structure your responses clearly with sections
- Use bullet points for advice
- NEVER provide definitive diagnoses - always use phrases like "possible causes", "may indicate"
- ALWAYS remind users to consult a healthcare professional for proper diagnosis
- If symptoms sound serious (chest pain, breathing difficulty, severe bleeding), strongly urge immediate medical attention
- Keep responses concise but thorough
- If the user shares their profile info (age, gender, conditions), factor that into your analysis
- Do NOT prescribe specific medications with dosages
''';

  void initialize() {
    resetChat();
  }

  Future<String> sendMessage(String message, {String? userContext}) async {
    try {
      String fullMessage = message;
      if (userContext != null) {
        fullMessage = 'User context: $userContext\n\nUser says: $message';
      }

      _messages.add({"role": "user", "content": fullMessage});

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.openRouterApiKey}',
          'HTTP-Referer': 'https://healixai.com', 
          'X-Title': AppConstants.appName, 
        },
        body: jsonEncode({
          "model": "nvidia/nemotron-3-nano-30b-a3b:free",
          "messages": [
            {"role": "system", "content": _systemInstruction},
            ..._messages,
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] ?? '';
        
        _messages.add({"role": "assistant", "content": reply});
        return reply;
      } else {
        _messages.removeLast();
        return 'I apologize, but I couldn\'t generate a response (Status: ${response.statusCode}). Please try again.';
      }
    } catch (e) {
      if (_messages.isNotEmpty && _messages.last['role'] == 'user') {
        _messages.removeLast();
      }
      return 'I\'m having trouble connecting to the AI service. Please check your internet connection or try again later.\n\nError: ${e.toString()}';
    }
  }

  void resetChat() {
    _messages = [];
  }
}

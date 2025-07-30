import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/gemini_service.dart';
import '../models/chat_model.dart';

class ChatbotScreen extends StatefulWidget {
  final String userType;
  final String? initialMessage;
  final String? context;
  
  const ChatbotScreen({
    super.key, 
    required this.userType,
    this.initialMessage,
    this.context,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimationController;
  List<String> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      await GeminiService.initialize();
      _addWelcomeMessage();
      
      // If there's a context or initial message, process it
      if (widget.context != null || widget.initialMessage != null) {
        await _handleInitialContext();
      }
    } catch (e) {
      _addSystemMessage("⚠️ AI service is temporarily unavailable. You can still get basic health advice.");
    }
  }

  Future<void> _handleInitialContext() async {
    if (widget.context != null) {
      // Add context-based message
      String contextMessage = _getContextualMessage();
      setState(() {
        messages.add(ChatMessage.bot(contextMessage));
      });
      _scrollToBottom();
    }
    
    if (widget.initialMessage != null) {
      // Auto-send the initial message
      await Future.delayed(const Duration(milliseconds: 500));
      _sendSpecificMessage(widget.initialMessage!);
    }
  }

  String _getContextualMessage() {
    String context = widget.context ?? '';
    
    if (context.contains('EMERGENCY')) {
      return "🚨 **Emergency Alert Response**\n\nI see you're dealing with an emergency health situation. Let me provide immediate guidance and preventive measures.\n\nWhat specific assistance do you need right now?";
    } else if (context.contains('DENGUE')) {
      return "🦟 **Dengue Prevention Assistant**\n\nI'm here to help you with dengue prevention measures. Let me guide you through:\n\n• Immediate actions to take\n• Breeding site elimination\n• Personal protection methods\n• When to seek medical help\n\nWhat would you like to know first?";
    } else if (context.contains('MALARIA')) {
      return "🦟 **Malaria Prevention Assistant**\n\nI can help you with comprehensive malaria prevention strategies:\n\n• Mosquito control methods\n• Personal protection measures\n• Symptom recognition\n• Environmental management\n\nHow can I assist you?";
    } else if (context.contains('TYPHOID')) {
      return "💧 **Typhoid Prevention Assistant**\n\nI'm here to help with typhoid prevention and safety measures:\n\n• Water and food safety\n• Hygiene practices\n• Vaccination information\n• Symptom awareness\n\nWhat specific guidance do you need?";
    } else if (context.contains('VACCINATION')) {
      return "💉 **Vaccination Information**\n\nI can provide guidance about vaccination campaigns and immunization:\n\n• Vaccine schedules\n• Preparation for vaccination\n• Post-vaccination care\n• Addressing concerns\n\nWhat would you like to know?";
    } else if (context.contains('PREVENTION')) {
      return "🛡️ **Health Prevention Assistant**\n\nI'm ready to help you with preventive health measures:\n\n• General prevention strategies\n• Seasonal health tips\n• Lifestyle modifications\n• Risk reduction methods\n\nWhat specific prevention topic can I help with?";
    }
    
    return "🩺 **Health Assistant**\n\nI'm here to provide specific guidance based on your health concern. How can I help you today?";
  }

  void _addWelcomeMessage() {
    String welcomeMessage = _getWelcomeMessage();
    setState(() {
      messages.add(ChatMessage.bot(welcomeMessage));
    });
    _scrollToBottom();
  }

  String _getWelcomeMessage() {
    switch (widget.userType) {
      case 'ASHA/ANM':
        return "🩺 **Welcome, Health Worker!**\n\nI'm AarogyaRekha's AI Assistant, specialized in preventive healthcare. I can help you with:\n\n• Community health screening tips\n• Disease prevention strategies\n• Early warning signs identification\n• Family health education guidance\n\nHow can I assist you today?";
      case 'PHC/District':
        return "🏥 **Welcome, Healthcare Official!**\n\nI'm here to support your public health initiatives with:\n\n• Outbreak prevention strategies\n• Resource planning for preventive care\n• Community health campaign guidance\n• Seasonal disease preparation\n\nWhat would you like to know?";
      case 'Rural':
        return "🏠 **Welcome to AarogyaRekha!**\n\nI'm your family health assistant, here to help you keep your loved ones healthy with:\n\n• Simple prevention tips\n• Seasonal health advice\n• Child health guidance\n• Safe practices for daily life\n\nWhat health topic can I help you with?";
      case 'Tourist':
        return "🧳 **Welcome, Traveler!**\n\nI'm here to help you stay healthy during your journey with:\n\n• Travel health kit essentials\n• Destination-specific health risks\n• Food and water safety tips\n• Preventive measures for common diseases\n\nWhere are you traveling, and how can I help?";
      default:
        return "🛡️ **Welcome to AarogyaRekha!**\n\nI'm your AI health assistant focused on disease prevention. I can help you with preventive measures, health tips, and early warning signs.\n\nWhat would you like to know about staying healthy?";
    }
  }

  void _addSystemMessage(String message) {
    setState(() {
      messages.add(ChatMessage.system(message));
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await _sendSpecificMessage(text);
  }

  Future<void> _sendSpecificMessage(String text) async {
    // Add user message
    final userMessage = ChatMessage.user(text);
    setState(() {
      messages.add(userMessage);
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Add to conversation history
    _conversationHistory.add("User: $text");
    if (_conversationHistory.length > 10) {
      _conversationHistory.removeAt(0);
    }

    try {
      // Get AI response
      final response = await GeminiService.sendMessage(
        text,
        widget.userType,
        conversationHistory: _conversationHistory,
      );

      // Add bot response
      final botMessage = ChatMessage.bot(response);
      setState(() {
        messages.add(botMessage);
        _isTyping = false;
      });

      // Add to conversation history
      _conversationHistory.add("AI: $response");
      if (_conversationHistory.length > 10) {
        _conversationHistory.removeAt(0);
      }

    } catch (e) {
      setState(() {
        messages.add(ChatMessage.bot("❌ Sorry, I encountered an error. Please try again."));
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSuggestionTap(String query) {
    _messageController.text = query;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'AarogyaRekha AI Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(messages[index]);
                    },
                  ),
          ),

          // Quick suggestions (show when no messages)
          if (messages.length <= 1) _buildQuickSuggestions(),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.health_and_safety,
              size: 50,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'AarogyaRekha AI Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your preventive healthcare companion',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: message.type == MessageType.system 
                  ? Colors.orange.withOpacity(0.1)
                  : const Color(0xFF2E7D8A).withOpacity(0.1),
              child: Icon(
                message.type == MessageType.system 
                    ? Icons.info_outline
                    : Icons.health_and_safety,
                color: message.type == MessageType.system 
                    ? Colors.orange
                    : const Color(0xFF2E7D8A),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color(0xFF2E7D8A)
                    : message.type == MessageType.system
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Use Markdown for bot messages, regular Text for user messages
                  message.isUser 
                      ? Text(
                          message.content,
                          style: TextStyle(
                            color: message.isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              height: 1.4,
                            ),
                            h1: const TextStyle(
                              color: Color(0xFF2E7D8A),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: const TextStyle(
                              color: Color(0xFF2E7D8A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: const TextStyle(
                              color: Color(0xFF2E7D8A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D8A),
                            ),
                            em: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                            code: TextStyle(
                              backgroundColor: Colors.grey.withOpacity(0.1),
                              fontFamily: 'monospace',
                            ),
                            listBullet: const TextStyle(
                              color: Color(0xFF2E7D8A),
                            ),
                          ),
                        ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF2E7D8A),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF2E7D8A).withOpacity(0.1),
            child: const Icon(
              Icons.health_and_safety,
              color: Color(0xFF2E7D8A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const SpinKitThreeBounce(
              color: Color(0xFF2E7D8A),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = ChatSuggestions.getForUserType(widget.userType);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick suggestions:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3,
            ),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return GestureDetector(
                onTap: () => _onSuggestionTap(suggestion.query),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2E7D8A).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        suggestion.icon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          suggestion.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2E7D8A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about preventive health measures...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D8A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AarogyaRekha AI Assistant'),
        content: const Text(
          'This AI assistant provides preventive healthcare guidance based on your user type. '
          'It focuses on disease prevention, early warning signs, and health education.\n\n'
          'Note: This is not a replacement for professional medical advice. '
          'Always consult healthcare providers for diagnosis and treatment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

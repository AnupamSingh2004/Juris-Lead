class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final String? location;
  final List<String>? quickReplies;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.location,
    this.quickReplies,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  factory ChatMessage.bot(String content, {List<String>? quickReplies}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.text,
      quickReplies: quickReplies,
    );
  }

  factory ChatMessage.system(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.system,
    );
  }
}

enum MessageType {
  text,
  system,
  location,
  image,
  quickReply,
}

class QuickReply {
  final String text;
  final String action;
  final String? icon;

  QuickReply({
    required this.text,
    required this.action,
    this.icon,
  });
}

class ChatSuggestion {
  final String title;
  final String description;
  final String query;
  final String icon;
  final String userType;

  ChatSuggestion({
    required this.title,
    required this.description,
    required this.query,
    required this.icon,
    required this.userType,
  });
}

class ChatSuggestions {
  static List<ChatSuggestion> getForUserType(String userType) {
    switch (userType) {
      case 'ASHA/ANM':
        return [
          ChatSuggestion(
            title: 'House Visit Checklist',
            description: 'Get preventive health checklist for home visits',
            query: 'What should I check during house visits for disease prevention?',
            icon: '🏠',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Malaria Prevention',
            description: 'Community education about malaria prevention',
            query: 'How can I educate families about malaria prevention?',
            icon: '🦟',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Child Nutrition',
            description: 'Preventing malnutrition in children',
            query: 'What are the signs of malnutrition and how to prevent it?',
            icon: '👶',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Water Safety',
            description: 'Preventing water-borne diseases',
            query: 'How to prevent diarrhea and water-borne diseases?',
            icon: '💧',
            userType: userType,
          ),
        ];
      case 'PHC/District':
        return [
          ChatSuggestion(
            title: 'Outbreak Prevention',
            description: 'Early warning signs and prevention strategies',
            query: 'What are the early warning signs of disease outbreaks?',
            icon: '🚨',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Resource Planning',
            description: 'Medicine and vaccine inventory for prevention',
            query: 'What preventive medicines and vaccines should we stock?',
            icon: '📋',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Seasonal Preparation',
            description: 'Preparing for monsoon health risks',
            query: 'How should we prepare for monsoon-related health risks?',
            icon: '🌧️',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Community Campaign',
            description: 'Organizing awareness campaigns',
            query: 'How to organize effective health awareness campaigns?',
            icon: '📢',
            userType: userType,
          ),
        ];
      case 'Rural':
        return [
          ChatSuggestion(
            title: 'Family Health',
            description: 'Keeping your family healthy and safe',
            query: 'How can I keep my family healthy and prevent diseases?',
            icon: '👨‍👩‍👧‍👦',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Monsoon Safety',
            description: 'Staying safe during monsoon season',
            query: 'How to stay safe and healthy during monsoon?',
            icon: '☔',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Clean Water',
            description: 'Ensuring safe drinking water at home',
            query: 'How to ensure clean drinking water at home?',
            icon: '🚰',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Child Care',
            description: 'Preventing childhood diseases',
            query: 'How to prevent common childhood diseases?',
            icon: '🧸',
            userType: userType,
          ),
        ];
      case 'Tourist':
        return [
          ChatSuggestion(
            title: 'Travel Health Kit',
            description: 'Essential items for safe travel',
            query: 'What should I pack in my travel health kit for India?',
            icon: '🧳',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Food Safety',
            description: 'Avoiding food-borne illnesses while traveling',
            query: 'How to avoid food-borne diseases while traveling?',
            icon: '🍽️',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Mosquito Protection',
            description: 'Preventing mosquito-borne diseases',
            query: 'How to protect myself from mosquito-borne diseases?',
            icon: '🦟',
            userType: userType,
          ),
          ChatSuggestion(
            title: 'Destination Advice',
            description: 'Location-specific health precautions',
            query: 'What health precautions should I take for rural India?',
            icon: '🗺️',
            userType: userType,
          ),
        ];
      default:
        return [
          ChatSuggestion(
            title: 'General Prevention',
            description: 'Basic health prevention tips',
            query: 'What are the basic health prevention tips?',
            icon: '🛡️',
            userType: userType,
          ),
        ];
    }
  }
}

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static GenerativeModel? _model;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
      throw Exception('Gemini API key not found in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 20,
        topP: 0.8,
        maxOutputTokens: 1000,
      ),
    );

    _isInitialized = true;
    print('✅ Gemini AI initialized successfully');
  }

  static String _buildSystemPrompt(String userType, String? location) {
    final locationContext = location != null ? "User location: $location" : "Location not provided";
    
    return """
You are AarogyaRekha's AI Health Assistant - a specialized preventive healthcare chatbot designed to prevent disease outbreaks before they occur.

CONTEXT:
AarogyaRekha is an AI-powered preventive healthcare system that predicts and alerts communities about potential disease outbreaks like malaria, dengue, diarrhea, and malnutrition using satellite data, climatic patterns, and behavioral insights.

USER TYPE: $userType
$locationContext

CORE MISSION:
- Focus on PREVENTIVE measures rather than treatment
- Provide early warning alerts based on environmental factors
- Offer practical, actionable prevention tips
- Support different user types with tailored advice

KEY DISEASES TO FOCUS ON:
🦟 Vector-borne: Malaria, Dengue, Chikungunya, Zika
💧 Water-borne: Diarrhea, Cholera, Typhoid
🍎 Nutrition-related: Malnutrition, Anemia
🌡️ Climate-sensitive: Heat stroke, Respiratory infections

PREVENTIVE MEASURES DATABASE:
🦟 Mosquito-borne diseases:
- Use mosquito nets (especially during dawn/dusk)
- Apply repellents (Odomos, DEET-based)
- Eliminate standing water (flower pots, containers)
- Wear long sleeves in endemic areas
- Use bed nets treated with insecticide

💧 Water-borne diseases:
- Drink only boiled/filtered water
- Avoid street food and raw vegetables
- Wash hands frequently with soap
- Use ORS for dehydration prevention
- Maintain proper sanitation

🍎 Nutrition-related:
- Include iron-rich foods (spinach, dates, jaggery)
- Ensure balanced diet with proteins and vitamins
- Monitor child growth regularly
- Supplement with vitamin D and B12
- Avoid processed foods

RESPONSE GUIDELINES:
1. Always prioritize prevention over treatment
2. Provide specific, actionable advice
3. Include seasonal/climate considerations
4. Suggest appropriate products/tools when relevant
5. Emphasize early detection and monitoring
6. Use simple, clear language
7. Include traditional remedies where appropriate
8. Always recommend consulting healthcare workers for serious symptoms

USER-SPECIFIC APPROACH:
- ASHA/ANM Workers: Focus on community screening, home visits, and public health measures
- PHC/District Officials: Emphasize surveillance, resource planning, and outbreak management
- Rural Households: Simple, practical tips for family health and local prevention
- Tourists: Destination-specific risks, travel health kit recommendations

Remember: You are NOT a doctor. Always recommend consulting healthcare professionals for diagnosis and treatment. Your role is strictly preventive guidance and health education.

Respond in a helpful, caring, and professional manner. If asked about treatment, redirect to prevention and advise consulting a healthcare provider.
""";
  }

  static Future<String> sendMessage(
    String message,
    String userType, {
    String? location,
    List<String>? conversationHistory,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_model == null) {
      return "❌ AI service is not available. Please check your internet connection and try again.";
    }

    try {
      final systemPrompt = _buildSystemPrompt(userType, location);
      
      // Build conversation context
      String fullPrompt = systemPrompt + "\n\n";
      
      // Add recent conversation history if available
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        fullPrompt += "RECENT CONVERSATION:\n";
        for (int i = 0; i < conversationHistory.length && i < 6; i++) {
          fullPrompt += "${conversationHistory[i]}\n";
        }
        fullPrompt += "\n";
      }
      
      fullPrompt += "USER MESSAGE: $message\n\nAI RESPONSE:";

      final content = [Content.text(fullPrompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        return "❌ Sorry, I couldn't generate a response. Please try again.";
      }

      return response.text!;
    } catch (e) {
      print('❌ Gemini API error: $e');
      return _getFallbackResponse(message, userType);
    }
  }

  static String _getFallbackResponse(String message, String userType) {
    final lowerMessage = message.toLowerCase();
    
    // Malaria prevention
    if (lowerMessage.contains('malaria') || lowerMessage.contains('mosquito')) {
      return """
🦟 **Malaria Prevention Tips:**

**Immediate Actions:**
• Use mosquito nets while sleeping (especially dawn/dusk)
• Apply repellents like Odomos or DEET-based creams
• Wear long sleeves and pants during evening hours
• Remove standing water from containers, flower pots

**For Travel:**
• Carry insect repellent and nets
• Avoid outdoor activities during peak mosquito hours (5-8 PM)
• Stay in air-conditioned/screened rooms when possible

**Monitor Symptoms:**
• Fever, chills, headache, body aches
• Seek immediate medical help if symptoms appear

⚠️ **Important:** If you have fever, consult a healthcare worker immediately for proper diagnosis and treatment.
""";
    }
    
    // Dengue prevention
    if (lowerMessage.contains('dengue') || lowerMessage.contains('aedes')) {
      return """
🦟 **Dengue Prevention Guide:**

**Eliminate Breeding Sites:**
• Empty water containers weekly
• Cover water storage tanks
• Clean gutters and drains
• Remove stagnant water from coolers, plant pots

**Personal Protection:**
• Use mosquito repellents (Odomos, Good knight)
• Wear full-sleeve clothes during day time
• Use bed nets and screens

**Early Warning Signs:**
• High fever, severe headache, pain behind eyes
• Muscle and joint pain, skin rash

⚠️ **Critical:** Dengue can be serious. Consult doctor immediately if symptoms appear.
""";
    }
    
    // Diarrhea prevention
    if (lowerMessage.contains('diarrhea') || lowerMessage.contains('stomach') || lowerMessage.contains('water')) {
      return """
💧 **Diarrhea Prevention:**

**Safe Water Practices:**
• Drink only boiled or filtered water
• Avoid ice cubes and street beverages
• Use bottled water for brushing teeth

**Food Safety:**
• Eat freshly cooked hot food
• Avoid raw vegetables and fruits you can't peel
• Wash hands before eating

**Hygiene Measures:**
• Wash hands frequently with soap
• Use hand sanitizer when soap unavailable
• Maintain clean cooking environment

**For Travelers:**
• Carry ORS packets
• Pack water purification tablets
• Avoid street food

⚠️ **Seek help if:** Severe dehydration, blood in stool, high fever
""";
    }
    
    // Tourist-specific advice
    if (userType == 'Tourist' || lowerMessage.contains('travel')) {
      return """
🧳 **Travel Health Kit for India:**

**Essential Items:**
• Mosquito repellent (Odomos/DEET-based)
• Mosquito net (if staying in endemic areas)
• Water purification tablets
• ORS packets for dehydration
• Hand sanitizer
• Sunscreen and hat
• First aid kit

**Vaccination Check:**
• Hepatitis A & B
• Typhoid
• Japanese Encephalitis (for rural areas)
• Routine vaccines (MMR, DPT)

**Daily Precautions:**
• Drink bottled/boiled water only
• Eat at reputable restaurants
• Avoid street food initially
• Use repellent during dawn/dusk
• Wear appropriate clothing

**Emergency Contacts:**
• Keep local emergency numbers handy
• Know nearest hospital location
• Carry travel insurance details

💡 **Tip:** Research destination-specific health risks before traveling.
""";
    }
    
    // General prevention advice
    return """
🛡️ **General Prevention Tips:**

**Daily Health Practices:**
• Wash hands frequently with soap
• Drink clean, safe water
• Eat balanced, nutritious meals
• Get adequate sleep and exercise
• Maintain clean living environment

**Seasonal Precautions:**
• Monsoon: Prevent water stagnation, avoid contaminated water
• Summer: Stay hydrated, avoid heat exposure
• Winter: Maintain hygiene, prevent respiratory infections

**Community Health:**
• Report unusual illness patterns to health workers
• Participate in vaccination drives
• Maintain cleanliness in surroundings

**When to Seek Help:**
• Persistent fever
• Unusual symptoms
• Outbreak in your area
• Pregnancy/child health concerns

⚠️ **Remember:** Prevention is better than cure. Consult healthcare workers for any health concerns.
""";
  }

  static Future<String> getLocationSpecificAdvice(String location, String userType) async {
    final message = "What are the current health risks and preventive measures I should know about in $location?";
    return await sendMessage(message, userType, location: location);
  }

  static Future<String> getSeasonalAdvice(String season, String userType) async {
    final message = "What preventive health measures should I take during $season season?";
    return await sendMessage(message, userType);
  }

  static Future<String> getDiseasePrevention(String disease, String userType) async {
    final message = "How can I prevent $disease? What are the early warning signs?";
    return await sendMessage(message, userType);
  }

  static Future<String> getTravelAdvice(String destination, String userType) async {
    final message = "I'm traveling to $destination. What health precautions should I take and what should I pack in my health kit?";
    return await sendMessage(message, userType, location: destination);
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class GoogleLoginRequest {
  final String accessToken;

  GoogleLoginRequest({required this.accessToken});

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'password_confirm': password,
      'first_name': firstName,
      'last_name': lastName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }
}

class UserProfile {
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String userRole;
  final String? profilePicture;
  final bool isVerified;

  UserProfile({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.userRole,
    this.profilePicture,
    required this.isVerified,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'],
      userRole: json['user_role'] ?? 'client',
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'user_role': userRole,
      'profile_picture': profilePicture,
      'is_verified': isVerified,
    };
  }
}

class AnalysisRequest {
  final String description;
  final String? category;
  final bool detailed;

  AnalysisRequest({
    required this.description,
    this.category,
    this.detailed = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'case_description': description, // Backend expects case_description
      if (category != null) 'category': category,
      'detailed': detailed,
      // Add optional fields that the backend might use
      'create_lead': false,
      'generate_pdf': false,
      'urgency_level': 'medium',
    };
  }
}

class IPCSection {
  final String sectionNumber;
  final String description;
  final String whyApplicable;
  final String punishment;

  IPCSection({
    required this.sectionNumber,
    required this.description,
    required this.whyApplicable,
    required this.punishment,
  });

  factory IPCSection.fromJson(Map<String, dynamic> json) {
    return IPCSection(
      sectionNumber: json['section_number']?.toString() ?? '',
      description: json['description'] ?? '',
      whyApplicable: json['why_applicable'] ?? '',
      punishment: json['punishment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section_number': sectionNumber,
      'description': description,
      'why_applicable': whyApplicable,
      'punishment': punishment,
    };
  }
}

class AnalysisResponse {
  final String analysis;
  final List<IPCSection> applicableIpcSections;
  final List<IPCSection>? defensiveIpcSections;
  final String severity;
  final String analysisTimestamp;
  final int totalSectionsIdentified;
  final int? totalDefensiveSections;

  AnalysisResponse({
    required this.analysis,
    required this.applicableIpcSections,
    this.defensiveIpcSections,
    required this.severity,
    required this.analysisTimestamp,
    required this.totalSectionsIdentified,
    this.totalDefensiveSections,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      analysis: json['analysis'] ?? '',
      applicableIpcSections: (json['applicable_ipc_sections'] as List<dynamic>?)
          ?.map((section) => IPCSection.fromJson(section))
          .toList() ?? [],
      defensiveIpcSections: (json['defensive_ipc_sections'] as List<dynamic>?)
          ?.map((section) => IPCSection.fromJson(section))
          .toList(),
      severity: json['severity'] ?? 'Medium',
      analysisTimestamp: json['analysis_timestamp'] ?? DateTime.now().toIso8601String(),
      totalSectionsIdentified: json['total_sections_identified'] ?? 0,
      totalDefensiveSections: json['total_defensive_sections'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis': analysis,
      'applicable_ipc_sections': applicableIpcSections.map((s) => s.toJson()).toList(),
      'defensive_ipc_sections': defensiveIpcSections?.map((s) => s.toJson()).toList(),
      'severity': severity,
      'analysis_timestamp': analysisTimestamp,
      'total_sections_identified': totalSectionsIdentified,
      'total_defensive_sections': totalDefensiveSections,
    };
  }
}

class TransformedAnalysisResponse {
  final String summary;
  final List<String> legalIssues;
  final List<String> recommendations;
  final String severity;
  final List<String> nextSteps;
  final List<ApplicableSection> applicableSections;
  final List<ApplicableSection>? defensiveSections;
  final String timeline;
  final String caseType;

  TransformedAnalysisResponse({
    required this.summary,
    required this.legalIssues,
    required this.recommendations,
    required this.severity,
    required this.nextSteps,
    required this.applicableSections,
    this.defensiveSections,
    required this.timeline,
    required this.caseType,
  });
}

class ApplicableSection {
  final String section;
  final String title;
  final String description;
  final String punishment;

  ApplicableSection({
    required this.section,
    required this.title,
    required this.description,
    required this.punishment,
  });
}

class OCRResponse {
  final bool success;
  final String? extractedText;
  final String? error;

  OCRResponse({
    required this.success,
    this.extractedText,
    this.error,
  });

  factory OCRResponse.fromJson(Map<String, dynamic> json) {
    return OCRResponse(
      success: json['success'] ?? false,
      extractedText: json['extracted_text'],
      error: json['error'],
    );
  }
}

class DocumentSummaryResponse {
  final bool success;
  final String? summary;
  final List<String>? keyPoints;
  final String? error;

  DocumentSummaryResponse({
    required this.success,
    this.summary,
    this.keyPoints,
    this.error,
  });

  factory DocumentSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DocumentSummaryResponse(
      success: json['success'] ?? false,
      summary: json['summary'],
      keyPoints: (json['key_points'] as List<dynamic>?)
          ?.map((point) => point.toString())
          .toList(),
      error: json['error'],
    );
  }
}

class ApiError implements Exception {
  final String message;
  final int? status;
  final dynamic details;

  ApiError({
    required this.message,
    this.status,
    this.details,
  });

  @override
  String toString() => 'ApiError: $message (Status: $status)';
}

class HistoryEntry {
  final String id;
  final String title;
  final String content;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  HistoryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

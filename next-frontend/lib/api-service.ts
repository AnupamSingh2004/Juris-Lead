// API configuration for Juris-Lead backend
export const API_CONFIG = {
  BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8001/api/v1',
  ENDPOINTS: {
    ANALYZE_CASE: '/leads/analyze-case/', // Public endpoint for citizens to analyze cases
    EXTRACT_TEXT: '/legal/extract-text/', // OCR endpoint for image text extraction
    HEALTH_CHECK: '/legal/health/', // Correct health check endpoint
    LOGIN: '/auth/login/',
    GOOGLE_LOGIN: '/auth/google-login/',
    LOGOUT: '/auth/logout/',
    PROFILE: '/auth/profile/',
    REFRESH_TOKEN: '/auth/token/refresh/',
    // History endpoints
    HISTORY_LIST: '/auth/history/activities/',
    HISTORY_ACTIVITY_TYPES: '/auth/history/activities/types/',
    HISTORY_CLEAR: '/auth/history/activities/clear/',
    HISTORY_EXPORT: '/auth/history/activities/export/',
  },
  TIMEOUT: 300000, // 5 minutes for AI analysis
};
export interface ApiErrorData {
  message: string;
  status?: number;
  details?: any;
}

export class ApiError extends Error {
  public status?: number;
  public details?: any;

  constructor(data: ApiErrorData) {
    super(data.message);
    this.name = 'ApiError';
    this.status = data.status;
    this.details = data.details;
  }
}

export interface IpcSection {
  section_number: string;
  description: string;
  why_applicable: string;
  punishment: string;
}

export interface DefensiveIpcSection {
  section_number: string;
  description: string;
  why_applicable: string;
  punishment: string;
}

export interface AnalysisResponse {
  applicable_ipc_sections: IpcSection[];
  defensive_ipc_sections?: DefensiveIpcSection[];
  severity: 'High' | 'Medium' | 'Low';
  total_sections_identified: number;
  total_defensive_sections?: number;
  analysis_timestamp: string;
}

export interface AnalysisRequest {
  case_description: string;
  incident_date?: string;
  incident_location?: string;
  city?: string;
  state?: string;
  contact_method?: 'email' | 'phone';
  contact_value?: string;
  urgency_level?: 'low' | 'medium' | 'high';
  create_lead?: boolean;
  generate_pdf?: boolean;
  user_type?: string; // Add this field for frontend compatibility
}

export interface OCRResponse {
  success: boolean;
  extracted_text: string;
  confidence: number;
  metadata: {
    word_count: number;
    character_count: number;
    image_size: {
      width: number;
      height: number;
    };
    file_info: {
      name: string;
      size_mb: number;
      format: string;
    };
  };
}

export interface LoginRequest {
  email: string;
  password: string;
  user_role: 'client' | 'lawyer';
}

export interface GoogleLoginRequest {
  access_token: string;
  user_role: 'client' | 'lawyer';
  email?: string;
  first_name?: string;
  last_name?: string;
  google_id?: string;
}

export interface UserProfile {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  full_name: string;
  phone_number?: string;
  user_role: 'client' | 'lawyer';
  email_verified: boolean;
  is_google_user: boolean;
  date_joined: string;
}

export class ApiService {
  private static getAuthToken(): string | null {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('access_token');
    }
    return null;
  }

  private static setAuthToken(token: string): void {
    if (typeof window !== 'undefined') {
      localStorage.setItem('access_token', token);
    }
  }

  private static removeAuthToken(): void {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('access_token');
      localStorage.removeItem('refresh_token');
      localStorage.removeItem('user_profile');
      localStorage.removeItem('juris-logged-in');
    }
  }

  private static async fetchWithTimeout(
    url: string,
    options: RequestInit,
    timeout: number = API_CONFIG.TIMEOUT
  ): Promise<Response> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    // Add auth header if available
    const token = this.getAuthToken();
    const headers: Record<string, string> = {};

    // Only set Content-Type for non-FormData requests
    if (!(options.body instanceof FormData)) {
      headers['Content-Type'] = 'application/json';
    }

    // Add any additional headers from options
    if (options.headers) {
      const optHeaders = options.headers as Record<string, string>;
      Object.assign(headers, optHeaders);
    }

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
        signal: controller.signal,
      });
      clearTimeout(timeoutId);
      return response;
    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  }

  static async healthCheck(): Promise<{ status: string; timestamp: string }> {
    try {
      const response = await this.fetchWithTimeout(
        `${API_CONFIG.BASE_URL}${API_CONFIG.ENDPOINTS.HEALTH_CHECK}`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        },
        10000 // 10 seconds for health check
      );

      if (!response.ok) {
        throw new Error(`Health check failed: ${response.status} ${response.statusText}`);
      }

      const data = await response.json();
      console.log('Health check successful:', data);
      return data;
    } catch (error) {
      console.error('Health check failed:', error);
      throw new ApiError({
        message: 'Unable to connect to analysis service',
        status: 0,
        details: error,
      });
    }
  }

  static async login(request: LoginRequest): Promise<{
    tokens: { access: string; refresh: string };
    user: UserProfile;
    session_key: string;
  }> {
    try {
      const response = await this.fetchWithTimeout(
        `${API_CONFIG.BASE_URL}${API_CONFIG.ENDPOINTS.LOGIN}`,
        {
          method: 'POST',
          body: JSON.stringify(request),
        }
      );

      if (!response.ok) {
        const errorData = await response.json().catch(() => null);
        throw new ApiError({
          message: errorData?.message || 'Login failed',
          status: response.status,
          details: errorData,
        });
      }

      const data = await response.json();
      
      if (data.status === 'success') {
        // Store tokens and user data
        this.setAuthToken(data.data.tokens.access);
        if (typeof window !== 'undefined') {
          localStorage.setItem('refresh_token', data.data.tokens.refresh);
          localStorage.setItem('user_profile', JSON.stringify(data.data.user));
          localStorage.setItem('juris-logged-in', 'true');
        }
        return data.data;
      }

      throw new ApiError({
        message: data.message || 'Login failed',
        details: data,
      });
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError({
        message: 'Login request failed',
        details: error,
      });
    }
  }

  static async googleLogin(request: GoogleLoginRequest): Promise<{
    tokens: { access: string; refresh: string };
    user: UserProfile;
    session_key: string;
    is_new_user: boolean;
  }> {
    try {
      const response = await this.fetchWithTimeout(
        `${API_CONFIG.BASE_URL}${API_CONFIG.ENDPOINTS.GOOGLE_LOGIN}`,
        {
          method: 'POST',
          body: JSON.stringify(request),
        }
      );

      if (!response.ok) {
        const errorData = await response.json().catch(() => null);
        throw new ApiError({
          message: errorData?.message || 'Google login failed',
          status: response.status,
          details: errorData,
        });
      }

      const data = await response.json();
      
      if (data.status === 'success') {
        // Store tokens and user data
        this.setAuthToken(data.data.tokens.access);
        if (typeof window !== 'undefined') {
          localStorage.setItem('refresh_token', data.data.tokens.refresh);
          localStorage.setItem('user_profile', JSON.stringify(data.data.user));
          localStorage.setItem('juris-logged-in', 'true');
        }
        return data.data;
      }

      throw new ApiError({
        message: data.message || 'Google login failed',
        details: data,
      });
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError({
        message: 'Google login request failed',
        details: error,
      });
    }
  }

  static async logout(): Promise<void> {
    try {
      const response = await this.fetchWithTimeout(
        `${API_CONFIG.BASE_URL}${API_CONFIG.ENDPOINTS.LOGOUT}`,
        {
          method: 'POST',
        }
      );

      // Clear local storage regardless of response
      this.removeAuthToken();

      if (!response.ok) {
        console.warn('Logout request failed, but tokens cleared locally');
      }
    } catch (error) {
      // Clear local storage even if request fails
      this.removeAuthToken();
      console.warn('Logout request failed, but tokens cleared locally', error);
    }
  }

  static async getProfile(): Promise<UserProfile> {
    try {
      const response = await this.fetchWithTimeout(
        `${API_CONFIG.BASE_URL}${API_CONFIG.ENDPOINTS.PROFILE}`,
        {
          method: 'GET',
        }
      );

      if (!response.ok) {
        throw new ApiError({
          message: 'Failed to fetch profile',
          status: response.status,
        });
      }

      const data = await response.json();
      
      if (data.status === 'success') {
        // Update stored user profile
        if (typeof window !== 'undefined') {
          localStorage.setItem('user_profile', JSON.stringify(data.data));
        }
        return data.data;
      }

      throw new ApiError({
        message: data.message || 'Failed to fetch profile',
        details: data,
      });
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError({
        message: 'Profile request failed',
        details: error,
      });
    }
  }

  static getCurrentUser(): UserProfile | null {
    if (typeof window !== 'undefined') {
      const profileData = localStorage.getItem('user_profile');
      return profileData ? JSON.parse(profileData) : null;
    }
    return null;
  }

  static isAuthenticated(): boolean {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('juris-logged-in') === 'true' && 
             !!localStorage.getItem('access_token');
    }
    return false;
  }

  static isLawyer(): boolean {
    const user = this.getCurrentUser();
    return user?.user_role === 'lawyer';
  }

  static isClient(): boolean {
    const user = this.getCurrentUser();
    return user?.user_role === 'client';
  }

  static async analyzeCase(request: AnalysisRequest): Promise<AnalysisResponse> {
    try {
      // Remove authentication check since the analyze endpoint might not require it
      // if (!this.isAuthenticated()) {
      //   throw new ApiError({
      //     message: 'Authentication required for case analysis',
      //     status: 401,
      //   });
      // }

      const response = await this.fetchWithTimeout(
        `${API_CONFIG.BASE_URL}${API_CONFIG.ENDPOINTS.ANALYZE_CASE}`,
        {
          method: 'POST',
          body: JSON.stringify(request),
        }
      );

      if (!response.ok) {
        const errorData = await response.json().catch(() => null);
        throw new ApiError({
          message: errorData?.detail || errorData?.message || `Analysis failed: ${response.status}`,
          status: response.status,
          details: errorData,
        });
      }

      const data = await response.json();
      
      // Handle both success response formats
      if (data.status === 'success' && data.data) {
        return data.data;
      }
      
      // Direct response format
      if (data.applicable_ipc_sections || data.analysis) {
        return data;
      }
      
      throw new ApiError({
        message: 'Invalid response format from analysis service',
        details: data,
      });
    } catch (error) {
      console.error('Case analysis failed:', error);
      
      if (error instanceof ApiError) {
        throw error;
      }

      // Handle network errors
      if (error instanceof TypeError && error.message.includes('fetch')) {
        throw new ApiError({
          message: 'Network error: Unable to reach analysis service',
          status: 0,
          details: error,
        });
      }

      // Handle timeout errors
      if (error instanceof Error && error.name === 'AbortError') {
        throw new ApiError({
          message: 'Analysis timeout: The request took too long to complete',
          status: 408,
          details: error,
        });
      }

      throw new ApiError({
        message: 'Unexpected error during analysis',
        details: error,
      });
    }
  }

  static async extractTextFromImage(imageFile: File): Promise<OCRResponse> {
    try {
      if (!this.isAuthenticated()) {
        throw new ApiError({
          message: 'Authentication required for image text extraction',
          status: 401,
        });
      }

      // Create FormData for file upload
      const formData = new FormData();
      formData.append('image', imageFile);

      const response = await this.fetchWithTimeout(
        `${API_CONFIG.BASE_URL}${API_CONFIG.ENDPOINTS.EXTRACT_TEXT}`,
        {
          method: 'POST',
          headers: {
            // Don't set Content-Type for FormData - let browser set it with boundary
          },
          body: formData,
        }
      );

      if (!response.ok) {
        const errorData = await response.json().catch(() => null);
        throw new ApiError({
          message: errorData?.error || `OCR extraction failed: ${response.status}`,
          status: response.status,
          details: errorData,
        });
      }

      const data = await response.json();
      
      if (!data.success) {
        throw new ApiError({
          message: data.error || 'OCR extraction failed',
          details: data,
        });
      }
      
      return data;
    } catch (error) {
      console.error('Image text extraction failed:', error);
      
      if (error instanceof ApiError) {
        throw error;
      }

      // Handle network errors
      if (error instanceof TypeError && error.message.includes('fetch')) {
        throw new ApiError({
          message: 'Network error: Unable to reach OCR service',
          status: 0,
          details: error,
        });
      }

      // Handle timeout errors
      if (error instanceof Error && error.name === 'AbortError') {
        throw new ApiError({
          message: 'OCR timeout: Image processing took too long',
          status: 408,
          details: error,
        });
      }

      throw new ApiError({
        message: 'Unexpected error during image text extraction',
        details: error,
      });
    }
  }

  // Helper method to transform backend response to frontend format
  static transformAnalysisResponse(backendResponse: AnalysisResponse): {
    summary: string;
    legalIssues: string[];
    recommendations: string[];
    severity: 'low' | 'medium' | 'high';
    nextSteps: string[];
    applicableSections: Array<{
      section: string;
      title: string;
      description: string;
      punishment: string;
    }>;
    defensiveSections?: Array<{
      section: string;
      title: string;
      description: string;
      punishment: string;
    }>;
    timeline: string;
    caseType: string;
  } {
    const severityMap = {
      'High': 'high' as const,
      'Medium': 'medium' as const,
      'Low': 'low' as const,
    };

    // Safely handle severity with fallback
    const backendSeverity = backendResponse.severity || 'Medium';
    const mappedSeverity = severityMap[backendSeverity] || 'medium';

    const defensiveSections = backendResponse.defensive_ipc_sections?.map(section => ({
      section: `IPC ${section.section_number}`,
      title: section.description.split(':')[0] || section.description,
      description: section.why_applicable,
      punishment: section.punishment,
    })) || [];

    return {
      summary: `AI analysis identified ${backendResponse.total_sections_identified} applicable IPC sections${backendResponse.total_defensive_sections ? ` and ${backendResponse.total_defensive_sections} defensive sections` : ''} with ${mappedSeverity} severity. This analysis was completed on ${new Date(backendResponse.analysis_timestamp).toLocaleDateString()}.`,
      legalIssues: backendResponse.applicable_ipc_sections.map(section => `IPC ${section.section_number}: ${section.description}`),
      recommendations: [
        'Consult with a qualified legal professional immediately',
        'Document all relevant evidence and maintain records',
        'Gather witness statements if applicable',
        'Preserve any physical or digital evidence',
        'Consider filing a formal complaint with appropriate authorities',
        ...(defensiveSections.length > 0 ? ['Review available defensive strategies with your lawyer'] : []),
      ],
      severity: mappedSeverity,
      nextSteps: [
        'Schedule consultation with recommended lawyers',
        'Prepare comprehensive case documentation',
        'Review applicable legal sections in detail',
        'Consider alternative dispute resolution options',
        ...(defensiveSections.length > 0 ? ['Discuss defensive legal strategies'] : []),
      ],
      applicableSections: backendResponse.applicable_ipc_sections.map(section => ({
        section: `IPC ${section.section_number}`,
        title: section.description.split(':')[0] || section.description,
        description: section.why_applicable,
        punishment: section.punishment,
      })),
      defensiveSections: defensiveSections.length > 0 ? defensiveSections : undefined,
      timeline: mappedSeverity === 'high' ? '1-3 months for urgent action' : 
                mappedSeverity === 'medium' ? '2-6 months for resolution' : 
                '3-12 months for standard proceedings',
      caseType: 'Criminal Law - IPC Analysis',
    };
  }
}

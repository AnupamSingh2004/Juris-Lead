// API configuration for Juris-Lead backend
export const API_CONFIG = {
  BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8001/api/v1',
  ENDPOINTS: {
    ANALYZE_CASE: '/leads/analyze-case/',
    HEALTH_CHECK: '/leads/health/',
    LOGIN: '/auth/login/',
    GOOGLE_LOGIN: '/auth/google-login/',
    LOGOUT: '/auth/logout/',
    PROFILE: '/auth/profile/',
    REFRESH_TOKEN: '/auth/token/refresh/',
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
}

export interface AnalysisResponse {
  applicable_ipc_sections: IpcSection[];
  severity: 'High' | 'Medium' | 'Low';
  total_sections_identified: number;
  analysis_timestamp: string;
}

export interface AnalysisRequest {
  case_description: string;
  user_type: 'citizen' | 'lawyer' | 'law_student' | 'legal_aid';
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
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

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
        },
        10000 // 10 seconds for health check
      );

      if (!response.ok) {
        throw new Error(`Health check failed: ${response.status}`);
      }

      return await response.json();
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
    // Check authentication for analysis
    if (!this.isAuthenticated()) {
      throw new ApiError({
        message: 'Authentication required for case analysis',
        status: 401,
      });
    }

    try {
      // First check if service is healthy
      await this.healthCheck();

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
          message: errorData?.detail || `Analysis failed: ${response.status}`,
          status: response.status,
          details: errorData,
        });
      }

      const data = await response.json();
      
      // Validate response structure
      if (!data.applicable_ipc_sections || !Array.isArray(data.applicable_ipc_sections)) {
        throw new ApiError({
          message: 'Invalid response format from analysis service',
          details: data,
        });
      }

      return data;
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
    }>;
    timeline: string;
    caseType: string;
  } {
    const severityMap = {
      'High': 'high' as const,
      'Medium': 'medium' as const,
      'Low': 'low' as const,
    };

    return {
      summary: `AI analysis identified ${backendResponse.total_sections_identified} applicable IPC sections with ${backendResponse.severity.toLowerCase()} severity. This analysis was completed on ${new Date(backendResponse.analysis_timestamp).toLocaleDateString()}.`,
      legalIssues: backendResponse.applicable_ipc_sections.map(section => `IPC ${section.section_number}: ${section.description}`),
      recommendations: [
        'Consult with a qualified legal professional immediately',
        'Document all relevant evidence and maintain records',
        'Gather witness statements if applicable',
        'Preserve any physical or digital evidence',
        'Consider filing a formal complaint with appropriate authorities',
      ],
      severity: severityMap[backendResponse.severity],
      nextSteps: [
        'Schedule consultation with recommended lawyers',
        'Prepare comprehensive case documentation',
        'Review applicable legal sections in detail',
        'Consider alternative dispute resolution options',
      ],
      applicableSections: backendResponse.applicable_ipc_sections.map(section => ({
        section: `IPC ${section.section_number}`,
        title: section.description.split(':')[0] || section.description,
        description: section.why_applicable,
      })),
      timeline: backendResponse.severity === 'High' ? '1-3 months for urgent action' : 
                backendResponse.severity === 'Medium' ? '2-6 months for resolution' : 
                '3-12 months for standard proceedings',
      caseType: 'Criminal Law - IPC Analysis',
    };
  }
}

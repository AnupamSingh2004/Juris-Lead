import { useState, useEffect } from 'react'

// Types
export interface ActivityRecord {
  id: string
  activity_type: string
  activity_type_display: string
  title: string
  description: string
  status: string
  status_display: string
  result_data?: any
  file_name?: string
  file_size?: number
  file_type?: string
  created_at: string
  duration_seconds?: number
  time_ago: string
  icon_name: string
  page_url?: string
  additional_data?: any
}

export interface UserAnalytics {
  total_analyses: number
  total_documents_processed: number
  total_cases_created: number
  total_lawyer_searches: number
  total_legal_research: number
  total_time_spent_minutes: number
  last_activity_date?: string
  total_files_uploaded: number
  total_file_size_mb: number
  monthly_analyses: number
  monthly_documents: number
  monthly_cases: number
  updated_at: string
}

export interface HistoryFilters {
  activity_type?: string
  status?: string
  date_from?: string
  date_to?: string
  period?: string
  search?: string
  page?: number
  page_size?: number
}

export interface HistoryResponse {
  results: ActivityRecord[]
  count: number
  next?: string
  previous?: string
  summary: {
    total_activities: number
    activity_breakdown: Array<{ activity_type: string; count: number }>
    status_breakdown: Array<{ status: string; count: number }>
  }
}

export interface CreateActivityData {
  activity_type: string
  title: string
  description?: string
  status?: string
  result_data?: any
  file_name?: string
  file_size?: number
  file_type?: string
  duration_seconds?: number
  page_url?: string
  referrer_url?: string
  additional_data?: any
}

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8001/api/v1'

export const useHistory = () => {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const getAuthHeaders = () => {
    const token = localStorage.getItem('access_token') // Use correct token key
    return {
      'Content-Type': 'application/json',
      'Authorization': token ? `Bearer ${token}` : '',
    }
  }

  const fetchHistory = async (filters: HistoryFilters = {}): Promise<HistoryResponse> => {
    setLoading(true)
    setError(null)
    
    try {
      const params = new URLSearchParams()
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== undefined && value !== '') {
          params.append(key, value.toString())
        }
      })

      const response = await fetch(`${API_BASE}/auth/history/activities/?${params}`, {
        headers: getAuthHeaders(),
      })

      if (!response.ok) {
        throw new Error('Failed to fetch history')
      }

      const data = await response.json()
      return data
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error occurred'
      setError(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  const createActivity = async (activityData: CreateActivityData): Promise<ActivityRecord> => {
    setLoading(true)
    setError(null)
    
    try {
      const response = await fetch(`${API_BASE}/auth/history/activities/create/`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify(activityData),
      })

      if (!response.ok) {
        throw new Error('Failed to create activity record')
      }

      const data = await response.json()
      return data.data
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error occurred'
      setError(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  const getAnalytics = async (): Promise<UserAnalytics> => {
    setLoading(true)
    setError(null)
    
    try {
      const response = await fetch(`${API_BASE}/auth/history/analytics/`, {
        headers: getAuthHeaders(),
      })

      if (!response.ok) {
        throw new Error('Failed to fetch analytics')
      }

      const data = await response.json()
      return data.data.analytics
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error occurred'
      setError(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  const getActivityTypes = async (): Promise<Array<{ value: string; label: string }>> => {
    try {
      const response = await fetch(`${API_BASE}/auth/history/activities/types/`, {
        headers: getAuthHeaders(),
      })

      if (!response.ok) {
        throw new Error('Failed to fetch activity types')
      }

      const data = await response.json()
      return data.data
    } catch (err) {
      console.error('Error fetching activity types:', err)
      return []
    }
  }

  const clearHistory = async (days?: number): Promise<void> => {
    setLoading(true)
    setError(null)
    
    try {
      const params = days ? `?days=${days}` : ''
      const response = await fetch(`${API_BASE}/auth/history/activities/clear/${params}`, {
        method: 'DELETE',
        headers: getAuthHeaders(),
      })

      if (!response.ok) {
        throw new Error('Failed to clear history')
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error occurred'
      setError(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  const exportHistory = async (filters: HistoryFilters = {}): Promise<ActivityRecord[]> => {
    setLoading(true)
    setError(null)
    
    try {
      const params = new URLSearchParams()
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== undefined && value !== '') {
          params.append(key, value.toString())
        }
      })

      const response = await fetch(`${API_BASE}/auth/history/activities/export/?${params}`, {
        headers: getAuthHeaders(),
      })

      if (!response.ok) {
        throw new Error('Failed to export history')
      }

      const data = await response.json()
      return data.data
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error occurred'
      setError(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  return {
    loading,
    error,
    fetchHistory,
    createActivity,
    getAnalytics,
    getActivityTypes,
    clearHistory,
    exportHistory,
  }
}

// Hook for tracking activities automatically
export const useActivityTracker = () => {
  const { createActivity } = useHistory()

  const trackActivity = async (
    activityType: string,
    title: string,
    options: Partial<CreateActivityData> = {}
  ) => {
    try {
      const startTime = Date.now()
      
      await createActivity({
        activity_type: activityType,
        title,
        page_url: window.location.href,
        referrer_url: document.referrer,
        duration_seconds: Math.floor((Date.now() - startTime) / 1000),
        ...options,
      })
    } catch (err) {
      console.error('Error tracking activity:', err)
      // Re-throw the error so the caller can handle it (e.g., fallback to localStorage)
      throw err
    }
  }

  const trackPageView = (pageName: string) => {
    trackActivity('dashboard_view', `Viewed ${pageName}`, {
      status: 'success',
      additional_data: { page_name: pageName }
    })
  }

  const trackDocumentAnalysis = (fileName: string, fileSize?: number, fileType?: string) => {
    trackActivity('document_analysis', `Analyzed document: ${fileName}`, {
      file_name: fileName,
      file_size: fileSize,
      file_type: fileType,
      status: 'success'
    })
  }

  const trackCaseAnalysis = (caseType: string, result?: any) => {
    trackActivity('case_analysis', `Analyzed ${caseType} case`, {
      result_data: result,
      status: 'success'
    })
  }

  const trackLawyerSearch = (searchTerms: string, resultCount?: number) => {
    trackActivity('lawyer_search', `Searched for lawyers: ${searchTerms}`, {
      additional_data: { search_terms: searchTerms, result_count: resultCount },
      status: 'success'
    })
  }

  return {
    trackActivity,
    trackPageView,
    trackDocumentAnalysis,
    trackCaseAnalysis,
    trackLawyerSearch,
  }
}

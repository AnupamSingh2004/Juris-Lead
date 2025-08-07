"use client"

import { useState, useEffect } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Calendar } from "@/components/ui/calendar"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { useHistory, type ActivityRecord, type HistoryFilters } from "@/hooks/use-history"
import { withAuth } from "@/lib/auth-context"
import { format } from "date-fns"
import {
  FileText,
  Scale,
  BookOpen,
  Search,
  Users,
  Calendar as CalendarIcon,
  Filter,
  Download,
  Trash2,
  Eye,
  Clock,
  CheckCircle,
  AlertTriangle,
  XCircle,
  BarChart3,
  TrendingUp,
  Activity,
  RefreshCw,
  ExternalLink
} from "lucide-react"

const ACTIVITY_ICONS: Record<string, any> = {
  document_analysis: FileText,
  case_analysis: Scale,
  ipc_analysis: BookOpen,
  case_creation: Scale,
  case_update: Scale,
  case_search: Search,
  lawyer_search: Users,
  lawyer_contact: Users,
  consultation_request: Calendar,
  document_upload: FileText,
  document_summarization: FileText,
  document_download: Download,
  legal_case_study: BookOpen,
  ipc_section_study: BookOpen,
  legal_research: Search,
  login: Activity,
  logout: Activity,
  profile_update: Activity,
  dashboard_view: BarChart3,
  analytics_view: TrendingUp,
  report_generation: FileText,
}

const STATUS_COLORS = {
  success: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300",
  failed: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300",
  pending: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300",
  cancelled: "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300",
}

const STATUS_ICONS = {
  success: CheckCircle,
  failed: XCircle,
  pending: Clock,
  cancelled: AlertTriangle,
}

// Component to display document summary in a nice format
const SummaryDisplay = ({ summary }: { summary: any }) => {
  if (!summary?.summary) {
    return <p className="text-gray-500 dark:text-gray-400">No summary data available</p>
  }

  const summaryData = summary.summary

  return (
    <div className="space-y-4">
      {/* Quick Info */}
      <div className="flex flex-wrap gap-2 mb-4">
        <Badge className="bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300">
          {summaryData.document_type}
        </Badge>
        <Badge className="bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300">
          {summaryData.urgency_level} Priority
        </Badge>
        <Badge className="bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300">
          {summaryData.language_complexity} Complexity
        </Badge>
      </div>

      {/* Simple Summary */}
      <div>
        <h4 className="font-semibold text-gray-900 dark:text-white mb-2">Simple Summary</h4>
        <p className="text-sm text-gray-600 dark:text-gray-300 leading-relaxed">
          {summaryData.simple_summary}
        </p>
      </div>

      {/* Key Points */}
      {summaryData.key_points && summaryData.key_points.length > 0 && (
        <div>
          <h4 className="font-semibold text-gray-900 dark:text-white mb-2">Key Points</h4>
          <ul className="text-sm space-y-1">
            {summaryData.key_points.slice(0, 3).map((point: string, index: number) => (
              <li key={index} className="flex items-start gap-2 text-gray-600 dark:text-gray-300">
                <span className="w-1.5 h-1.5 bg-blue-500 rounded-full mt-2 flex-shrink-0" />
                {point}
              </li>
            ))}
            {summaryData.key_points.length > 3 && (
              <li className="text-xs text-gray-500 dark:text-gray-400 italic">
                +{summaryData.key_points.length - 3} more points
              </li>
            )}
          </ul>
        </div>
      )}

      {/* Action Required */}
      {summaryData.action_required && (
        <div>
          <h4 className="font-semibold text-gray-900 dark:text-white mb-2">Action Required</h4>
          <p className="text-sm text-gray-600 dark:text-gray-300">
            {summaryData.action_required}
          </p>
        </div>
      )}

      {/* Metadata */}
      {summary.metadata && (
        <div className="pt-2 border-t border-gray-200 dark:border-gray-700">
          <div className="flex gap-4 text-xs text-gray-500 dark:text-gray-400">
            {summary.metadata.word_count && (
              <span>{summary.metadata.word_count} words</span>
            )}
            {summary.metadata.character_count && (
              <span>{summary.metadata.character_count} characters</span>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

function HistoryPage() {
  const [activities, setActivities] = useState<ActivityRecord[]>([])
  const [loading, setLoading] = useState(true)
  const [filters, setFilters] = useState<HistoryFilters>({})
  const [totalCount, setTotalCount] = useState(0)
  const [currentPage, setCurrentPage] = useState(1)
  const [activityTypes, setActivityTypes] = useState<Array<{ value: string; label: string }>>([])
  const [selectedActivity, setSelectedActivity] = useState<ActivityRecord | null>(null)
  const [dateRange, setDateRange] = useState<{ from?: Date; to?: Date }>({})
  const [searchTerm, setSearchTerm] = useState("")

  const { fetchHistory, getActivityTypes, clearHistory, exportHistory, error } = useHistory()

  useEffect(() => {
    loadActivityTypes()
    loadHistory()
  }, [])

  useEffect(() => {
    const delayedSearch = setTimeout(() => {
      loadHistory()
    }, 500)

    return () => clearTimeout(delayedSearch)
  }, [filters, currentPage])

  const loadActivityTypes = async () => {
    try {
      const types = await getActivityTypes()
      setActivityTypes(types)
    } catch (err) {
      console.error("Error loading activity types:", err)
    }
  }

  const loadHistory = async () => {
    setLoading(true)
    try {
      const response = await fetchHistory({
        ...filters,
        page: currentPage,
        page_size: 20,
        search: searchTerm || undefined,
        date_from: dateRange.from ? format(dateRange.from, 'yyyy-MM-dd') : undefined,
        date_to: dateRange.to ? format(dateRange.to, 'yyyy-MM-dd') : undefined,
      })
      
      setActivities(response.results)
      setTotalCount(response.count)
    } catch (err) {
      console.error("Error loading history:", err)
    } finally {
      setLoading(false)
    }
  }

  const handleFilterChange = (key: keyof HistoryFilters, value: string) => {
    setFilters(prev => ({
      ...prev,
      [key]: value || undefined
    }))
    setCurrentPage(1)
  }

  const handleSearch = (value: string) => {
    setSearchTerm(value)
    setCurrentPage(1)
  }

  const handleClearHistory = async () => {
    if (confirm("Are you sure you want to clear your history? This action cannot be undone.")) {
      try {
        await clearHistory()
        loadHistory()
      } catch (err) {
        console.error("Error clearing history:", err)
        alert("Failed to clear history. Please try again.")
      }
    }
  }

  const handleExportHistory = async () => {
    try {
      const data = await exportHistory(filters)
      const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `juris-lead-history-${format(new Date(), 'yyyy-MM-dd')}.json`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    } catch (err) {
      console.error("Error exporting history:", err)
      alert("Failed to export history. Please try again.")
    }
  }

  const getActivityIcon = (activityType: string) => {
    const IconComponent = ACTIVITY_ICONS[activityType] || Activity
    return <IconComponent className="w-5 h-5" />
  }

  const getStatusIcon = (status: string) => {
    const IconComponent = STATUS_ICONS[status as keyof typeof STATUS_ICONS] || Activity
    return <IconComponent className="w-4 h-4" />
  }

  const formatFileSize = (bytes?: number) => {
    if (!bytes) return ""
    const sizes = ["B", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(1024))
    return `${(bytes / Math.pow(1024, i)).toFixed(1)} ${sizes[i]}`
  }

  const totalPages = Math.ceil(totalCount / 20)

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 dark:from-slate-900 dark:to-slate-800">
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-3 bg-primary/10 rounded-xl">
              <Clock className="w-8 h-8 text-primary" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
                My History
              </h1>
              <p className="text-gray-600 dark:text-gray-300">
                Complete record of your legal analyses and document summaries
              </p>
            </div>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
            <Card className="p-6">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                  <BarChart3 className="w-6 h-6 text-blue-600 dark:text-blue-400" />
                </div>
                <div>
                  <p className="text-sm text-gray-600 dark:text-gray-400">Total Activities</p>
                  <p className="text-2xl font-bold text-gray-900 dark:text-white">{totalCount}</p>
                </div>
              </div>
            </Card>

            <Card className="p-6">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                  <CheckCircle className="w-6 h-6 text-green-600 dark:text-green-400" />
                </div>
                <div>
                  <p className="text-sm text-gray-600 dark:text-gray-400">Successful</p>
                  <p className="text-2xl font-bold text-gray-900 dark:text-white">
                    {activities.filter(a => a.status === 'success').length}
                  </p>
                </div>
              </div>
            </Card>

            <Card className="p-6">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                  <TrendingUp className="w-6 h-6 text-purple-600 dark:text-purple-400" />
                </div>
                <div>
                  <p className="text-sm text-gray-600 dark:text-gray-400">This Month</p>
                  <p className="text-2xl font-bold text-gray-900 dark:text-white">
                    {activities.filter(a => {
                      const activityDate = new Date(a.created_at)
                      const now = new Date()
                      return activityDate.getMonth() === now.getMonth() && 
                             activityDate.getFullYear() === now.getFullYear()
                    }).length}
                  </p>
                </div>
              </div>
            </Card>
          </div>
        </div>

        {/* Filters */}
        <Card className="p-6 mb-6">
          <div className="flex flex-col lg:flex-row gap-4">
            {/* Search */}
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                <Input
                  placeholder="Search your history..."
                  value={searchTerm}
                  onChange={(e) => handleSearch(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>

            {/* Activity Type Filter */}
            <Select value={filters.activity_type || "all"} onValueChange={(value) => handleFilterChange('activity_type', value === "all" ? "" : value)}>
              <SelectTrigger className="w-full lg:w-48">
                <SelectValue placeholder="All Activities" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Activities</SelectItem>
                {activityTypes.map((type) => (
                  <SelectItem key={type.value} value={type.value}>
                    {type.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {/* Status Filter */}
            <Select value={filters.status || "all"} onValueChange={(value) => handleFilterChange('status', value === "all" ? "" : value)}>
              <SelectTrigger className="w-full lg:w-32">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Status</SelectItem>
                <SelectItem value="success">Success</SelectItem>
                <SelectItem value="failed">Failed</SelectItem>
                <SelectItem value="pending">Pending</SelectItem>
                <SelectItem value="cancelled">Cancelled</SelectItem>
              </SelectContent>
            </Select>

            {/* Period Filter */}
            <Select value={filters.period || "all"} onValueChange={(value) => handleFilterChange('period', value === "all" ? "" : value)}>
              <SelectTrigger className="w-full lg:w-32">
                <SelectValue placeholder="Period" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Time</SelectItem>
                <SelectItem value="today">Today</SelectItem>
                <SelectItem value="week">This Week</SelectItem>
                <SelectItem value="month">This Month</SelectItem>
                <SelectItem value="year">This Year</SelectItem>
              </SelectContent>
            </Select>

            {/* Actions */}
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={loadHistory} disabled={loading}>
                <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              </Button>
              <Button variant="outline" size="sm" onClick={handleExportHistory}>
                <Download className="w-4 h-4" />
              </Button>
              <Button variant="destructive" size="sm" onClick={handleClearHistory}>
                <Trash2 className="w-4 h-4" />
              </Button>
            </div>
          </div>
        </Card>

        {/* Activities List */}
        <div className="space-y-4">
          {loading ? (
            <div className="flex justify-center py-12">
              <RefreshCw className="w-8 h-8 animate-spin text-primary" />
            </div>
          ) : activities.length === 0 ? (
            <Card className="p-12 text-center">
              <Activity className="w-16 h-16 text-gray-400 mx-auto mb-4" />
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                No activities found
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Start using the analyzer or document summarizer to see your history here.
              </p>
            </Card>
          ) : (
            activities.map((activity) => (
              <Card key={activity.id} className="p-6 hover:shadow-lg transition-shadow cursor-pointer">
                <div className="flex items-start gap-4">
                  {/* Icon */}
                  <div className="p-3 bg-primary/10 rounded-xl shrink-0">
                    {getActivityIcon(activity.activity_type)}
                  </div>

                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex-1">
                        <h3 className="font-semibold text-gray-900 dark:text-white mb-1 truncate">
                          {activity.title}
                        </h3>
                        <p className="text-sm text-gray-600 dark:text-gray-400 mb-2">
                          {activity.description}
                        </p>
                        
                        {/* Metadata */}
                        <div className="flex flex-wrap items-center gap-3 text-xs text-gray-500 dark:text-gray-400">
                          <span className="flex items-center gap-1">
                            <Clock className="w-3 h-3" />
                            {activity.time_ago}
                          </span>
                          
                          {activity.file_name && (
                            <span className="flex items-center gap-1">
                              <FileText className="w-3 h-3" />
                              {activity.file_name}
                              {activity.file_size && ` (${formatFileSize(activity.file_size)})`}
                            </span>
                          )}
                          
                          {activity.duration_seconds && (
                            <span className="flex items-center gap-1">
                              <Clock className="w-3 h-3" />
                              {Math.floor(activity.duration_seconds / 60)}m {activity.duration_seconds % 60}s
                            </span>
                          )}
                        </div>
                      </div>

                      {/* Status and Actions */}
                      <div className="flex items-center gap-2 shrink-0">
                        <Badge className={STATUS_COLORS[activity.status as keyof typeof STATUS_COLORS]}>
                          <span className="flex items-center gap-1">
                            {getStatusIcon(activity.status)}
                            {activity.status_display}
                          </span>
                        </Badge>
                        
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setSelectedActivity(activity)}
                        >
                          <Eye className="w-4 h-4" />
                        </Button>
                      </div>
                    </div>
                  </div>
                </div>
              </Card>
            ))
          )}
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex justify-center gap-2 mt-8">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
              disabled={currentPage === 1}
            >
              Previous
            </Button>
            
            <span className="flex items-center px-4 text-sm text-gray-600 dark:text-gray-400">
              Page {currentPage} of {totalPages}
            </span>
            
            <Button
              variant="outline"
              size="sm"
              onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
              disabled={currentPage === totalPages}
            >
              Next
            </Button>
          </div>
        )}

        {/* Activity Detail Modal */}
        {selectedActivity && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
            <Card className="max-w-2xl w-full max-h-[80vh] overflow-y-auto">
              <div className="p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="p-2 bg-primary/10 rounded-lg">
                      {getActivityIcon(selectedActivity.activity_type)}
                    </div>
                    <div>
                      <h2 className="text-xl font-semibold text-gray-900 dark:text-white">
                        {selectedActivity.title}
                      </h2>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        {selectedActivity.activity_type_display}
                      </p>
                    </div>
                  </div>
                  <Button variant="ghost" size="sm" onClick={() => setSelectedActivity(null)}>
                    <XCircle className="w-5 h-5" />
                  </Button>
                </div>

                <div className="space-y-4">
                  <div>
                    <h3 className="font-medium text-gray-900 dark:text-white mb-2">Details</h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      {selectedActivity.description}
                    </p>
                  </div>

                  {selectedActivity.result_data && (
                    <div>
                      <h3 className="font-medium text-gray-900 dark:text-white mb-2">Results</h3>
                      {selectedActivity.activity_type === 'document_summarization' ? (
                        <SummaryDisplay summary={selectedActivity.result_data} />
                      ) : (
                        <pre className="text-xs bg-gray-100 dark:bg-gray-800 p-3 rounded-lg overflow-x-auto">
                          {JSON.stringify(selectedActivity.result_data, null, 2)}
                        </pre>
                      )}
                    </div>
                  )}

                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="font-medium text-gray-900 dark:text-white">Status:</span>
                      <Badge className={`ml-2 ${STATUS_COLORS[selectedActivity.status as keyof typeof STATUS_COLORS]}`}>
                        {selectedActivity.status_display}
                      </Badge>
                    </div>
                    <div>
                      <span className="font-medium text-gray-900 dark:text-white">Date:</span>
                      <span className="ml-2 text-gray-600 dark:text-gray-400">
                        {format(new Date(selectedActivity.created_at), 'PPpp')}
                      </span>
                    </div>
                    {selectedActivity.file_name && (
                      <div>
                        <span className="font-medium text-gray-900 dark:text-white">File:</span>
                        <span className="ml-2 text-gray-600 dark:text-gray-400">
                          {selectedActivity.file_name}
                          {selectedActivity.file_size && ` (${formatFileSize(selectedActivity.file_size)})`}
                        </span>
                      </div>
                    )}
                    {selectedActivity.duration_seconds && (
                      <div>
                        <span className="font-medium text-gray-900 dark:text-white">Duration:</span>
                        <span className="ml-2 text-gray-600 dark:text-gray-400">
                          {Math.floor(selectedActivity.duration_seconds / 60)}m {selectedActivity.duration_seconds % 60}s
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </Card>
          </div>
        )}
      </div>
    </div>
  )
}

export default withAuth(HistoryPage)

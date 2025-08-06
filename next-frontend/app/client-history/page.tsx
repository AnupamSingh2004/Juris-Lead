"use client"

import { useState, useEffect } from "react"
import { motion } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { Navigation } from "@/components/navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { useHistory, type ActivityRecord, type HistoryFilters } from "@/hooks/use-history"
import { withAuth } from "@/lib/auth-context"
import { format } from "date-fns"
import { History, FileText, BarChart3, Clock, Trash2, Search, Calendar, Download, Eye, ArrowRight, RefreshCw, CheckCircle, XCircle, AlertTriangle, X, Scale } from "lucide-react"

// Map backend activity types to frontend types
const mapActivityType = (activityType: string): "analysis" | "summary" => {
  if (activityType.includes('analysis') || activityType.includes('case')) {
    return "analysis"
  }
  return "summary"
}

const getStatusIcon = (status: string) => {
  switch (status) {
    case 'success':
      return CheckCircle
    case 'failed':
      return XCircle
    case 'pending':
      return Clock
    default:
      return AlertTriangle
  }
}

function ClientHistory() {
  const [activities, setActivities] = useState<ActivityRecord[]>([])
  const [filteredHistory, setFilteredHistory] = useState<ActivityRecord[]>([])
  const [searchTerm, setSearchTerm] = useState("")
  const [filterType, setFilterType] = useState<"all" | "analysis" | "summary">("all")
  const [loading, setLoading] = useState(true)
  const [selectedItem, setSelectedItem] = useState<ActivityRecord | null>(null)
  const [showViewModal, setShowViewModal] = useState(false)
  const [stats, setStats] = useState({
    totalAnalyses: 0,
    totalSummaries: 0,
    thisMonth: 0,
  })

  const { fetchHistory, clearHistory, error } = useHistory()

  // Load history from backend database
  const loadHistory = async () => {
    setLoading(true)
    try {
      const response = await fetchHistory({
        page: 1,
        page_size: 100, // Load more items for client-side filtering
      })
      
      setActivities(response.results)
      
      // Calculate stats from backend data
      const analyses = response.results.filter((item: ActivityRecord) => 
        mapActivityType(item.activity_type) === "analysis"
      ).length
      const summaries = response.results.filter((item: ActivityRecord) => 
        mapActivityType(item.activity_type) === "summary"
      ).length

      const thisMonth = response.results.filter((item: ActivityRecord) => {
        try {
          const itemDate = new Date(item.created_at)
          const now = new Date()
          return itemDate.getMonth() === now.getMonth() && itemDate.getFullYear() === now.getFullYear()
        } catch {
          return false
        }
      }).length

      setStats({
        totalAnalyses: analyses,
        totalSummaries: summaries,
        thisMonth,
      })
    } catch (err) {
      console.error("Error loading history:", err)
      // Fallback to localStorage for backward compatibility
      try {
        const savedHistory = JSON.parse(localStorage.getItem("juris-history") || "[]")
        const validHistory = savedHistory.filter(
          (item: any) =>
            item &&
            typeof item.id === "string" &&
            typeof item.type === "string" &&
            typeof item.title === "string" &&
            typeof item.timestamp === "string",
        )
        
        // Convert localStorage format to ActivityRecord format
        const convertedHistory: ActivityRecord[] = validHistory.map((item: any) => ({
          id: item.id,
          activity_type: item.type === 'analysis' ? 'document_analysis' : 'document_summarization',
          activity_type_display: item.type === 'analysis' ? 'Document Analysis' : 'Document Summarization',
          title: item.title,
          description: item.title,
          status: item.status === 'completed' ? 'success' : item.status || 'success',
          status_display: item.status === 'completed' ? 'Success' : item.status || 'Success',
          created_at: item.timestamp,
          time_ago: formatTimeAgo(item.timestamp),
          result_data: item.data,
          file_name: item.data?.fileName,
          file_size: item.data?.fileSize,
          duration_seconds: null,
        }))
        
        setActivities(convertedHistory)
        
        const analyses = convertedHistory.filter(item => mapActivityType(item.activity_type) === "analysis").length
        const summaries = convertedHistory.filter(item => mapActivityType(item.activity_type) === "summary").length
        const thisMonth = convertedHistory.filter((item: ActivityRecord) => {
          try {
            const itemDate = new Date(item.created_at)
            const now = new Date()
            return itemDate.getMonth() === now.getMonth() && itemDate.getFullYear() === now.getFullYear()
          } catch {
            return false
          }
        }).length

        setStats({
          totalAnalyses: analyses,
          totalSummaries: summaries,
          thisMonth,
        })
      } catch (localError) {
        console.error("Error loading localStorage fallback:", localError)
        setActivities([])
        setStats({ totalAnalyses: 0, totalSummaries: 0, thisMonth: 0 })
      }
    } finally {
      setLoading(false)
    }
  }

  const formatTimeAgo = (timestamp: string) => {
    try {
      const date = new Date(timestamp)
      const now = new Date()
      const diffInMs = now.getTime() - date.getTime()
      const diffInHours = Math.floor(diffInMs / (1000 * 60 * 60))
      const diffInDays = Math.floor(diffInHours / 24)
      
      if (diffInDays > 0) {
        return `${diffInDays} day${diffInDays > 1 ? 's' : ''} ago`
      } else if (diffInHours > 0) {
        return `${diffInHours} hour${diffInHours > 1 ? 's' : ''} ago`
      } else {
        return 'Less than an hour ago'
      }
    } catch {
      return 'Unknown'
    }
  }

  useEffect(() => {
    loadHistory()
  }, [])

  useEffect(() => {
    // Filter activities client-side
    try {
      let filtered = [...activities]

      // Filter by search term
      if (searchTerm && searchTerm.trim()) {
        filtered = filtered.filter((item) => 
          item.title && item.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
          item.description && item.description.toLowerCase().includes(searchTerm.toLowerCase())
        )
      }

      // Filter by type
      if (filterType !== "all") {
        filtered = filtered.filter((item) => mapActivityType(item.activity_type) === filterType)
      }

      setFilteredHistory(filtered)
    } catch (error) {
      console.error("Error filtering history:", error)
      setFilteredHistory([])
    }
  }, [activities, searchTerm, filterType])

  const deleteHistoryItem = async (id: string) => {
    try {
      // For now, just remove from local state since we don't have delete endpoint
      const updatedActivities = activities.filter((item) => item.id !== id)
      setActivities(updatedActivities)
      
      // Also remove from localStorage if it exists there
      const savedHistory = JSON.parse(localStorage.getItem("juris-history") || "[]")
      const updatedLocalHistory = savedHistory.filter((item: any) => item.id !== id)
      localStorage.setItem("juris-history", JSON.stringify(updatedLocalHistory))
    } catch (error) {
      console.error("Error deleting history item:", error)
      alert("Failed to delete item. Please try again.")
    }
  }

  const restoreSession = (item: ActivityRecord) => {
    try {
      const itemType = mapActivityType(item.activity_type)
      if (itemType === "analysis") {
        window.location.href = `/analyzer?restore=${item.id}`
      } else {
        window.location.href = `/summarizer?restore=${item.id}`
      }
    } catch (error) {
      console.error("Error restoring session:", error)
      alert("Failed to restore session. Please try again.")
    }
  }

  const viewAnalysis = (item: ActivityRecord) => {
    setSelectedItem(item)
    setShowViewModal(true)
  }

  const closeViewModal = () => {
    setShowViewModal(false)
    setSelectedItem(null)
  }

  const formatDate = (timestamp: string) => {
    try {
      return new Date(timestamp).toLocaleDateString("en-IN", {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      })
    } catch {
      return "Invalid date"
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "success":
      case "completed":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      case "pending":
      case "processing":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
      case "failed":
        return "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    }
  }

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <Navigation />

        <main className="pt-24 pb-16">
          <div className="max-w-7xl mx-auto px-6">
            {/* Header */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8">
              <div className="flex items-center gap-4 mb-4">
                <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                  <History className="w-8 h-8 text-[#007BFF] dark:text-[#00FFFF]" />
                </div>
                <div>
                  <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-[#E0E6F1]">My History</h1>
                  <p className="text-xl text-gray-600 dark:text-gray-300">
                    Complete record of your legal analyses and document summaries
                  </p>
                </div>
              </div>
            </motion.div>

            {/* Stats Overview */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8"
            >
              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                    <BarChart3 className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-300">Total Analyses</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">{stats.totalAnalyses}</p>
                  </div>
                </div>
              </Card>

              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                    <FileText className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-300">Total Summaries</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">{stats.totalSummaries}</p>
                  </div>
                </div>
              </Card>

              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                    <Calendar className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-300">This Month</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">{stats.thisMonth}</p>
                  </div>
                </div>
              </Card>
            </motion.div>

            {/* Search and Filter */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="mb-8"
            >
              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                <div className="flex flex-col md:flex-row gap-4">
                  <div className="flex-1 relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                    <Input
                      placeholder="Search your history..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10 bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan"
                    />
                  </div>

                  <div className="flex gap-2">
                    <Button
                      variant={filterType === "all" ? "default" : "outline"}
                      onClick={() => setFilterType("all")}
                      className={
                        filterType === "all"
                          ? "bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white dark:glow-cyan"
                          : "border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                      }
                    >
                      All
                    </Button>
                    <Button
                      variant={filterType === "analysis" ? "default" : "outline"}
                      onClick={() => setFilterType("analysis")}
                      className={
                        filterType === "analysis"
                          ? "bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white dark:glow-cyan"
                          : "border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                      }
                    >
                      <BarChart3 className="w-4 h-4 mr-2" />
                      Analyses
                    </Button>
                    <Button
                      variant={filterType === "summary" ? "default" : "outline"}
                      onClick={() => setFilterType("summary")}
                      className={
                        filterType === "summary"
                          ? "bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white dark:glow-cyan"
                          : "border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                      }
                    >
                      <FileText className="w-4 h-4 mr-2" />
                      Summaries
                    </Button>
                  </div>
                </div>
              </Card>
            </motion.div>

            {/* History List */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                {filteredHistory.length === 0 ? (
                  <div className="text-center py-12">
                    <History className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">
                      {searchTerm || filterType !== "all" ? "No matching results" : "No history yet"}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-300 mb-6">
                      {searchTerm || filterType !== "all"
                        ? "Try adjusting your search or filter criteria"
                        : "Start by analyzing an incident or summarizing a document"}
                    </p>
                    {!searchTerm && filterType === "all" && (
                      <div className="flex gap-4 justify-center">
                        <Button
                          onClick={() => (window.location.href = "/analyzer")}
                          className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                        >
                          Start Analysis
                        </Button>
                        <Button
                          onClick={() => (window.location.href = "/summarizer")}
                          variant="outline"
                          className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover"
                        >
                          Summarize Document
                        </Button>
                      </div>
                    )}
                  </div>
                ) : (
                  <div className="space-y-4">
                    {filteredHistory.map((item, index) => (
                      <motion.div
                        key={item.id}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.1 * index }}
                        className="p-6 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg border border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF] dark:hover:border-[#00FFFF] transition-all duration-300 prestigious-hover"
                      >
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="flex items-center gap-4 mb-3">
                              <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                                {mapActivityType(item.activity_type) === "analysis" ? (
                                  <BarChart3 className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                                ) : (
                                  <FileText className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                                )}
                              </div>
                              <div className="flex-1">
                                <h4 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-1">
                                  {item.title}
                                </h4>
                                <div className="flex items-center gap-3">
                                  <Badge
                                    variant="outline"
                                    className="border-gray-300 dark:border-[#1B263B] text-gray-600 dark:text-gray-300"
                                  >
                                    {mapActivityType(item.activity_type) === "analysis" ? "Incident Analysis" : "Document Summary"}
                                  </Badge>
                                  <Badge className={getStatusColor(item.status)}>
                                    {item.status_display}
                                  </Badge>
                                </div>
                              </div>
                            </div>

                            <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-300">
                              <div className="flex items-center gap-1">
                                <Clock className="w-4 h-4" />
                                {formatDate(item.created_at)}
                              </div>
                              {item.time_ago && (
                                <div className="flex items-center gap-1">
                                  <span>{item.time_ago}</span>
                                </div>
                              )}
                            </div>
                          </div>

                          <div className="flex gap-2 ml-4">
                            <Button
                              size="sm"
                              onClick={() => viewAnalysis(item)}
                              className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                            >
                              <Eye className="w-4 h-4 mr-1" />
                              View
                            </Button>
                            <Button
                              size="sm"
                              variant="outline"
                              className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                            >
                              <Download className="w-4 h-4" />
                            </Button>
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => deleteHistoryItem(item.id)}
                              className="border-red-300 text-red-600 hover:bg-red-50 dark:border-red-700 dark:text-red-400 dark:hover:bg-red-900/20 prestigious-hover"
                            >
                              <Trash2 className="w-4 h-4" />
                            </Button>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                )}
              </Card>
            </motion.div>

            {/* Quick Actions */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
              className="mt-8"
            >
              <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                <div className="text-center mb-6">
                  <h2 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">
                    Ready for Your Next Analysis?
                  </h2>
                  <p className="text-gray-600 dark:text-gray-300">Continue building your legal knowledge with Aura</p>
                </div>

                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <Button
                    onClick={() => (window.location.href = "/analyzer")}
                    className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                  >
                    <BarChart3 className="w-4 h-4 mr-2" />
                    New Analysis
                    <ArrowRight className="w-4 h-4 ml-2" />
                  </Button>
                  <Button
                    onClick={() => (window.location.href = "/summarizer")}
                    variant="outline"
                    className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover"
                  >
                    <FileText className="w-4 h-4 mr-2" />
                    Summarize Document
                    <ArrowRight className="w-4 h-4 ml-2" />
                  </Button>
                </div>
              </Card>
            </motion.div>
          </div>
        </main>

        {/* Analysis View Modal */}
        {showViewModal && selectedItem && (
          <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              className="bg-white dark:bg-[#1B263B] rounded-xl max-w-4xl max-h-[90vh] overflow-y-auto w-full"
            >
              {/* Modal Header */}
              <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-[#1B263B]">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                    <Scale className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                  </div>
                  <div>
                    <h2 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">
                      {selectedItem.title}
                    </h2>
                    <p className="text-gray-600 dark:text-gray-300">
                      {format(new Date(selectedItem.created_at), "PPP")} at {format(new Date(selectedItem.created_at), "p")}
                    </p>
                  </div>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={closeViewModal}
                  className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                >
                  <X className="w-4 h-4" />
                </Button>
              </div>

              {/* Modal Content */}
              <div className="p-6 space-y-6">
                {selectedItem.result_data && (
                  <>
                    {/* Analysis Summary */}
                    {selectedItem.result_data.analysis_result?.summary && (
                      <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                          Executive Summary
                        </h3>
                        <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                          {selectedItem.result_data.analysis_result.summary}
                        </p>
                      </Card>
                    )}

                    {/* Case Details */}
                    {selectedItem.result_data.case_description && (
                      <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                          Case Description
                        </h3>
                        <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                          {selectedItem.result_data.case_description}
                        </p>
                      </Card>
                    )}

                    {/* Analysis Results */}
                    {selectedItem.result_data.analysis_result && (
                      <>
                        {/* Severity and Case Type */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                          {selectedItem.result_data.severity && (
                            <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                              <h4 className="text-md font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">
                                Severity Level
                              </h4>
                              <Badge className={`${
                                selectedItem.result_data.severity === 'high' 
                                  ? 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300'
                                  : selectedItem.result_data.severity === 'medium'
                                  ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300'
                                  : 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300'
                              }`}>
                                {selectedItem.result_data.severity?.toUpperCase()}
                              </Badge>
                            </Card>
                          )}

                          {selectedItem.result_data.case_type && (
                            <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                              <h4 className="text-md font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">
                                Case Type
                              </h4>
                              <p className="text-gray-700 dark:text-gray-300">
                                {selectedItem.result_data.case_type}
                              </p>
                            </Card>
                          )}
                        </div>

                        {/* Legal Issues */}
                        {selectedItem.result_data.analysis_result.legalIssues && selectedItem.result_data.analysis_result.legalIssues.length > 0 && (
                          <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                            <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                              Key Legal Issues
                            </h3>
                            <div className="space-y-2">
                              {selectedItem.result_data.analysis_result.legalIssues.map((issue: string, index: number) => (
                                <div key={index} className="flex items-center gap-3 p-2 bg-white dark:bg-[#1B263B] rounded">
                                  <div className="w-2 h-2 bg-[#007BFF] dark:bg-[#00FFFF] rounded-full" />
                                  <span className="text-gray-700 dark:text-gray-300">{issue}</span>
                                </div>
                              ))}
                            </div>
                          </Card>
                        )}

                        {/* Applicable Sections */}
                        {selectedItem.result_data.analysis_result.applicableSections && selectedItem.result_data.analysis_result.applicableSections.length > 0 && (
                          <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                            <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                              Applicable Legal Sections (Prosecution)
                            </h3>
                            <div className="space-y-3">
                              {selectedItem.result_data.analysis_result.applicableSections.map((section: any, index: number) => (
                                <div key={index} className="border-l-4 border-red-500 pl-4 bg-red-50 dark:bg-red-900/20 p-3 rounded-r">
                                  <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">
                                    {section.section}: {section.title}
                                  </h4>
                                  <p className="text-gray-600 dark:text-gray-300 mt-1">{section.description}</p>
                                  {section.punishment && (
                                    <div className="mt-2 p-2 bg-red-100 dark:bg-red-900/30 rounded">
                                      <p className="text-sm font-medium text-red-800 dark:text-red-200">
                                        <span className="font-semibold">Punishment:</span> {section.punishment}
                                      </p>
                                    </div>
                                  )}
                                </div>
                              ))}
                            </div>
                          </Card>
                        )}

                        {/* Defensive Sections */}
                        {selectedItem.result_data.analysis_result.defensiveSections && selectedItem.result_data.analysis_result.defensiveSections.length > 0 && (
                          <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                            <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                              Possible Defense Strategies
                            </h3>
                            <div className="space-y-3">
                              {selectedItem.result_data.analysis_result.defensiveSections.map((section: any, index: number) => (
                                <div key={index} className="border-l-4 border-green-500 pl-4 bg-green-50 dark:bg-green-900/20 p-3 rounded-r">
                                  <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">
                                    {section.section}: {section.title}
                                  </h4>
                                  <p className="text-gray-600 dark:text-gray-300 mt-1">{section.description}</p>
                                  {section.punishment && (
                                    <div className="mt-2 p-2 bg-green-100 dark:bg-green-900/30 rounded">
                                      <p className="text-sm font-medium text-green-800 dark:text-green-200">
                                        <span className="font-semibold">Defense Impact:</span> {section.punishment}
                                      </p>
                                    </div>
                                  )}
                                </div>
                              ))}
                            </div>
                          </Card>
                        )}

                        {/* Recommendations */}
                        {selectedItem.result_data.analysis_result.recommendations && selectedItem.result_data.analysis_result.recommendations.length > 0 && (
                          <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                            <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                              Recommendations
                            </h3>
                            <div className="space-y-2">
                              {selectedItem.result_data.analysis_result.recommendations.map((rec: string, index: number) => (
                                <div key={index} className="flex items-start gap-3 p-2 bg-blue-50 dark:bg-blue-900/20 rounded">
                                  <CheckCircle className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF] mt-0.5 flex-shrink-0" />
                                  <span className="text-gray-700 dark:text-gray-300">{rec}</span>
                                </div>
                              ))}
                            </div>
                          </Card>
                        )}
                      </>
                    )}

                    {/* Analysis Statistics */}
                    <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                        Analysis Statistics
                      </h3>
                      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-center">
                        <div>
                          <p className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">
                            {selectedItem.result_data.sections_count || 0}
                          </p>
                          <p className="text-sm text-gray-600 dark:text-gray-300">IPC Sections</p>
                        </div>
                        <div>
                          <p className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">
                            {selectedItem.result_data.defensive_sections_count || 0}
                          </p>
                          <p className="text-sm text-gray-600 dark:text-gray-300">Defense Options</p>
                        </div>
                        <div>
                          <p className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">
                            {selectedItem.result_data.recommendations_count || 0}
                          </p>
                          <p className="text-sm text-gray-600 dark:text-gray-300">Recommendations</p>
                        </div>
                        <div>
                          <p className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">
                            {selectedItem.result_data.input_type?.toUpperCase() || 'TEXT'}
                          </p>
                          <p className="text-sm text-gray-600 dark:text-gray-300">Input Type</p>
                        </div>
                      </div>
                    </Card>
                  </>
                )}
              </div>

              {/* Modal Footer */}
              <div className="flex justify-between items-center p-6 border-t border-gray-200 dark:border-[#1B263B]">
                <Button
                  variant="outline"
                  onClick={() => restoreSession(selectedItem)}
                  className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  Edit in Analyzer
                </Button>
                <Button
                  onClick={closeViewModal}
                  className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white"
                >
                  Close
                </Button>
              </div>
            </motion.div>
          </div>
        )}
      </PageContainer>
    </>
  )
}

export default withAuth(ClientHistory)

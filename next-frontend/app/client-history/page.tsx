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
import { History, FileText, BarChart3, Clock, Trash2, Search, Calendar, Download, Eye, ArrowRight } from "lucide-react"

interface HistoryItem {
  id: string
  type: "analysis" | "summary"
  title: string
  data: any
  timestamp: string
  status: "completed" | "processing" | "failed"
}

export default function ClientHistory() {
  const [history, setHistory] = useState<HistoryItem[]>([])
  const [filteredHistory, setFilteredHistory] = useState<HistoryItem[]>([])
  const [searchTerm, setSearchTerm] = useState("")
  const [filterType, setFilterType] = useState<"all" | "analysis" | "summary">("all")
  const [stats, setStats] = useState({
    totalAnalyses: 0,
    totalSummaries: 0,
    thisMonth: 0,
  })

  useEffect(() => {
    // Defensive programming: Load history with error handling
    try {
      const savedHistory = JSON.parse(localStorage.getItem("juris-history") || "[]")

      // Validate history data structure
      const validHistory = savedHistory.filter(
        (item: any) =>
          item &&
          typeof item.id === "string" &&
          typeof item.type === "string" &&
          typeof item.title === "string" &&
          typeof item.timestamp === "string",
      )

      setHistory(validHistory)
      setFilteredHistory(validHistory)

      // Calculate stats safely
      const analyses = validHistory.filter((item: HistoryItem) => item.type === "analysis").length
      const summaries = validHistory.filter((item: HistoryItem) => item.type === "summary").length

      const thisMonth = validHistory.filter((item: HistoryItem) => {
        try {
          const itemDate = new Date(item.timestamp)
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
    } catch (error) {
      console.error("Error loading history:", error)
      // Set empty state if there's an error
      setHistory([])
      setFilteredHistory([])
      setStats({ totalAnalyses: 0, totalSummaries: 0, thisMonth: 0 })
    }
  }, [])

  useEffect(() => {
    // Defensive filtering with error handling
    try {
      let filtered = [...history]

      // Filter by search term
      if (searchTerm && searchTerm.trim()) {
        filtered = filtered.filter((item) => item.title && item.title.toLowerCase().includes(searchTerm.toLowerCase()))
      }

      // Filter by type
      if (filterType !== "all") {
        filtered = filtered.filter((item) => item.type === filterType)
      }

      setFilteredHistory(filtered)
    } catch (error) {
      console.error("Error filtering history:", error)
      setFilteredHistory([])
    }
  }, [history, searchTerm, filterType])

  const deleteHistoryItem = (id: string) => {
    try {
      const updatedHistory = history.filter((item) => item.id !== id)
      setHistory(updatedHistory)
      localStorage.setItem("juris-history", JSON.stringify(updatedHistory))
    } catch (error) {
      console.error("Error deleting history item:", error)
      alert("Failed to delete item. Please try again.")
    }
  }

  const restoreSession = (item: HistoryItem) => {
    try {
      if (item.type === "analysis") {
        window.location.href = `/analyzer?restore=${item.id}`
      } else {
        window.location.href = `/summarizer?restore=${item.id}`
      }
    } catch (error) {
      console.error("Error restoring session:", error)
      alert("Failed to restore session. Please try again.")
    }
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
      case "completed":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
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
                                {item.type === "analysis" ? (
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
                                    {item.type === "analysis" ? "Incident Analysis" : "Document Summary"}
                                  </Badge>
                                  <Badge className={getStatusColor(item.status || "completed")}>
                                    {item.status || "completed"}
                                  </Badge>
                                </div>
                              </div>
                            </div>

                            <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-300">
                              <div className="flex items-center gap-1">
                                <Clock className="w-4 h-4" />
                                {formatDate(item.timestamp)}
                              </div>
                            </div>
                          </div>

                          <div className="flex gap-2 ml-4">
                            <Button
                              size="sm"
                              onClick={() => restoreSession(item)}
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
      </PageContainer>
    </>
  )
}

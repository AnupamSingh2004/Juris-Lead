"use client"

import { useState, useEffect } from "react"
import { motion } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { Navigation } from "@/components/navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  History,
  FileText,
  BarChart3,
  Clock,
  Trash2,
  Scale,
  Search,
  Users,
  ArrowRight,
  Calendar,
  AlertTriangle,
  CheckCircle,
} from "lucide-react"

interface HistoryItem {
  id: string
  type: "analysis" | "summary"
  title: string
  data: any
  timestamp: string
}

interface CaseTimeline {
  id: string
  name: string
  description: string
  events: number
  lastUpdated: string
  status: "active" | "completed" | "pending"
}

export default function ClientDashboard() {
  const [history, setHistory] = useState<HistoryItem[]>([])
  const [caseTimelines, setCaseTimelines] = useState<CaseTimeline[]>([])
  const [stats, setStats] = useState({
    totalAnalyses: 0,
    totalSummaries: 0,
    thisMonth: 0,
  })

  useEffect(() => {
    // Load history from localStorage
    const savedHistory = JSON.parse(localStorage.getItem("juris-history") || "[]")
    setHistory(savedHistory.slice(0, 5)) // Show only recent 5

    // Load case timelines from localStorage
    const savedTimelines = JSON.parse(localStorage.getItem("juris-timelines") || "[]")
    setCaseTimelines(savedTimelines)

    // Calculate stats
    const analyses = savedHistory.filter((item: HistoryItem) => item.type === "analysis").length
    const summaries = savedHistory.filter((item: HistoryItem) => item.type === "summary").length
    const thisMonth = savedHistory.filter((item: HistoryItem) => {
      const itemDate = new Date(item.timestamp)
      const now = new Date()
      return itemDate.getMonth() === now.getMonth() && itemDate.getFullYear() === now.getFullYear()
    }).length

    setStats({
      totalAnalyses: analyses,
      totalSummaries: summaries,
      thisMonth,
    })
  }, [])

  const deleteHistoryItem = (id: string) => {
    const updatedHistory = history.filter((item) => item.id !== id)
    setHistory(updatedHistory)

    // Update full history in localStorage
    const fullHistory = JSON.parse(localStorage.getItem("juris-history") || "[]")
    const updatedFullHistory = fullHistory.filter((item: HistoryItem) => item.id !== id)
    localStorage.setItem("juris-history", JSON.stringify(updatedFullHistory))
  }

  const restoreSession = (item: HistoryItem) => {
    if (item.type === "analysis") {
      window.location.href = `/analyzer?restore=${item.id}`
    } else {
      window.location.href = `/summarizer?restore=${item.id}`
    }
  }

  const formatDate = (timestamp: string) => {
    return new Date(timestamp).toLocaleDateString("en-IN", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      case "completed":
        return "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
      case "pending":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "active":
        return <AlertTriangle className="w-4 h-4" />
      case "completed":
        return <CheckCircle className="w-4 h-4" />
      case "pending":
        return <Clock className="w-4 h-4" />
      default:
        return <Calendar className="w-4 h-4" />
    }
  }

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <Navigation />

        <main className="pt-24 pb-16">
          <div className="max-w-7xl mx-auto px-6">
            {/* Welcome Header */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-12">
              <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">Welcome Back</h1>
              <p className="text-xl text-gray-600 dark:text-gray-300">
                Your personal legal command center powered by Aura
              </p>
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
                    <Clock className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-300">This Month</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">{stats.thisMonth}</p>
                  </div>
                </div>
              </Card>
            </motion.div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Widget 1: Recent Activity */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="lg:col-span-2"
              >
                <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] h-full">
                  <div className="flex items-center gap-3 mb-6">
                    <History className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                    <h2 className="text-2xl font-semibold text-gray-900 dark:text-[#E0E6F1]">My Recent Activity</h2>
                  </div>

                  {history.length === 0 ? (
                    <div className="text-center py-8">
                      <History className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">No activity yet</h3>
                      <p className="text-gray-600 dark:text-gray-300 mb-4">
                        Start by analyzing an incident or summarizing a document
                      </p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {history.map((item, index) => (
                        <motion.div
                          key={item.id}
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.1 * index }}
                          className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg border border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF] dark:hover:border-[#00FFFF] transition-all duration-300 prestigious-hover"
                        >
                          <div className="flex items-start justify-between">
                            <div className="flex-1">
                              <div className="flex items-center gap-3 mb-2">
                                <div className="p-2 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded">
                                  {item.type === "analysis" ? (
                                    <BarChart3 className="w-4 h-4 text-[#007BFF] dark:text-[#00FFFF]" />
                                  ) : (
                                    <FileText className="w-4 h-4 text-[#007BFF] dark:text-[#00FFFF]" />
                                  )}
                                </div>
                                <div>
                                  <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">{item.title}</h4>
                                  <p className="text-sm text-gray-600 dark:text-gray-300">
                                    {formatDate(item.timestamp)}
                                  </p>
                                </div>
                              </div>

                              <Badge
                                variant="outline"
                                className="border-gray-300 dark:border-[#1B263B] text-gray-600 dark:text-gray-300"
                              >
                                {item.type === "analysis" ? "Incident Analysis" : "Document Summary"}
                              </Badge>
                            </div>

                            <div className="flex gap-2">
                              <Button
                                size="sm"
                                onClick={() => restoreSession(item)}
                                className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                              >
                                Restore
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

              {/* Widget 2: Case Timelines */}
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
                <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] h-full">
                  <div className="flex items-center gap-3 mb-6">
                    <Calendar className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                    <h2 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1]">My Case Timelines</h2>
                  </div>

                  {caseTimelines.length === 0 ? (
                    <div className="text-center py-8">
                      <Calendar className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">No timelines yet</h3>
                      <p className="text-gray-600 dark:text-gray-300 mb-4">Create your first case timeline</p>
                      <Button
                        onClick={() => (window.location.href = "/case-builder")}
                        className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                      >
                        Create Timeline
                      </Button>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {caseTimelines.map((timeline, index) => (
                        <motion.div
                          key={timeline.id}
                          initial={{ opacity: 0, x: 20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.1 * index }}
                          className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg border border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF] dark:hover:border-[#00FFFF] transition-all duration-300 prestigious-hover cursor-pointer"
                          onClick={() => (window.location.href = `/case-builder?timeline=${timeline.id}`)}
                        >
                          <div className="flex items-start justify-between mb-3">
                            <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">{timeline.name}</h4>
                            <Badge className={getStatusColor(timeline.status)}>
                              <div className="flex items-center gap-1">
                                {getStatusIcon(timeline.status)}
                                {timeline.status}
                              </div>
                            </Badge>
                          </div>
                          <p className="text-sm text-gray-600 dark:text-gray-300 mb-2">{timeline.description}</p>
                          <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400">
                            <span>{timeline.events} events</span>
                            <span>Updated {formatDate(timeline.lastUpdated)}</span>
                          </div>
                        </motion.div>
                      ))}
                    </div>
                  )}
                </Card>
              </motion.div>
            </div>

            {/* Widget 3: Aura's Quick-Start Tools */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
              className="mt-8"
            >
              <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                <div className="text-center mb-8">
                  <h2 className="text-3xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">
                    Aura's Quick-Start Tools
                  </h2>
                  <p className="text-gray-600 dark:text-gray-300 text-lg">
                    Choose your next action to continue your legal journey
                  </p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <Button
                    onClick={() => (window.location.href = "/analyzer")}
                    className="h-32 flex flex-col items-center justify-center gap-4 bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan transition-all duration-300"
                  >
                    <Scale className="w-8 h-8" />
                    <div className="text-center">
                      <div className="font-semibold text-lg">Analyze a New Incident</div>
                      <div className="text-sm opacity-90">Get AI-powered legal analysis</div>
                    </div>
                    <ArrowRight className="w-5 h-5" />
                  </Button>

                  <Button
                    onClick={() => (window.location.href = "/summarizer")}
                    variant="outline"
                    className="h-32 flex flex-col items-center justify-center gap-4 border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent transition-all duration-300"
                  >
                    <FileText className="w-8 h-8" />
                    <div className="text-center">
                      <div className="font-semibold text-lg">Summarize a Document</div>
                      <div className="text-sm opacity-70">Get intelligent document summaries</div>
                    </div>
                    <ArrowRight className="w-5 h-5" />
                  </Button>

                  <Button
                    onClick={() => (window.location.href = "/explore")}
                    variant="outline"
                    className="h-32 flex flex-col items-center justify-center gap-4 border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent transition-all duration-300"
                  >
                    <Search className="w-8 h-8" />
                    <div className="text-center">
                      <div className="font-semibold text-lg">Explore Legal Topics</div>
                      <div className="text-sm opacity-70">Learn about Indian law</div>
                    </div>
                    <ArrowRight className="w-5 h-5" />
                  </Button>
                </div>

                <div className="mt-6 text-center">
                  <Button
                    onClick={() => (window.location.href = "/find-lawyer")}
                    variant="outline"
                    className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                  >
                    <Users className="w-5 h-5 mr-2" />
                    Find Expert Legal Counsel
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

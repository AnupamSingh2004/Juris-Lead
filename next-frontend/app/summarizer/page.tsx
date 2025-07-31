"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { Navigation } from "@/components/navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { AuraAnimation } from "@/components/aura-animation"
import {
  FileText,
  Upload,
  Sparkles,
  CheckCircle,
  ArrowRight,
  X,
  BookOpen,
  Lightbulb,
  AlertCircle,
  Download,
} from "lucide-react"

interface SummaryResult {
  summary: string
  keyPoints: string[]
  legalImplications: string[]
  actionItems: string[]
  documentType: string
  complexity: "low" | "medium" | "high"
  timeline: string
  riskLevel: "low" | "medium" | "high"
}

export default function SummarizerPage() {
  const [textInput, setTextInput] = useState("")
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [isSummarizing, setIsSummarizing] = useState(false)
  const [summaryResult, setSummaryResult] = useState<SummaryResult | null>(null)
  const [showResult, setShowResult] = useState(false)

  useEffect(() => {
    // Defensive programming: Check for restore parameter safely
    try {
      const urlParams = new URLSearchParams(window.location.search)
      const restoreId = urlParams.get("restore")

      if (restoreId) {
        const historyData = localStorage.getItem("juris-history")
        if (historyData) {
          const history = JSON.parse(historyData)
          const item = history.find((h: any) => h?.id === restoreId)

          if (item && item.type === "summary" && item.data) {
            if (item.data.input) {
              setTextInput(item.data.input)
            }
            if (item.data.result) {
              setSummaryResult(item.data.result)
              setShowResult(true)
            }
          }
        }
      }
    } catch (error) {
      console.error("Error restoring session:", error)
      // Continue with empty state - don't crash
    }
  }, [])

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      // Validate file size (10MB limit)
      if (file.size > 10 * 1024 * 1024) {
        alert("File size must be less than 10MB")
        return
      }
      setSelectedFile(file)
    }
  }

  const handleSummarize = async () => {
    // Defensive validation
    if (!textInput.trim() && !selectedFile) {
      alert("Please enter text or select a file to summarize")
      return
    }

    setIsSummarizing(true)
    setShowResult(false)

    try {
      // Simulate AI summarization with proper error handling
      await new Promise((resolve) => setTimeout(resolve, 2500))

      const mockResult: SummaryResult = {
        summary:
          "This document outlines the terms and conditions of a service agreement, including payment obligations, service delivery expectations, and termination clauses. The agreement establishes clear responsibilities for both parties and includes provisions for dispute resolution.",
        keyPoints: [
          "Service delivery timeline: 30 business days from contract execution",
          "Payment terms: Net 30 days with 2% early payment discount",
          "Termination clause: 30-day notice required from either party",
          "Liability limitations: Capped at contract value",
          "Intellectual property rights remain with original owner",
        ],
        legalImplications: [
          "Binding contractual obligations for both parties",
          "Potential penalties for breach of service delivery terms",
          "Limited liability exposure as per agreement terms",
          "Dispute resolution through arbitration required",
        ],
        actionItems: [
          "Review payment schedule and ensure compliance",
          "Establish service delivery milestones and tracking",
          "Prepare termination procedures documentation",
          "Consult legal counsel for any modifications needed",
        ],
        documentType: "Service Agreement",
        complexity: "medium",
        timeline: "30-45 days for full implementation",
        riskLevel: "low",
      }

      setSummaryResult(mockResult)
      setShowResult(true)

      // Save to history with error handling
      try {
        const historyItem = {
          id: Date.now().toString(),
          type: "summary",
          title: selectedFile?.name || textInput.slice(0, 50) + (textInput.length > 50 ? "..." : ""),
          data: {
            input: textInput,
            file: selectedFile?.name,
            result: mockResult,
          },
          timestamp: new Date().toISOString(),
          status: "completed",
        }

        const existingHistory = JSON.parse(localStorage.getItem("juris-history") || "[]")
        existingHistory.unshift(historyItem)
        localStorage.setItem("juris-history", JSON.stringify(existingHistory))
      } catch (storageError) {
        console.error("Error saving to history:", storageError)
        // Don't crash - just log the error
      }
    } catch (error) {
      console.error("Summarization error:", error)
      alert("Summarization failed. Please try again.")
    } finally {
      setIsSummarizing(false)
    }
  }

  const getComplexityColor = (complexity: string) => {
    switch (complexity) {
      case "low":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      case "medium":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
      case "high":
        return "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    }
  }

  const getRiskColor = (risk: string) => {
    switch (risk) {
      case "low":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      case "medium":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
      case "high":
        return "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    }
  }

  const resetSummarizer = () => {
    setTextInput("")
    setSelectedFile(null)
    setSummaryResult(null)
    setShowResult(false)
  }

  const downloadSummary = () => {
    if (!summaryResult) return

    try {
      const summaryText = `
JURIS-LEAD DOCUMENT SUMMARY REPORT
Generated on: ${new Date().toLocaleDateString()}

DOCUMENT TYPE: ${summaryResult.documentType}
COMPLEXITY: ${summaryResult.complexity.toUpperCase()}
RISK LEVEL: ${summaryResult.riskLevel.toUpperCase()}
TIMELINE: ${summaryResult.timeline}

EXECUTIVE SUMMARY:
${summaryResult.summary}

KEY POINTS:
${summaryResult.keyPoints.map((point, index) => `${index + 1}. ${point}`).join("\n")}

LEGAL IMPLICATIONS:
${summaryResult.legalImplications.map((implication, index) => `${index + 1}. ${implication}`).join("\n")}

RECOMMENDED ACTIONS:
${summaryResult.actionItems.map((action, index) => `${index + 1}. ${action}`).join("\n")}

This summary is generated by Aura AI and should be used for informational purposes only.
Please consult with a qualified lawyer for legal advice.
      `

      const blob = new Blob([summaryText], { type: "text/plain" })
      const url = URL.createObjectURL(blob)
      const a = document.createElement("a")
      a.href = url
      a.download = `juris-lead-summary-${Date.now()}.txt`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    } catch (error) {
      console.error("Download error:", error)
      alert("Download failed. Please try again.")
    }
  }

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <Navigation />

        <main className="pt-24 pb-16">
          <div className="max-w-4xl mx-auto px-6">
            {/* Header */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center mb-12">
              <div className="flex items-center justify-center gap-4 mb-6">
                <motion.div
                  className="p-4 bg-gradient-to-r from-[#007BFF] to-[#00FFFF] dark:from-[#00FFFF] dark:to-[#007BFF] rounded-2xl shadow-2xl"
                  animate={{
                    boxShadow: [
                      "0 0 20px rgba(0, 123, 255, 0.3)",
                      "0 0 40px rgba(0, 255, 255, 0.4)",
                      "0 0 20px rgba(0, 123, 255, 0.3)",
                    ],
                  }}
                  transition={{
                    duration: 3,
                    repeat: Number.POSITIVE_INFINITY,
                    ease: "easeInOut",
                  }}
                >
                  <FileText className="w-10 h-10 text-white" />
                </motion.div>
                <div className="text-left">
                  <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">
                    Document Summarizer
                  </h1>
                  <p className="text-xl text-gray-600 dark:text-gray-300">
                    Get intelligent summaries of legal documents with Aura
                  </p>
                </div>
              </div>
            </motion.div>

            <AnimatePresence mode="wait">
              {!showResult ? (
                <motion.div
                  key="input-form"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  className="space-y-8"
                >
                  {/* Input Form */}
                  <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                    <h2 className="text-2xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6">
                      Upload or Paste Your Document
                    </h2>

                    {/* File Upload Section */}
                    <div className="mb-8">
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-4">
                        Upload Document (PDF, DOC, DOCX, TXT)
                      </label>
                      <div className="border-2 border-dashed border-gray-300 dark:border-[#1B263B] rounded-lg p-8 text-center hover:border-[#007BFF] dark:hover:border-[#00FFFF] transition-colors duration-300">
                        <input
                          type="file"
                          accept=".pdf,.doc,.docx,.txt"
                          onChange={handleFileSelect}
                          className="hidden"
                          id="file-upload"
                        />
                        <label htmlFor="file-upload" className="cursor-pointer flex flex-col items-center gap-4">
                          {selectedFile ? (
                            <>
                              <motion.div
                                className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg"
                                animate={{ scale: [1, 1.05, 1] }}
                                transition={{ duration: 2, repeat: Number.POSITIVE_INFINITY }}
                              >
                                <FileText className="w-8 h-8 text-[#007BFF] dark:text-[#00FFFF]" />
                              </motion.div>
                              <div>
                                <p className="text-lg font-medium text-gray-900 dark:text-[#E0E6F1]">
                                  {selectedFile.name}
                                </p>
                                <p className="text-sm text-gray-600 dark:text-gray-300">
                                  {(selectedFile.size / 1024 / 1024).toFixed(2)} MB
                                </p>
                              </div>
                              <Button
                                type="button"
                                variant="outline"
                                size="sm"
                                onClick={(e) => {
                                  e.preventDefault()
                                  setSelectedFile(null)
                                }}
                                className="border-red-300 text-red-600 hover:bg-red-50 dark:border-red-700 dark:text-red-400 dark:hover:bg-red-900/20"
                              >
                                <X className="w-4 h-4 mr-1" />
                                Remove
                              </Button>
                            </>
                          ) : (
                            <>
                              <motion.div
                                className="p-4 bg-gray-100 dark:bg-[#0D1B2A]/50 rounded-lg"
                                whileHover={{ scale: 1.05 }}
                                transition={{ type: "spring", stiffness: 300 }}
                              >
                                <Upload className="w-12 h-12 text-gray-400" />
                              </motion.div>
                              <div>
                                <p className="text-lg font-medium text-gray-900 dark:text-[#E0E6F1]">
                                  Drop your document here or click to browse
                                </p>
                                <p className="text-sm text-gray-600 dark:text-gray-300">
                                  Supports PDF, DOC, DOCX, TXT files up to 10MB
                                </p>
                              </div>
                            </>
                          )}
                        </label>
                      </div>
                    </div>

                    {/* Divider */}
                    <div className="flex items-center gap-4 mb-8">
                      <div className="flex-1 h-px bg-gray-300 dark:bg-[#1B263B]" />
                      <span className="text-sm text-gray-500 dark:text-gray-400 font-medium">OR</span>
                      <div className="flex-1 h-px bg-gray-300 dark:bg-[#1B263B]" />
                    </div>

                    {/* Text Input Section */}
                    <div className="space-y-4">
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                        Paste Document Text
                      </label>
                      <Textarea
                        value={textInput}
                        onChange={(e) => setTextInput(e.target.value)}
                        placeholder="Paste the text of your legal document here for analysis and summarization..."
                        className="min-h-[200px] bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan resize-none transition-all duration-300"
                        maxLength={10000}
                      />
                      <div className="text-right text-sm text-gray-500 dark:text-gray-400">
                        {textInput.length}/10,000 characters
                      </div>
                    </div>

                    {/* Action Button */}
                    <div className="flex justify-center mt-8">
                      <motion.div
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        transition={{ type: "spring", stiffness: 300 }}
                      >
                        <Button
                          onClick={handleSummarize}
                          disabled={(!textInput.trim() && !selectedFile) || isSummarizing}
                          className="px-8 py-4 text-lg font-semibold bg-gradient-to-r from-[#007BFF] to-[#0056b3] dark:from-[#00FFFF] dark:to-[#00CCCC] hover:from-[#0056b3] hover:to-[#004085] dark:hover:from-[#00CCCC] dark:hover:to-[#00AAAA] text-white dark:text-[#0D1B2A] shadow-xl hover:shadow-2xl transition-all duration-300 prestigious-hover dark:glow-cyan disabled:opacity-50"
                        >
                          {isSummarizing ? (
                            <div className="flex items-center gap-3">
                              <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                              Summarizing with Aura...
                            </div>
                          ) : (
                            <div className="flex items-center gap-3">
                              <Sparkles className="w-5 h-5" />
                              Generate Summary
                              <ArrowRight className="w-5 h-5" />
                            </div>
                          )}
                        </Button>
                      </motion.div>
                    </div>
                  </Card>

                  {/* Summarization Animation */}
                  {isSummarizing && (
                    <motion.div
                      initial={{ opacity: 0, scale: 0.9 }}
                      animate={{ opacity: 1, scale: 1 }}
                      className="flex justify-center"
                    >
                      <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] text-center prestigious-hover">
                        <AuraAnimation />
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mt-6 mb-2">
                          Aura is analyzing your document...
                        </h3>
                        <p className="text-gray-600 dark:text-gray-300">
                          Extracting key information and generating insights
                        </p>
                      </Card>
                    </motion.div>
                  )}
                </motion.div>
              ) : (
                <motion.div
                  key="summary-result"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="space-y-8"
                >
                  {/* Summary Header */}
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                    <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                      <div className="flex items-center gap-4">
                        <motion.div
                          className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg"
                          animate={{ scale: [1, 1.05, 1] }}
                          transition={{ duration: 2, repeat: Number.POSITIVE_INFINITY }}
                        >
                          <CheckCircle className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                        </motion.div>
                        <div>
                          <h2 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">Summary Complete</h2>
                          <p className="text-gray-600 dark:text-gray-300">
                            Document type: {summaryResult?.documentType}
                          </p>
                        </div>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {summaryResult && (
                          <>
                            <Badge className={getComplexityColor(summaryResult.complexity)}>
                              <BookOpen className="w-4 h-4 mr-1" />
                              {summaryResult.complexity.toUpperCase()} COMPLEXITY
                            </Badge>
                            <Badge className={getRiskColor(summaryResult.riskLevel)}>
                              <AlertCircle className="w-4 h-4 mr-1" />
                              {summaryResult.riskLevel.toUpperCase()} RISK
                            </Badge>
                          </>
                        )}
                      </div>
                    </div>
                  </Card>

                  {summaryResult && (
                    <>
                      {/* Document Summary */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">
                          Executive Summary
                        </h3>
                        <p className="text-gray-700 dark:text-gray-300 leading-relaxed">{summaryResult.summary}</p>
                        <div className="mt-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                          <p className="text-sm text-blue-700 dark:text-blue-300">
                            <strong>Timeline:</strong> {summaryResult.timeline}
                          </p>
                        </div>
                      </Card>

                      {/* Key Points */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">Key Points</h3>
                        <div className="space-y-3">
                          {summaryResult.keyPoints.map((point, index) => (
                            <motion.div
                              key={index}
                              initial={{ opacity: 0, x: -20 }}
                              animate={{ opacity: 1, x: 0 }}
                              transition={{ delay: index * 0.1 }}
                              className="flex items-start gap-3 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg"
                            >
                              <div className="w-2 h-2 bg-[#007BFF] dark:bg-[#00FFFF] rounded-full mt-2 flex-shrink-0" />
                              <span className="text-gray-700 dark:text-gray-300">{point}</span>
                            </motion.div>
                          ))}
                        </div>
                      </Card>

                      {/* Legal Implications */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">
                          Legal Implications
                        </h3>
                        <div className="space-y-3">
                          {summaryResult.legalImplications.map((implication, index) => (
                            <motion.div
                              key={index}
                              initial={{ opacity: 0, x: -20 }}
                              animate={{ opacity: 1, x: 0 }}
                              transition={{ delay: index * 0.1 }}
                              className="flex items-start gap-3 p-3 bg-yellow-50 dark:bg-yellow-900/20 rounded-lg"
                            >
                              <AlertCircle className="w-5 h-5 text-yellow-600 dark:text-yellow-400 mt-0.5 flex-shrink-0" />
                              <span className="text-gray-700 dark:text-gray-300">{implication}</span>
                            </motion.div>
                          ))}
                        </div>
                      </Card>

                      {/* Action Items */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">
                          Recommended Actions
                        </h3>
                        <div className="space-y-3">
                          {summaryResult.actionItems.map((action, index) => (
                            <motion.div
                              key={index}
                              initial={{ opacity: 0, x: -20 }}
                              animate={{ opacity: 1, x: 0 }}
                              transition={{ delay: index * 0.1 }}
                              className="flex items-start gap-3 p-3 bg-green-50 dark:bg-green-900/20 rounded-lg"
                            >
                              <div className="w-6 h-6 bg-[#007BFF] dark:bg-[#00FFFF] text-white dark:text-[#0D1B2A] rounded-full flex items-center justify-center text-sm font-semibold flex-shrink-0">
                                {index + 1}
                              </div>
                              <span className="text-gray-700 dark:text-gray-300">{action}</span>
                            </motion.div>
                          ))}
                        </div>
                      </Card>
                    </>
                  )}

                  {/* Action Buttons */}
                  <div className="flex flex-col sm:flex-row gap-4 justify-center">
                    <motion.div
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      transition={{ type: "spring", stiffness: 300 }}
                    >
                      <Button
                        onClick={downloadSummary}
                        className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                      >
                        <Download className="w-4 h-4 mr-2" />
                        Download Summary
                        <ArrowRight className="w-4 h-4 ml-2" />
                      </Button>
                    </motion.div>
                    <motion.div
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      transition={{ type: "spring", stiffness: 300 }}
                    >
                      <Button
                        onClick={() => (window.location.href = "/find-lawyer")}
                        variant="outline"
                        className="border-[#007BFF] dark:border-[#00FFFF] text-[#007BFF] dark:text-[#00FFFF] hover:bg-[#007BFF] dark:hover:bg-[#00FFFF] hover:text-white dark:hover:text-[#0D1B2A] prestigious-hover bg-transparent"
                      >
                        <Lightbulb className="w-4 h-4 mr-2" />
                        Get Legal Advice
                        <ArrowRight className="w-4 h-4 ml-2" />
                      </Button>
                    </motion.div>
                    <Button
                      onClick={resetSummarizer}
                      variant="outline"
                      className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                    >
                      New Summary
                    </Button>
                    <Button
                      onClick={() => (window.location.href = "/client-history")}
                      variant="outline"
                      className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover"
                    >
                      View History
                    </Button>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </main>
      </PageContainer>
    </>
  )
}

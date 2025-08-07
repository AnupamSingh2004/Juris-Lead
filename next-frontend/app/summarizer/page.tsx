"use client"

import React, { useState, useRef } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { useRouter } from "next/navigation"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import {
  FileText,
  Upload,
  Download,
  X,
  CheckCircle,
  AlertCircle,
  BookOpen,
  Users,
  Calendar,
  Scale,
  Clock,
  Lightbulb,
  Sparkles,
  ArrowRight,
  History,
} from "lucide-react"
import { LivingBackground } from "@/components/living-background"
import { Navigation } from "@/components/navigation"
import { PageContainer } from "@/components/page-container"
import { AuraAnimation } from "@/components/aura-animation"
import { ApiService, DocumentSummaryResponse } from "@/lib/api-service"
import { useHistory } from "@/hooks/use-history"

interface SummarizerPageProps {}

const SummarizerPage: React.FC<SummarizerPageProps> = () => {
  const [inputMode, setInputMode] = useState<"file" | "text">("file")
  const [textInput, setTextInput] = useState("")
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [isSummarizing, setIsSummarizing] = useState(false)
  const [summaryResult, setSummaryResult] = useState<DocumentSummaryResponse | null>(null)
  const [showResult, setShowResult] = useState(false)
  const [summaryError, setSummaryError] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)
  
  const { createActivity } = useHistory()
  const router = useRouter()

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      // Validate file size (50MB limit)
      if (file.size > 50 * 1024 * 1024) {
        alert("File size must be less than 50MB")
        return
      }
      
      // Validate file type
      const allowedTypes = [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'text/plain',
        'image/jpeg',
        'image/png',
        'image/jpg'
      ]
      
      if (!allowedTypes.includes(file.type)) {
        alert("Please select a PDF, DOC, DOCX, TXT, or image file")
        return
      }
      
      setSelectedFile(file)
      setSummaryError(null)
    }
  }

  const handleSummarization = async () => {
    if (!textInput.trim() && !selectedFile) {
      alert("Please provide either text input or upload a file")
      return
    }

    setIsSummarizing(true)
    setShowResult(false)
    setSummaryError(null)

    try {
      let result: DocumentSummaryResponse

      if (inputMode === "file" && selectedFile) {
        result = await ApiService.summarizeDocument(selectedFile)
      } else if (inputMode === "text" && textInput.trim()) {
        // Create a text file from the input
        const textFile = new File([textInput], "document.txt", { type: "text/plain" })
        result = await ApiService.summarizeDocument(textFile)
      } else {
        throw new Error("No valid input provided")
      }

      setSummaryResult(result)
      setShowResult(true)

      // Save to history using the proper API with fallback to localStorage
      try {
        // Try to save to API first
        await createActivity({
          activity_type: "document_summarization",
          title: `Document Summary: ${selectedFile?.name || "Text Input"}`,
          description: `Generated AI summary for ${inputMode === "file" ? "uploaded file" : "text input"}`,
          status: "success",
          result_data: {
            summary: result.summary,
            metadata: result.metadata || {
              word_count: result.summary ? 0 : 0,
              character_count: textInput.length || 0,
            },
            input_mode: inputMode,
          },
          file_name: selectedFile?.name,
          file_size: selectedFile?.size,
          file_type: selectedFile?.type,
          page_url: "/summarizer",
          additional_data: {
            document_type: result.summary?.document_type,
            urgency_level: result.summary?.urgency_level,
            language_complexity: result.summary?.language_complexity,
          }
        })
        console.log("Successfully saved to API history")
      } catch (historyError) {
        console.error("API history saving failed, falling back to localStorage:", historyError)
        
        // Fallback to localStorage if API fails
        try {
          const historyItem = {
            id: Date.now().toString(),
            activity_type: "document_summarization",
            activity_type_display: "Document Summarization",
            title: `Document Summary: ${selectedFile?.name || "Text Input"}`,
            description: `Generated AI summary for ${inputMode === "file" ? "uploaded file" : "text input"}`,
            status: "success",
            status_display: "Success",
            result_data: {
              summary: result.summary,
              metadata: result.metadata || {
                word_count: result.summary ? 0 : 0,
                character_count: textInput.length || 0,
              },
              input_mode: inputMode,
            },
            file_name: selectedFile?.name,
            file_size: selectedFile?.size,
            file_type: selectedFile?.type,
            created_at: new Date().toISOString(),
            time_ago: "Just now",
            icon_name: "FileText",
            page_url: "/summarizer",
            additional_data: {
              document_type: result.summary?.document_type,
              urgency_level: result.summary?.urgency_level,
              language_complexity: result.summary?.language_complexity,
            }
          }

          const existingHistory = JSON.parse(localStorage.getItem("document-summaries") || "[]")
          existingHistory.unshift(historyItem)
          // Keep only last 50 entries to avoid storage bloat
          if (existingHistory.length > 50) {
            existingHistory.splice(50)
          }
          localStorage.setItem("document-summaries", JSON.stringify(existingHistory))
          console.log("Successfully saved to localStorage history")
        } catch (localStorageError) {
          console.error("localStorage history saving also failed:", localStorageError)
        }
      }

    } catch (error) {
      console.error("Summarization error:", error)
      
      let errorMessage = "Document summarization failed. Please try again."
      
      if (error instanceof Error) {
        errorMessage = error.message
      }
      
      setSummaryError(errorMessage)
      alert(errorMessage)
    } finally {
      setIsSummarizing(false)
    }
  }

  const getUrgencyColor = (urgency: string) => {
    switch (urgency.toLowerCase()) {
      case "high":
        return "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
      case "medium":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
      case "low":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    }
  }

  const getComplexityColor = (complexity: string) => {
    switch (complexity.toLowerCase()) {
      case "complex":
        return "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300"
      case "moderate":
        return "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
      case "simple":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    }
  }

  const resetSummarizer = () => {
    setTextInput("")
    setSelectedFile(null)
    setSummaryResult(null)
    setShowResult(false)
    setInputMode("file")
    setSummaryError(null)
    if (fileInputRef.current) {
      fileInputRef.current.value = ""
    }
  }

  const downloadSummary = () => {
    if (!summaryResult) return

    try {
      const summary = summaryResult.summary
      const summaryText = `
DOCUMENT SUMMARY
Generated on: ${new Date().toLocaleDateString()}

DOCUMENT TYPE: ${summary.document_type}
FILE: ${selectedFile?.name || "User Input"}

SIMPLE SUMMARY:
${summary.simple_summary}

DETAILED SUMMARY:
${summary.detailed_summary}

KEY POINTS:
${summary.key_points.map((point, index) => `${index + 1}. ${point}`).join('\n')}

PARTIES INVOLVED:
${summary.parties_involved.length > 0 ? summary.parties_involved.join(', ') : 'None specified'}

IMPORTANT DATES:
${summary.important_dates.length > 0 ? summary.important_dates.join(', ') : 'None specified'}

DOCUMENT IMPLICATIONS:
${summary.legal_implications}

ACTION REQUIRED:
${summary.action_required}

URGENCY LEVEL: ${summary.urgency_level}
LANGUAGE COMPLEXITY: ${summary.language_complexity}

This summary is generated by AI and should be used for informational purposes only.
      `

      const blob = new Blob([summaryText], { type: "text/plain" })
      const url = URL.createObjectURL(blob)
      const a = document.createElement("a")
      a.href = url
      a.download = `document-summary-${Date.now()}.txt`
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
            <motion.div 
              initial={{ opacity: 0, y: 20 }} 
              animate={{ opacity: 1, y: 0 }} 
              className="text-center mb-12"
            >
              <div className="flex items-center justify-center gap-4 mb-6">
                <div className="p-4 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-xl">
                  <FileText className="w-10 h-10 text-[#007BFF] dark:text-[#00FFFF]" />
                </div>
                <div className="text-center">
                  <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">
                    Document Summarizer
                  </h1>
                  <p className="text-xl text-gray-600 dark:text-gray-300">
                    Get intelligent summaries of any document with AI
                  </p>
                </div>
              </div>
            </motion.div>

            {/* View History Button */}
            <div className="flex justify-center mb-8">
              <Button
                onClick={() => router.push('/client-history')}
                variant="outline"
                className="flex items-center gap-2 border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
              >
                <History className="w-4 h-4" />
                View Summary History
              </Button>
            </div>

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
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                    <h2 className="text-2xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6">
                      Upload or Paste Your Document
                    </h2>

                    {/* Input Mode Selector */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
                      <Button
                        variant={inputMode === "file" ? "default" : "outline"}
                        onClick={() => setInputMode("file")}
                        className={`h-20 flex flex-col items-center justify-center gap-2 ${
                          inputMode === "file"
                            ? "bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white"
                            : "border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                        } transition-all duration-300`}
                      >
                        <Upload className="w-6 h-6" />
                        <span className="font-medium">Upload Document</span>
                      </Button>

                      <Button
                        variant={inputMode === "text" ? "default" : "outline"}
                        onClick={() => setInputMode("text")}
                        className={`h-20 flex flex-col items-center justify-center gap-2 ${
                          inputMode === "text"
                            ? "bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white"
                            : "border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                        } transition-all duration-300`}
                      >
                        <FileText className="w-6 h-6" />
                        <span className="font-medium">Paste Text</span>
                      </Button>
                    </div>

                    {/* Input Area */}
                    <div className="space-y-4">
                      {inputMode === "file" && (
                        <div>
                          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Upload Document (PDF, DOC, DOCX, TXT, Images)
                          </label>
                          <div className="border-2 border-dashed border-gray-300 dark:border-[#1B263B] rounded-lg p-8 text-center hover:border-[#007BFF] dark:hover:border-[#00FFFF] transition-colors duration-300">
                            <input
                              ref={fileInputRef}
                              type="file"
                              accept=".pdf,.doc,.docx,.txt,image/*"
                              onChange={handleFileSelect}
                              className="hidden"
                              id="file-upload"
                            />
                            <label htmlFor="file-upload" className="cursor-pointer flex flex-col items-center gap-4">
                              {selectedFile ? (
                                <>
                                  <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                                    <FileText className="w-8 h-8 text-[#007BFF] dark:text-[#00FFFF]" />
                                  </div>
                                  <div className="text-center">
                                    <p className="text-lg font-medium text-gray-900 dark:text-[#E0E6F1]">
                                      {selectedFile.name}
                                    </p>
                                    <p className="text-sm text-gray-600 dark:text-gray-300">
                                      {(selectedFile.size / 1024 / 1024).toFixed(2)} MB
                                    </p>
                                  </div>
                                </>
                              ) : (
                                <>
                                  <div className="p-3 bg-gray-100 dark:bg-[#0D1B2A]/50 rounded-lg">
                                    <Upload className="w-8 h-8 text-gray-600 dark:text-gray-400" />
                                  </div>
                                  <div className="text-center">
                                    <p className="text-lg font-medium text-gray-900 dark:text-[#E0E6F1]">
                                      Drop your document here or click to browse
                                    </p>
                                    <p className="text-sm text-gray-600 dark:text-gray-300">
                                      Supports PDF, DOC, DOCX, TXT files and images up to 50MB
                                    </p>
                                  </div>
                                </>
                              )}
                            </label>
                          </div>
                        </div>
                      )}

                      {inputMode === "text" && (
                        <div>
                          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Paste Document Text
                          </label>
                          <Textarea
                            value={textInput}
                            onChange={(e) => setTextInput(e.target.value)}
                            placeholder="Paste the text of your document here for analysis and summarization..."
                            className="min-h-[300px] bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] resize-none"
                            maxLength={10000}
                          />
                          <div className="text-right text-sm text-gray-500 dark:text-gray-400 mt-2">
                            {textInput.length}/10,000 characters
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Generate Summary Button */}
                    <div className="flex justify-center mt-8">
                      <Button
                        onClick={handleSummarization}
                        disabled={
                          (inputMode === "text" && !textInput.trim()) ||
                          (inputMode === "file" && !selectedFile) ||
                          isSummarizing
                        }
                        className="px-8 py-4 text-lg font-semibold bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white transition-all duration-300 disabled:opacity-50"
                      >
                        {isSummarizing ? (
                          <div className="flex items-center gap-3">
                            <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                            Generating Summary...
                          </div>
                        ) : (
                          <div className="flex items-center gap-3">
                            <Sparkles className="w-5 h-5" />
                            Generate Summary
                            <ArrowRight className="w-5 h-5" />
                          </div>
                        )}
                      </Button>
                    </div>
                  </Card>

                  {/* Processing Animation */}
                  {isSummarizing && (
                    <motion.div
                      initial={{ opacity: 0, scale: 0.9 }}
                      animate={{ opacity: 1, scale: 1 }}
                      className="flex justify-center"
                    >
                      <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] text-center">
                        <AuraAnimation />
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mt-6 mb-2">
                          AI is analyzing your document...
                        </h3>
                        <p className="text-gray-600 dark:text-gray-300">
                          Extracting key information and generating summary
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
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                    <div className="flex items-center justify-between mb-4">
                      <div className="flex items-center gap-4">
                        <div className="p-3 bg-green-100 dark:bg-green-900/30 rounded-lg">
                          <CheckCircle className="w-8 h-8 text-green-600 dark:text-green-400" />
                        </div>
                        <div>
                          <h2 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">
                            Document Summary Complete
                          </h2>
                          <p className="text-gray-600 dark:text-gray-300">
                            {selectedFile?.name || "Document"} • {summaryResult?.metadata.word_count} words
                          </p>
                        </div>
                      </div>
                      <div className="flex gap-2">
                        <Button
                          onClick={downloadSummary}
                          variant="outline"
                          className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                        >
                          <Download className="w-4 h-4 mr-2" />
                          Download
                        </Button>
                        <Button
                          onClick={resetSummarizer}
                          variant="outline"
                          className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                        >
                          <X className="w-4 h-4 mr-2" />
                          New Summary
                        </Button>
                      </div>
                    </div>

                    {/* Summary Badges */}
                    <div className="flex flex-wrap gap-2">
                      <Badge className={`${getUrgencyColor(summaryResult?.summary.urgency_level || "medium")} px-3 py-1`}>
                        <AlertCircle className="w-3 h-3 mr-1" />
                        {summaryResult?.summary.urgency_level} Urgency
                      </Badge>
                      <Badge className={`${getComplexityColor(summaryResult?.summary.language_complexity || "moderate")} px-3 py-1`}>
                        <BookOpen className="w-3 h-3 mr-1" />
                        {summaryResult?.summary.language_complexity} Complexity
                      </Badge>
                      <Badge className="bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300 px-3 py-1">
                        <FileText className="w-3 h-3 mr-1" />
                        {summaryResult?.summary.document_type}
                      </Badge>
                    </div>
                  </Card>

                  {summaryResult && (
                    <>
                      {/* Simple Summary */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4 flex items-center gap-2">
                          <Lightbulb className="w-5 h-5 text-yellow-500" />
                          Simple Summary
                        </h3>
                        <p className="text-gray-700 dark:text-gray-300 text-lg leading-relaxed">
                          {summaryResult.summary.simple_summary}
                        </p>
                      </Card>

                      {/* Detailed Summary */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4 flex items-center gap-2">
                          <FileText className="w-5 h-5 text-blue-500" />
                          Detailed Summary
                        </h3>
                        <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                          {summaryResult.summary.detailed_summary}
                        </p>
                      </Card>

                      {/* Key Points */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4 flex items-center gap-2">
                          <CheckCircle className="w-5 h-5 text-green-500" />
                          Key Points
                        </h3>
                        <ul className="space-y-2">
                          {summaryResult.summary.key_points.map((point, index) => (
                            <li key={index} className="flex items-start gap-3">
                              <div className="w-2 h-2 bg-[#007BFF] dark:bg-[#00FFFF] rounded-full mt-2 flex-shrink-0" />
                              <span className="text-gray-700 dark:text-gray-300">{point}</span>
                            </li>
                          ))}
                        </ul>
                      </Card>

                      {/* Parties and Dates */}
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        {/* Parties Involved */}
                        <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                          <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3 flex items-center gap-2">
                            <Users className="w-5 h-5 text-purple-500" />
                            Parties Involved
                          </h3>
                          {summaryResult.summary.parties_involved.length > 0 ? (
                            <ul className="space-y-2">
                              {summaryResult.summary.parties_involved.map((party, index) => (
                                <li key={index} className="text-gray-700 dark:text-gray-300">
                                  • {party}
                                </li>
                              ))}
                            </ul>
                          ) : (
                            <p className="text-gray-500 dark:text-gray-400 italic">None specified</p>
                          )}
                        </Card>

                        {/* Important Dates */}
                        <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                          <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3 flex items-center gap-2">
                            <Calendar className="w-5 h-5 text-orange-500" />
                            Important Dates
                          </h3>
                          {summaryResult.summary.important_dates.length > 0 ? (
                            <ul className="space-y-2">
                              {summaryResult.summary.important_dates.map((date, index) => (
                                <li key={index} className="text-gray-700 dark:text-gray-300">
                                  • {date}
                                </li>
                              ))}
                            </ul>
                          ) : (
                            <p className="text-gray-500 dark:text-gray-400 italic">None specified</p>
                          )}
                        </Card>
                      </div>

                      {/* Document Implications */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4 flex items-center gap-2">
                          <Scale className="w-5 h-5 text-red-500" />
                          Document Implications
                        </h3>
                        <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                          {summaryResult.summary.legal_implications}
                        </p>
                      </Card>

                      {/* Action Required */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4 flex items-center gap-2">
                          <Clock className="w-5 h-5 text-indigo-500" />
                          Action Required
                        </h3>
                        <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                          {summaryResult.summary.action_required}
                        </p>
                      </Card>
                    </>
                  )}
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </main>
      </PageContainer>
    </>
  )
}

export default SummarizerPage

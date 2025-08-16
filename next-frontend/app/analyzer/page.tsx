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
import { ApiService, ApiError, type AnalysisRequest } from "@/lib/api-service"
import { withAuth } from "@/lib/auth-context"
import { useActivityTracker } from "@/hooks/use-history"
import { extractTextFromPDF, isPDFFile, isPDFExtractionSupported } from "@/lib/pdf-utils"
import { extractTextFromImage, isImageFile, isImageExtractionSupported, validateImageFile } from "@/lib/image-utils"
import {
  Scale,
  FileText,
  ImageIcon,
  Upload,
  Sparkles,
  AlertTriangle,
  CheckCircle,
  Clock,
  ArrowRight,
  X,
  Download,
  BookOpen,
  Users,
  Wifi,
  WifiOff,
  History,
} from "lucide-react"

type InputType = "text" | "pdf" | "image"

interface AnalysisResult {
  summary: string
  legalIssues: string[]
  recommendations: string[]
  severity: "low" | "medium" | "high"
  nextSteps: string[]
  applicableSections: Array<{
    section: string
    title: string
    description: string
    punishment: string
  }>
  defensiveSections?: Array<{
    section: string
    title: string
    description: string
    punishment: string
  }>
  timeline: string
  caseType: string
}

function AnalyzerPage() {
  const [inputType, setInputType] = useState<InputType>("text")
  const [textInput, setTextInput] = useState("")
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [analysisResult, setAnalysisResult] = useState<AnalysisResult | null>(null)
  const [showResult, setShowResult] = useState(false)
  const [completedSteps, setCompletedSteps] = useState<string[]>([])
  const [backendStatus, setBackendStatus] = useState<'checking' | 'connected' | 'disconnected'>('checking')
  const [analysisError, setAnalysisError] = useState<string | null>(null)
  const [isExtractingPDF, setIsExtractingPDF] = useState(false)
  const [isExtractingImage, setIsExtractingImage] = useState(false)
  const [extractedText, setExtractedText] = useState<string>("")

  const { trackActivity } = useActivityTracker()

  useEffect(() => {
    checkBackendConnection()
  }, [])

  const checkBackendConnection = async () => {
    try {
      await ApiService.healthCheck()
      setBackendStatus('connected')
      console.log('Backend connection successful')
    } catch (error) {
      console.error('Backend connection failed:', error)
      setBackendStatus('disconnected')

      console.warn('Health check failed, but analysis may still work')
    }
  }

  useEffect(() => {
    try {
      const urlParams = new URLSearchParams(window.location.search)
      const restoreId = urlParams.get("restore")

      if (restoreId) {
        const historyData = localStorage.getItem("juris-history")
        if (historyData) {
          const history = JSON.parse(historyData)
          const item = history.find((h: any) => h?.id === restoreId)

          if (item && item.type === "analysis" && item.data) {
            if (item.data.input) {
              setTextInput(item.data.input)
            }
            if (item.data.result) {
              setAnalysisResult(item.data.result)
              setShowResult(true)
            }
          }
        }
      }
    } catch (error) {
      console.error("Error restoring session:", error)
    }
  }, [])

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      if (file.size > 10 * 1024 * 1024) {
        alert("File size must be less than 10MB")
        return
      }
      
      setSelectedFile(file)
      setExtractedText("")

      if (isPDFFile(file) && isPDFExtractionSupported()) {
        setIsExtractingPDF(true)
        try {
          const pdfResult = await extractTextFromPDF(file)
          setExtractedText(pdfResult.text)
          console.log(`PDF text extracted: ${pdfResult.text.length} characters from ${pdfResult.pageCount} pages`)
        } catch (error) {
          console.error('PDF extraction failed:', error)
          alert(`Failed to extract text from PDF: ${error instanceof Error ? error.message : 'Unknown error'}`)
          setSelectedFile(null)
        } finally {
          setIsExtractingPDF(false)
        }
      }

      else if (isImageFile(file) && isImageExtractionSupported()) {
        setIsExtractingImage(true)
        try {
          const imageResult = await extractTextFromImage(file)
          if (imageResult.success) {
            setExtractedText(imageResult.text)
            console.log(`Image text extracted: ${imageResult.text.length} characters with ${imageResult.confidence}% confidence`)
          } else {
            throw new Error(imageResult.error || 'OCR extraction failed')
          }
        } catch (error) {
          console.error('Image OCR extraction failed:', error)
          alert(`Failed to extract text from image: ${error instanceof Error ? error.message : 'Unknown error'}`)
          setSelectedFile(null)
        } finally {
          setIsExtractingImage(false)
        }
      }
    }
  }

  const handleAnalysis = async () => {
    if (inputType === "text" && !textInput.trim()) {
      alert("Please enter a description of your incident")
      return
    }

    if ((inputType === "pdf" || inputType === "image") && !selectedFile) {
      alert("Please select a file to analyze")
      return
    }

    if (backendStatus === 'disconnected') {
      console.warn("Health check failed, but attempting analysis anyway")

    }

    setIsAnalyzing(true)
    setShowResult(false)
    setCompletedSteps([])
    setAnalysisError(null)

    const steps = [
      "Connecting to AI analysis service...",
      "Processing case description...",
      "Analyzing applicable IPC sections...",
      "Determining case severity...",
      "Generating recommendations...",
      "Finalizing analysis report..."
    ]

    const stepInterval = setInterval(() => {
      setCompletedSteps(prev => {
        if (prev.length < steps.length - 1) {
          return [...prev, steps[prev.length]]
        }
        return prev
      })
    }, 2000)

    try {
      let caseDescription = textInput.trim()

      if (inputType === "pdf" && selectedFile) {
        if (extractedText) {
          caseDescription = extractedText
        } else {
          caseDescription = `[PDF File Upload: ${selectedFile.name}] ${caseDescription || 'PDF content analysis requested'}`
        }
      } else if (inputType === "image" && selectedFile) {
        if (extractedText) {
          caseDescription = extractedText
        } else {
          caseDescription = `[Image File Upload: ${selectedFile.name}] ${caseDescription || 'Image content analysis requested'}`
        }
      }

      const analysisRequest: AnalysisRequest = {
        case_description: caseDescription,
        user_type: 'citizen'
      }

      const backendResponse = await ApiService.analyzeCase(analysisRequest)
      
      // Transform backend response to frontend format
      const transformedResult = ApiService.transformAnalysisResponse(backendResponse)
      
      clearInterval(stepInterval)
      setCompletedSteps(steps)
      
      setAnalysisResult(transformedResult)
      setShowResult(true)

      // Save to backend history system or localStorage
      try {
        const activityTitle = inputType === "text"
          ? (textInput.length > 50 ? textInput.slice(0, 50) + "..." : textInput)
          : `${inputType.toUpperCase()} Analysis - ${selectedFile?.name || "Unknown"}`

        const activityType = inputType === "text" ? "case_analysis" : "document_analysis"
        
        const historyData = {
          description: `Legal analysis completed for ${inputType} input`,
          status: 'success',
          result_data: {
            input_type: inputType,
            case_description: caseDescription,
            analysis_result: transformedResult,
            backend_response: backendResponse,
            severity: transformedResult.severity,
            case_type: transformedResult.caseType,
            sections_count: transformedResult.applicableSections?.length || 0,
            defensive_sections_count: transformedResult.defensiveSections?.length || 0,
            recommendations_count: transformedResult.recommendations?.length || 0
          },
          file_name: selectedFile?.name,
          file_size: selectedFile?.size,
          file_type: selectedFile?.type,
          additional_data: {
            input_method: inputType,
            text_length: textInput.length,
            completed_steps: steps.length
          }
        }

        // Try to save to backend if user is authenticated
        try {
          await trackActivity(activityType, activityTitle, historyData)
          console.log("Analysis successfully saved to history")
        } catch (backendError) {
          console.warn("Backend history save failed, using localStorage:", backendError)
          
          // Fallback to localStorage for unauthenticated users
          const historyItem = {
            id: Date.now().toString(),
            type: "analysis",
            title: activityTitle,
            data: {
              input: textInput,
              file: selectedFile?.name,
              result: transformedResult,
              inputType,
              backendResponse: backendResponse,
            },
            timestamp: new Date().toISOString(),
            status: "completed",
          }

          const existingHistory = JSON.parse(localStorage.getItem("juris-history") || "[]")
          existingHistory.unshift(historyItem)
          localStorage.setItem("juris-history", JSON.stringify(existingHistory))
          console.log("Analysis saved to localStorage")
        }
      } catch (error) {
        clearInterval(stepInterval)
        console.error("Analysis error:", error)
      
        // Track failed analysis
        try {
          const activityTitle = inputType === "text"
            ? (textInput.length > 50 ? textInput.slice(0, 50) + "..." : textInput)
            : `${inputType.toUpperCase()} Analysis - ${selectedFile?.name || "Unknown"}`
          
          const activityType = inputType === "text" ? "case_analysis" : "document_analysis"
          
          await trackActivity(activityType, activityTitle, {
            description: `Legal analysis failed for ${inputType} input`,
            status: 'failed',
            result_data: {
              error_message: error instanceof Error ? error.message : 'Unknown error',
              input_type: inputType
            },
            file_name: selectedFile?.name,
            file_size: selectedFile?.size,
            file_type: selectedFile?.type,
            additional_data: {
              error_type: error instanceof ApiError ? 'api_error' : 'general_error',
              error_status: error instanceof ApiError ? error.status : undefined
            }
          })
        } catch (trackingError) {
          console.error("Error tracking failed analysis:", trackingError)
        }
        
        let errorMessage = "Analysis failed. Please try again."
        
        if (error instanceof ApiError) {
          errorMessage = error.message
          if (error.status === 408) {
            errorMessage = "Analysis is taking longer than expected. This may be due to complex case details. Please try again or simplify your description."
          }
        } else if (error instanceof Error) {
          errorMessage = `Analysis error: ${error.message}`
        }
        
        setAnalysisError(errorMessage)
        alert(errorMessage)
      }
    } finally {
      setIsAnalyzing(false)
    }
  }

  const getSeverityColor = (severity: string) => {
    switch (severity) {
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

  const getSeverityIcon = (severity: string) => {
    switch (severity) {
      case "low":
        return <CheckCircle className="w-4 h-4" />
      case "medium":
        return <AlertTriangle className="w-4 h-4" />
      case "high":
        return <AlertTriangle className="w-4 h-4" />
      default:
        return <Clock className="w-4 h-4" />
    }
  }

  const resetAnalysis = () => {
    setTextInput("")
    setSelectedFile(null)
    setExtractedText("")
    setAnalysisResult(null)
    setShowResult(false)
    setInputType("text")
    setCompletedSteps([])
  }

  const downloadAnalysis = () => {
    if (!analysisResult) return

    try {
      const analysisText = `
JURIS-LEAD LEGAL ANALYSIS REPORT
Generated on: ${new Date().toLocaleDateString()}

INPUT TYPE: ${inputType.toUpperCase()}
${selectedFile ? `FILE: ${selectedFile.name}` : ""}

INCIDENT DESCRIPTION:
${textInput || "File-based analysis"}

SEVERITY ASSESSMENT: ${analysisResult.severity?.toUpperCase() || 'MEDIUM'}
EXPECTED TIMELINE: ${analysisResult.timeline}

APPLICABLE LEGAL SECTIONS:
${analysisResult.applicableSections
  .map((section) => `• ${section.section}: ${section.title}\n  ${section.description}`)
  .join("\n")}

RECOMMENDED ACTIONS:
${analysisResult.recommendations.map((action, index) => `${index + 1}. ${action}`).join("\n")}

This analysis is generated by Aura AI and should be used for informational purposes only.
Please consult with a qualified lawyer for legal advice.
      `

      const blob = new Blob([analysisText], { type: "text/plain" })
      const url = URL.createObjectURL(blob)
      const a = document.createElement("a")
      a.href = url
      a.download = `juris-lead-analysis-${Date.now()}.txt`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)

      setCompletedSteps((prev) => [...prev, "download"])
    } catch (error) {
      console.error("Download error:", error)
      alert("Download failed. Please try again.")
    }
  }

  const exploreRights = () => {
    setCompletedSteps((prev) => [...prev, "explore"])
    window.location.href = `/explore?topic=${encodeURIComponent(analysisResult?.caseType || "Legal Rights")}`
  }

  const findLawyer = () => {
    setCompletedSteps((prev) => [...prev, "lawyer"])
    window.location.href = `/find-lawyer?specialization=${encodeURIComponent(analysisResult?.caseType || "General Law")}`
  }

  const nextSteps = [
    {
      id: "download",
      title: "Secure Evidence",
      description: "Download a PDF of your analysis to create a timestamped record",
      icon: <Download className="w-5 h-5" />,
      action: downloadAnalysis,
      priority: 1,
    },
    {
      id: "explore",
      title: "Explore Your Rights",
      description: `Read our comprehensive guide on ${analysisResult?.caseType || "your legal situation"}`,
      icon: <BookOpen className="w-5 h-5" />,
      action: exploreRights,
      priority: 2,
    },
    {
      id: "lawyer",
      title: "Find Professional Help",
      description: `Browse lawyers specializing in ${analysisResult?.caseType || "your case type"}`,
      icon: <Users className="w-5 h-5" />,
      action: findLawyer,
      priority: 3,
    },
  ]

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <Navigation />

        <main className="pt-24 pb-16">
          <div className="max-w-4xl mx-auto px-6">
            {/* Header */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center mb-12">
              <div className="flex items-center justify-between mb-6">
                {/* Left side - Title and description */}
                <div className="flex items-center gap-4">
                  <div className="p-4 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-xl">
                    <Scale className="w-10 h-10 text-[#007BFF] dark:text-[#00FFFF]" />
                  </div>
                  <div className="text-left">
                    <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">
                      Incident Analyzer
                    </h1>
                    <p className="text-xl text-gray-600 dark:text-gray-300">
                      Let Aura analyze your legal situation with AI precision
                    </p>
                  </div>
                </div>
                
                {/* Right side - History button */}
                <Button
                  onClick={() => window.location.href = '/client-history'}
                  variant="outline"
                  className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover"
                >
                  <History className="w-4 h-4 mr-2" />
                  My History
                </Button>
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
                  {/* Empty State / Input Form */}
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                    <h2 className="text-2xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6">
                      {!textInput && !selectedFile ? "Start a New Analysis" : "Choose Your Input Method"}
                    </h2>

                    {/* Multi-Format Input Selector */}
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
                      <Button
                        variant={inputType === "text" ? "default" : "outline"}
                        onClick={() => setInputType("text")}
                        className={`h-20 flex flex-col items-center justify-center gap-2 ${
                          inputType === "text"
                            ? "bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white dark:glow-cyan"
                            : "border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                        } prestigious-hover transition-all duration-300`}
                      >
                        <FileText className="w-6 h-6" />
                        <span className="font-medium">Text Description</span>
                      </Button>

                      <Button
                        variant={inputType === "pdf" ? "default" : "outline"}
                        onClick={() => setInputType("pdf")}
                        className={`h-20 flex flex-col items-center justify-center gap-2 ${
                          inputType === "pdf"
                            ? "bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white dark:glow-cyan"
                            : "border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                        } prestigious-hover transition-all duration-300`}
                      >
                        <Upload className="w-6 h-6" />
                        <span className="font-medium">PDF Document</span>
                      </Button>

                      <Button
                        variant={inputType === "image" ? "default" : "outline"}
                        onClick={() => setInputType("image")}
                        className={`h-20 flex flex-col items-center justify-center gap-2 ${
                          inputType === "image"
                            ? "bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white dark:glow-cyan"
                            : "border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                        } prestigious-hover transition-all duration-300`}
                      >
                        <ImageIcon className="w-6 h-6" />
                        <span className="font-medium">Image / Photo</span>
                      </Button>
                    </div>

                    {/* Input Area */}
                    <div className="space-y-4">
                      {inputType === "text" && (
                        <div>
                          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Describe what happened...
                          </label>
                          <Textarea
                            value={textInput}
                            onChange={(e) => setTextInput(e.target.value)}
                            placeholder="Please provide a detailed description of the incident, including dates, parties involved, and any relevant circumstances..."
                            className="min-h-[200px] bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan resize-none"
                            maxLength={2000}
                          />
                          <div className="text-right text-sm text-gray-500 dark:text-gray-400 mt-2">
                            {textInput.length}/2000 characters
                          </div>
                        </div>
                      )}

                      {(inputType === "pdf" || inputType === "image") && (
                        <div>
                          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Upload your {inputType === "pdf" ? "PDF document" : "image/photo"}
                          </label>
                          <div className="border-2 border-dashed border-gray-300 dark:border-[#1B263B] rounded-lg p-8 text-center hover:border-[#007BFF] dark:hover:border-[#00FFFF] transition-colors duration-300">
                            <input
                              type="file"
                              accept={inputType === "pdf" ? ".pdf" : "image/*"}
                              onChange={handleFileSelect}
                              className="hidden"
                              id="file-upload"
                            />
                            <label htmlFor="file-upload" className="cursor-pointer flex flex-col items-center gap-4">
                              {selectedFile ? (
                                <>
                                  <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                                    {inputType === "pdf" ? (
                                      <FileText className="w-8 h-8 text-[#007BFF] dark:text-[#00FFFF]" />
                                    ) : (
                                      <ImageIcon className="w-8 h-8 text-[#007BFF] dark:text-[#00FFFF]" />
                                    )}
                                  </div>
                                  <div className="text-center">
                                    <p className="text-lg font-medium text-gray-900 dark:text-[#E0E6F1]">
                                      {selectedFile.name}
                                    </p>
                                    <p className="text-sm text-gray-600 dark:text-gray-300">
                                      {(selectedFile.size / 1024 / 1024).toFixed(2)} MB
                                    </p>
                                    {inputType === "pdf" && (
                                      <div className="mt-2">
                                        {isExtractingPDF ? (
                                          <div className="flex items-center gap-2 text-sm text-blue-600 dark:text-blue-400">
                                            <div className="w-4 h-4 border-2 border-blue-600 border-t-transparent rounded-full animate-spin" />
                                            Extracting text from PDF...
                                          </div>
                                        ) : extractedText ? (
                                          <div className="text-sm text-green-600 dark:text-green-400">
                                            ✓ Text extracted ({extractedText.length} characters)
                                          </div>
                                        ) : (
                                          <div className="text-sm text-yellow-600 dark:text-yellow-400">
                                            PDF uploaded - text extraction may have failed
                                          </div>
                                        )}
                                      </div>
                                    )}
                                    {inputType === "image" && (
                                      <div className="mt-2">
                                        {isExtractingImage ? (
                                          <div className="flex items-center gap-2 text-sm text-blue-600 dark:text-blue-400">
                                            <div className="w-4 h-4 border-2 border-blue-600 border-t-transparent rounded-full animate-spin" />
                                            Extracting text from image...
                                          </div>
                                        ) : extractedText ? (
                                          <div className="text-sm text-green-600 dark:text-green-400">
                                            ✓ Text extracted ({extractedText.length} characters)
                                          </div>
                                        ) : (
                                          <div className="text-sm text-yellow-600 dark:text-yellow-400">
                                            Image uploaded - text extraction may have failed
                                          </div>
                                        )}
                                      </div>
                                    )}
                                  </div>
                                  <Button
                                    type="button"
                                    variant="outline"
                                    size="sm"
                                    onClick={(e) => {
                                      e.preventDefault()
                                      setSelectedFile(null)
                                      setExtractedText("")
                                    }}
                                    className="border-red-300 text-red-600 hover:bg-red-50 dark:border-red-700 dark:text-red-400 dark:hover:bg-red-900/20"
                                  >
                                    <X className="w-4 h-4 mr-1" />
                                    Remove
                                  </Button>
                                </>
                              ) : (
                                <>
                                  <div className="p-4 bg-gray-100 dark:bg-[#0D1B2A]/50 rounded-lg">
                                    <Upload className="w-12 h-12 text-gray-400" />
                                  </div>
                                  <div>
                                    <p className="text-lg font-medium text-gray-900 dark:text-[#E0E6F1]">
                                      Drop your {inputType === "pdf" ? "PDF" : "image"} here or click to browse
                                    </p>
                                    <p className="text-sm text-gray-600 dark:text-gray-300">
                                      {inputType === "pdf"
                                        ? "Supports PDF files up to 10MB"
                                        : "Supports JPG, PNG, GIF up to 5MB"}
                                    </p>
                                  </div>
                                </>
                              )}
                            </label>
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Show extracted PDF text preview */}
                    {inputType === "pdf" && extractedText && (
                      <div className="mt-6 p-4 bg-gray-50 dark:bg-[#0D1B2A]/30 rounded-lg border border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                          Extracted Text Preview:
                        </h3>
                        <div className="max-h-32 overflow-y-auto">
                          <p className="text-sm text-gray-700 dark:text-gray-300 whitespace-pre-wrap">
                            {extractedText.length > 500 ? `${extractedText.substring(0, 500)}...` : extractedText}
                          </p>
                        </div>
                        {extractedText.length > 500 && (
                          <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
                            Showing first 500 characters of {extractedText.length} total characters
                          </p>
                        )}
                      </div>
                    )}

                    {/* Action Button */}
                    <div className="flex justify-center mt-8">
                      <Button
                        onClick={handleAnalysis}
                        disabled={
                          (inputType === "text" && !textInput.trim()) ||
                          ((inputType === "pdf" || inputType === "image") && !selectedFile) ||
                          isAnalyzing ||
                          isExtractingPDF ||
                          isExtractingImage
                        }
                        className="px-8 py-4 text-lg font-semibold bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan transition-all duration-300 disabled:opacity-50"
                      >
                        {isAnalyzing ? (
                          <div className="flex items-center gap-3">
                            <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                            Analyzing with Aura...
                          </div>
                        ) : (
                          <div className="flex items-center gap-3">
                            <Sparkles className="w-5 h-5" />
                            Analyze
                            <ArrowRight className="w-5 h-5" />
                          </div>
                        )}
                      </Button>
                    </div>
                  </Card>

                  {/* Analysis Animation */}
                  {isAnalyzing && (
                    <motion.div
                      initial={{ opacity: 0, scale: 0.9 }}
                      animate={{ opacity: 1, scale: 1 }}
                      className="flex justify-center"
                    >
                      <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] text-center">
                        <AuraAnimation />
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mt-6 mb-2">
                          Aura is analyzing your case...
                        </h3>
                        <p className="text-gray-600 dark:text-gray-300">
                          Processing legal context and generating insights
                        </p>
                      </Card>
                    </motion.div>
                  )}
                </motion.div>
              ) : (
                <motion.div
                  key="analysis-result"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="space-y-8"
                >
                  {/* Analysis Header */}
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                    <div className="flex items-center justify-between mb-4">
                      <div className="flex items-center gap-4">
                        <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                          <CheckCircle className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                        </div>
                        <div>
                          <h2 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">Analysis Complete</h2>
                          <p className="text-gray-600 dark:text-gray-300">Aura has analyzed your legal situation</p>
                        </div>
                      </div>
                      {analysisResult && (
                        <Badge className={getSeverityColor(analysisResult.severity || 'medium')}>
                          <div className="flex items-center gap-1">
                            {getSeverityIcon(analysisResult.severity || 'medium')}
                            {(analysisResult.severity?.toUpperCase() || 'MEDIUM')} PRIORITY
                          </div>
                        </Badge>
                      )}
                    </div>
                  </Card>

                  {/* Analysis Summary */}
                  {analysisResult && (
                    <>
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">
                          Executive Summary
                        </h3>
                        <p className="text-gray-700 dark:text-gray-300 leading-relaxed">{analysisResult.summary}</p>
                      </Card>

                      {/* Legal Issues */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">
                          Key Legal Issues Identified
                        </h3>
                        <div className="space-y-3">
                          {analysisResult.legalIssues.map((issue, index) => (
                            <motion.div
                              key={index}
                              initial={{ opacity: 0, x: -20 }}
                              animate={{ opacity: 1, x: 0 }}
                              transition={{ delay: index * 0.1 }}
                              className="flex items-center gap-3 p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg"
                            >
                              <div className="w-2 h-2 bg-[#007BFF] dark:bg-[#00FFFF] rounded-full" />
                              <span className="text-gray-700 dark:text-gray-300">{issue}</span>
                            </motion.div>
                          ))}
                        </div>
                      </Card>

                      {/* Applicable Legal Sections */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">
                          Applicable Legal Sections (Prosecution)
                        </h3>
                        <div className="space-y-4">
                          {analysisResult.applicableSections.map((section, index) => (
                            <div key={index} className="border-l-4 border-red-500 dark:border-red-400 pl-4 bg-red-50 dark:bg-red-900/20 p-4 rounded-r-lg">
                              <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">
                                {section.section}: {section.title}
                              </h4>
                              <p className="text-gray-600 dark:text-gray-300 mt-1">{section.description}</p>
                              <div className="mt-3 p-2 bg-red-100 dark:bg-red-900/30 rounded">
                                <p className="text-sm font-medium text-red-800 dark:text-red-200">
                                  <span className="font-semibold">Punishment:</span> {section.punishment}
                                </p>
                              </div>
                            </div>
                          ))}
                        </div>
                      </Card>

                      {/* Defensive Legal Sections */}
                      {analysisResult.defensiveSections && analysisResult.defensiveSections.length > 0 && (
                        <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                          <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">
                            Possible Defense Strategies
                          </h3>
                          <div className="space-y-4">
                            {analysisResult.defensiveSections.map((section, index) => (
                              <div key={index} className="border-l-4 border-green-500 dark:border-green-400 pl-4 bg-green-50 dark:bg-green-900/20 p-4 rounded-r-lg">
                                <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">
                                  {section.section}: {section.title}
                                </h4>
                                <p className="text-gray-600 dark:text-gray-300 mt-1">{section.description}</p>
                                <div className="mt-3 p-2 bg-green-100 dark:bg-green-900/30 rounded">
                                  <p className="text-sm font-medium text-green-800 dark:text-green-200">
                                    <span className="font-semibold">Defense Impact:</span> {section.punishment}
                                  </p>
                                </div>
                              </div>
                            ))}
                          </div>
                        </Card>
                      )}

                      {/* Recommendations */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">
                          Aura's Recommendations
                        </h3>
                        <div className="space-y-3">
                          {analysisResult.recommendations.map((rec, index) => (
                            <motion.div
                              key={index}
                              initial={{ opacity: 0, x: -20 }}
                              animate={{ opacity: 1, x: 0 }}
                              transition={{ delay: index * 0.1 }}
                              className="flex items-start gap-3 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg"
                            >
                              <CheckCircle className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF] mt-0.5 flex-shrink-0" />
                              <span className="text-gray-700 dark:text-gray-300">{rec}</span>
                            </motion.div>
                          ))}
                        </div>
                      </Card>

                      {/* Aura's Next Steps Module */}
                      <Card className="p-8 bg-gradient-to-br from-[#007BFF]/5 to-[#007BFF]/10 dark:from-[#00FFFF]/5 dark:to-[#00FFFF]/10 border-[#007BFF]/20 dark:border-[#00FFFF]/20 prestigious-hover">
                        <div className="text-center mb-8">
                          <div className="inline-flex items-center gap-3 mb-4">
                            <div className="w-12 h-12 bg-[#007BFF] dark:bg-[#00FFFF] rounded-full flex items-center justify-center breathe">
                              <span className="text-white dark:text-[#0D1B2A] font-bold text-xl">A</span>
                            </div>
                            <h3 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">
                              Aura's Recommended Next Steps
                            </h3>
                          </div>
                          <p className="text-gray-600 dark:text-gray-300">
                            Follow these prioritized steps to take action on your legal situation
                          </p>
                        </div>

                        <div className="grid gap-4">
                          {nextSteps.map((step, index) => (
                            <motion.div
                              key={step.id}
                              initial={{ opacity: 0, x: -20 }}
                              animate={{ opacity: 1, x: 0 }}
                              transition={{ delay: index * 0.1 }}
                              className={`p-4 rounded-lg border-2 transition-all duration-300 prestigious-hover ${
                                completedSteps.includes(step.id)
                                  ? "border-green-300 dark:border-green-700 bg-green-50 dark:bg-green-900/20"
                                  : "border-gray-200 dark:border-[#1B263B] bg-white dark:bg-[#0D1B2A]/30 hover:border-[#007BFF] dark:hover:border-[#00FFFF]"
                              }`}
                            >
                              <div className="flex items-start gap-4">
                                <div
                                  className={`flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center ${
                                    completedSteps.includes(step.id)
                                      ? "bg-green-500 text-white"
                                      : "bg-[#007BFF] dark:bg-[#00FFFF] text-white dark:text-[#0D1B2A]"
                                  }`}
                                >
                                  {completedSteps.includes(step.id) ? <CheckCircle className="w-5 h-5" /> : step.icon}
                                </div>
                                <div className="flex-1">
                                  <div className="flex items-center gap-2 mb-2">
                                    <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">{step.title}</h4>
                                    <Badge variant="outline" className="text-xs">
                                      Priority {step.priority}
                                    </Badge>
                                  </div>
                                  <p className="text-gray-600 dark:text-gray-300 mb-3">{step.description}</p>
                                  {!completedSteps.includes(step.id) && (
                                    <Button
                                      onClick={step.action}
                                      size="sm"
                                      className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                                    >
                                      {step.title}
                                      <ArrowRight className="w-4 h-4 ml-2" />
                                    </Button>
                                  )}
                                  {completedSteps.includes(step.id) && (
                                    <Badge className="bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300">
                                      <CheckCircle className="w-4 h-4 mr-1" />
                                      Completed
                                    </Badge>
                                  )}
                                </div>
                              </div>
                            </motion.div>
                          ))}
                        </div>
                      </Card>
                    </>
                  )}

                  {/* Action Buttons */}
                  <div className="flex flex-col sm:flex-row gap-4 justify-center">
                    <Button
                      onClick={() => (window.location.href = "/find-lawyer")}
                      className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                    >
                      Find Expert Lawyers
                      <ArrowRight className="w-4 h-4 ml-2" />
                    </Button>
                    <Button
                      onClick={resetAnalysis}
                      variant="outline"
                      className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                    >
                      New Analysis
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

export default withAuth(AnalyzerPage)

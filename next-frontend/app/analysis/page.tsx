"use client"

import { useState, useEffect, Suspense } from "react"
import { motion } from "framer-motion"
import { useSearchParams, useRouter } from "next/navigation"
import { AnimatedBackground } from "@/components/animated-background"
import { CursorLight } from "@/components/cursor-light"
import { Navigation } from "@/components/navigation"
import { AnalysisNebula } from "@/components/analysis-nebula"
import { CaseTimeline } from "@/components/case-timeline"
import { HistoryPanel } from "@/components/history-panel"
import { GlassCard } from "@/components/glass-card"
import { Button } from "@/components/ui/button"
import { TimerIcon as Timeline, ArrowLeft } from "lucide-react"

function AnalysisContent() {
  const searchParams = useSearchParams()
  const router = useRouter()
  const query = searchParams.get("query") || ""
  const [showTimeline, setShowTimeline] = useState(false)
  const [analysisData, setAnalysisData] = useState(null)

  useEffect(() => {
    // Simulate analysis processing
    const timer = setTimeout(() => {
      // @ts-ignore
      setAnalysisData({
        incident: query,
        ipcSections: [
          {
            id: "ipc-420",
            title: "IPC Section 420",
            description: "Cheating and dishonestly inducing delivery of property",
          },
          { id: "ipc-406", title: "IPC Section 406", description: "Criminal breach of trust" },
          { id: "ipc-415", title: "IPC Section 415", description: "Cheating" },
        ],
        defenses: [
          { id: "def-1", title: "Lack of Intent", description: "No fraudulent intention" },
          { id: "def-2", title: "Good Faith", description: "Acting in good faith" },
        ],
        punishments: [
          { id: "pun-1", title: "Imprisonment", description: "Up to 7 years" },
          { id: "pun-2", title: "Fine", description: "As per court discretion" },
        ],
      })
    }, 2000)

    return () => clearTimeout(timer)
  }, [query])

  if (!analysisData) {
    return (
      <div className="min-h-screen relative overflow-hidden">
        <AnimatedBackground />
        <CursorLight />
        <Navigation />
        <div className="flex items-center justify-center min-h-screen">
          <GlassCard className="p-8">
            <div className="text-center">
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 2, repeat: Number.POSITIVE_INFINITY, ease: "linear" }}
                className="w-12 h-12 border-4 border-prestige-blue dark:border-electric-blue border-t-transparent rounded-full mx-auto mb-4"
              />
              <p className="text-charcoal dark:text-off-white">Analyzing your case...</p>
            </div>
          </GlassCard>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen relative overflow-hidden">
      <AnimatedBackground />
      <CursorLight />
      <Navigation />
      <HistoryPanel />

      <main className="pt-20 px-4">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-8 flex items-center justify-between"
          >
            <div className="flex items-center gap-4">
              <Button
                variant="ghost"
                onClick={() => router.back()}
                className="text-charcoal dark:text-off-white hover:bg-white/10"
              >
                <ArrowLeft className="w-4 h-4 mr-2" />
                Back
              </Button>
              <h1 className="text-3xl font-bold text-charcoal dark:text-off-white">Case Analysis</h1>
            </div>

            {!showTimeline && (
              <Button
                onClick={() => setShowTimeline(true)}
                className="bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90 text-white"
              >
                <Timeline className="w-4 h-4 mr-2" />
                Expand into Case Timeline
              </Button>
            )}
          </motion.div>

          {showTimeline ? (
            <CaseTimeline initialAnalysis={analysisData} onBack={() => setShowTimeline(false)} />
          ) : (
            <AnalysisNebula data={analysisData} />
          )}
        </div>
      </main>
    </div>
  )
}

export default function AnalysisPage() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <AnalysisContent />
    </Suspense>
  )
}

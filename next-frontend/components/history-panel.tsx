"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { GlassCard } from "@/components/glass-card"
import { Button } from "@/components/ui/button"
import { History, ChevronLeft, ChevronRight, Clock } from "lucide-react"

const mockHistory = [
  {
    id: "1",
    query: "Property dispute with landlord over security deposit",
    date: "2024-01-15",
    time: "14:30",
  },
  {
    id: "2",
    query: "Employment termination without proper notice",
    date: "2024-01-14",
    time: "10:15",
  },
  {
    id: "3",
    query: "Consumer complaint against online retailer",
    date: "2024-01-13",
    time: "16:45",
  },
]

export function HistoryPanel() {
  const [isOpen, setIsOpen] = useState(false)

  const restoreAnalysis = (historyItem: (typeof mockHistory)[0]) => {
    // Navigate to analysis with the historical query
    window.location.href = `/analysis?query=${encodeURIComponent(historyItem.query)}`
  }

  return (
    <>
      {/* Toggle Button */}
      <motion.div
        className="fixed left-4 top-1/2 -translate-y-1/2 z-40"
        initial={{ x: isOpen ? 0 : -10 }}
        animate={{ x: isOpen ? 0 : -10 }}
      >
        <Button
          onClick={() => setIsOpen(!isOpen)}
          size="sm"
          className="bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90 rounded-r-lg rounded-l-none"
        >
          {isOpen ? <ChevronLeft className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
        </Button>
      </motion.div>

      {/* History Panel */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ x: -300, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            exit={{ x: -300, opacity: 0 }}
            transition={{ type: "spring", stiffness: 300, damping: 30 }}
            className="fixed left-0 top-20 bottom-4 w-80 z-30 p-4"
          >
            <GlassCard className="h-full p-6 overflow-hidden flex flex-col">
              <div className="flex items-center gap-2 mb-6">
                <History className="w-5 h-5 text-prestige-blue dark:text-electric-blue" />
                <h3 className="text-lg font-semibold text-charcoal dark:text-off-white">Analysis History</h3>
              </div>

              <div className="flex-1 overflow-y-auto space-y-3">
                {mockHistory.map((item, index) => (
                  <motion.div
                    key={item.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.1 }}
                  >
                    <div
                      onClick={() => restoreAnalysis(item)}
                      className="p-4 bg-white/5 hover:bg-white/10 rounded-lg border border-white/10 cursor-pointer transition-all duration-200 group"
                    >
                      <p className="text-charcoal dark:text-off-white text-sm font-medium mb-2 line-clamp-2 group-hover:text-prestige-blue dark:group-hover:text-electric-blue">
                        {item.query}
                      </p>
                      <div className="flex items-center gap-2 text-xs text-charcoal/60 dark:text-off-white/60">
                        <Clock className="w-3 h-3" />
                        <span>{item.date}</span>
                        <span>•</span>
                        <span>{item.time}</span>
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>

              <div className="mt-4 pt-4 border-t border-white/20">
                <Button
                  variant="outline"
                  size="sm"
                  className="w-full border-white/20 hover:bg-white/10 text-charcoal dark:text-off-white bg-transparent"
                >
                  Clear History
                </Button>
              </div>
            </GlassCard>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  )
}

"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { GlassCard } from "@/components/glass-card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Plus, Calendar, FileText, AlertTriangle, ArrowLeft, X } from "lucide-react"

interface TimelineEvent {
  id: string
  type: "incident" | "document" | "date"
  title: string
  description: string
  date: string
  importance: "low" | "medium" | "high"
}

interface CaseTimelineProps {
  initialAnalysis: any
  onBack: () => void
}

export function CaseTimeline({ initialAnalysis, onBack }: CaseTimelineProps) {
  const [events, setEvents] = useState<TimelineEvent[]>([
    {
      id: "1",
      type: "incident",
      title: "Initial Analysis",
      description: initialAnalysis.incident,
      date: new Date().toISOString().split("T")[0],
      importance: "high",
    },
  ])

  const [showModal, setShowModal] = useState(false)
  const [newEvent, setNewEvent] = useState({
    type: "incident" as "incident" | "document" | "date",
    title: "",
    description: "",
    date: "",
    importance: "medium" as "low" | "medium" | "high",
  })

  const addEvent = () => {
    if (newEvent.title && newEvent.date) {
      const event: TimelineEvent = {
        id: Date.now().toString(),
        ...newEvent,
      }
      setEvents((prev) => [...prev, event].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()))
      setNewEvent({
        type: "incident",
        title: "",
        description: "",
        date: "",
        importance: "medium",
      })
      setShowModal(false)
    }
  }

  const getEventIcon = (type: string) => {
    switch (type) {
      case "incident":
        return <AlertTriangle className="w-5 h-5" />
      case "document":
        return <FileText className="w-5 h-5" />
      case "date":
        return <Calendar className="w-5 h-5" />
      default:
        return <Calendar className="w-5 h-5" />
    }
  }

  const getImportanceColor = (importance: string) => {
    switch (importance) {
      case "high":
        return "border-red-500 bg-red-500/20"
      case "medium":
        return "border-yellow-500 bg-yellow-500/20"
      case "low":
        return "border-green-500 bg-green-500/20"
      default:
        return "border-gray-500 bg-gray-500/20"
    }
  }

  return (
    <div>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6 flex justify-between items-center"
      >
        <div className="flex items-center gap-4">
          <Button variant="ghost" onClick={onBack} className="text-charcoal dark:text-off-white hover:bg-white/10">
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Nebula
          </Button>
          <h2 className="text-2xl font-bold text-charcoal dark:text-off-white">Case Timeline</h2>
        </div>

        <Button
          onClick={() => setShowModal(true)}
          className="bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90"
        >
          <Plus className="w-4 h-4 mr-2" />
          Add Event
        </Button>
      </motion.div>

      <div className="relative">
        {/* Timeline Line */}
        <div className="absolute left-8 top-0 bottom-0 w-0.5 bg-gradient-to-b from-prestige-blue to-electric-blue"></div>

        <div className="space-y-6">
          {events.map((event, index) => (
            <motion.div
              key={event.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.1 }}
              className="relative flex items-start gap-6"
            >
              {/* Timeline Node */}
              <div
                className={`relative z-10 w-16 h-16 rounded-full border-4 ${getImportanceColor(event.importance)} flex items-center justify-center text-white`}
              >
                {getEventIcon(event.type)}
              </div>

              {/* Event Card */}
              <div className="flex-1">
                <GlassCard className="p-6">
                  <div className="flex justify-between items-start mb-3">
                    <div>
                      <h3 className="text-xl font-semibold text-charcoal dark:text-off-white mb-1">{event.title}</h3>
                      <p className="text-charcoal/70 dark:text-off-white/70 text-sm">
                        {new Date(event.date).toLocaleDateString("en-IN", {
                          year: "numeric",
                          month: "long",
                          day: "numeric",
                        })}
                      </p>
                    </div>
                    <div className="flex gap-2">
                      <Badge variant="outline" className="border-prestige-blue/30 dark:border-electric-blue/30">
                        {event.type}
                      </Badge>
                      <Badge
                        className={
                          event.importance === "high"
                            ? "bg-red-500/20 text-red-400 border-red-500/30"
                            : event.importance === "medium"
                              ? "bg-yellow-500/20 text-yellow-400 border-yellow-500/30"
                              : "bg-green-500/20 text-green-400 border-green-500/30"
                        }
                      >
                        {event.importance}
                      </Badge>
                    </div>
                  </div>

                  <p className="text-charcoal dark:text-off-white leading-relaxed">{event.description}</p>
                </GlassCard>
              </div>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Add Event Modal */}
      <AnimatePresence>
        {showModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            onClick={() => setShowModal(false)}
          >
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              onClick={(e) => e.stopPropagation()}
              className="w-full max-w-md"
            >
              <GlassCard className="p-6">
                <div className="flex justify-between items-center mb-6">
                  <h3 className="text-xl font-semibold text-charcoal dark:text-off-white">Add New Event</h3>
                  <button
                    onClick={() => setShowModal(false)}
                    className="text-charcoal/60 dark:text-off-white/60 hover:text-charcoal dark:hover:text-off-white"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>

                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Event Type
                    </label>
                    <select
                      value={newEvent.type}
                      onChange={(e) => setNewEvent((prev) => ({ ...prev, type: e.target.value as any }))}
                      className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-charcoal dark:text-off-white"
                    >
                      <option value="incident">Incident</option>
                      <option value="document">Document</option>
                      <option value="date">Important Date</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">Title</label>
                    <Input
                      value={newEvent.title}
                      onChange={(e) => setNewEvent((prev) => ({ ...prev, title: e.target.value }))}
                      placeholder="Event title..."
                      className="bg-white/10 border-white/20"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">Date</label>
                    <Input
                      type="date"
                      value={newEvent.date}
                      onChange={(e) => setNewEvent((prev) => ({ ...prev, date: e.target.value }))}
                      className="bg-white/10 border-white/20"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Importance
                    </label>
                    <select
                      value={newEvent.importance}
                      onChange={(e) => setNewEvent((prev) => ({ ...prev, importance: e.target.value as any }))}
                      className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-charcoal dark:text-off-white"
                    >
                      <option value="low">Low</option>
                      <option value="medium">Medium</option>
                      <option value="high">High</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Description
                    </label>
                    <Textarea
                      value={newEvent.description}
                      onChange={(e) => setNewEvent((prev) => ({ ...prev, description: e.target.value }))}
                      placeholder="Event description..."
                      className="bg-white/10 border-white/20 min-h-[100px]"
                    />
                  </div>
                </div>

                <div className="flex gap-3 mt-6">
                  <Button
                    onClick={addEvent}
                    className="flex-1 bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90"
                  >
                    Add Event
                  </Button>
                  <Button
                    variant="outline"
                    onClick={() => setShowModal(false)}
                    className="border-white/20 hover:bg-white/10"
                  >
                    Cancel
                  </Button>
                </div>
              </GlassCard>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { Navigation } from "@/components/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Plus, Calendar, FileText, AlertTriangle, X, Brain } from "lucide-react"

interface TimelineEvent {
  id: string
  type: "incident" | "document" | "date"
  title: string
  description: string
  date: string
  importance: "low" | "medium" | "high"
}

export default function CaseBuilderPage() {
  const [events, setEvents] = useState<TimelineEvent[]>([])
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
        return "border-red-500 bg-red-500/20 text-red-700 dark:text-red-300"
      case "medium":
        return "border-yellow-500 bg-yellow-500/20 text-yellow-700 dark:text-yellow-300"
      case "low":
        return "border-green-500 bg-green-500/20 text-green-700 dark:text-green-300"
      default:
        return "border-gray-500 bg-gray-500/20 text-gray-700 dark:text-gray-300"
    }
  }

  const generateAuraSummary = () => {
    if (events.length === 0) {
      return {
        overview: "No events added yet. Start building your case timeline to see Aura's analysis.",
        keyFacts: [],
        legalConsiderations: [],
        recommendations: [],
      }
    }

    const highPriorityEvents = events.filter((e) => e.importance === "high")
    const incidents = events.filter((e) => e.type === "incident")
    const documents = events.filter((e) => e.type === "document")

    return {
      overview: `Case timeline contains ${events.length} events spanning from ${new Date(events[0]?.date).toLocaleDateString()} to ${new Date(events[events.length - 1]?.date).toLocaleDateString()}. ${highPriorityEvents.length} high-priority events identified.`,
      keyFacts: [
        `${incidents.length} incident(s) documented`,
        `${documents.length} supporting document(s) referenced`,
        `${highPriorityEvents.length} critical event(s) requiring attention`,
        "Chronological sequence established for legal proceedings",
      ],
      legalConsiderations: [
        "Timeline consistency supports case credibility",
        "Documentary evidence strengthens legal position",
        "High-priority events may require immediate legal action",
        "Chronological gaps may need additional documentation",
      ],
      recommendations: [
        "Gather additional evidence for high-priority events",
        "Consult with specialized legal counsel",
        "Prepare witness statements for key incidents",
        "Organize documents in chronological order for court presentation",
      ],
    }
  }

  const auraSummary = generateAuraSummary()

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <Navigation />

        <main className="pt-24 pb-16">
          <div className="px-6">
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8">
              <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">Case Builder</h1>
              <p className="text-xl text-gray-600 dark:text-gray-300">
                Build your case timeline and get real-time AI analysis from Aura
              </p>
            </motion.div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Left Column - Interactive Timeline */}
              <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.2 }}>
                <Card className="p-6 bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm border-gray-200 dark:border-gray-700 h-fit">
                  <div className="flex justify-between items-center mb-6">
                    <h2 className="text-2xl font-semibold text-gray-900 dark:text-white">Interactive Timeline</h2>
                    <Button onClick={() => setShowModal(true)} className="bg-[#007BFF] hover:bg-[#0056b3] text-white">
                      <Plus className="w-4 h-4 mr-2" />
                      Add Event
                    </Button>
                  </div>

                  {events.length === 0 ? (
                    <div className="text-center py-12">
                      <Calendar className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">No events yet</h3>
                      <p className="text-gray-600 dark:text-gray-300 mb-6">
                        Start building your case by adding the first event
                      </p>
                      <Button onClick={() => setShowModal(true)} className="bg-[#007BFF] hover:bg-[#0056b3] text-white">
                        <Plus className="w-4 h-4 mr-2" />
                        Add First Event
                      </Button>
                    </div>
                  ) : (
                    <div className="relative">
                      {/* Timeline Line */}
                      <div className="absolute left-8 top-0 bottom-0 w-0.5 bg-gradient-to-b from-[#007BFF] to-blue-300"></div>

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
                              className={`relative z-10 w-16 h-16 rounded-full border-4 ${getImportanceColor(event.importance)} flex items-center justify-center text-white bg-white dark:bg-gray-800`}
                            >
                              {getEventIcon(event.type)}
                            </div>

                            {/* Event Card */}
                            <div className="flex-1">
                              <Card className="p-4 bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600">
                                <div className="flex justify-between items-start mb-3">
                                  <div>
                                    <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1">
                                      {event.title}
                                    </h3>
                                    <p className="text-sm text-gray-600 dark:text-gray-300">
                                      {new Date(event.date).toLocaleDateString("en-IN", {
                                        year: "numeric",
                                        month: "long",
                                        day: "numeric",
                                      })}
                                    </p>
                                  </div>
                                  <div className="flex gap-2">
                                    <Badge variant="outline" className="border-[#007BFF]/30 text-[#007BFF]">
                                      {event.type}
                                    </Badge>
                                    <Badge className={getImportanceColor(event.importance)}>{event.importance}</Badge>
                                  </div>
                                </div>

                                <p className="text-gray-700 dark:text-gray-200 leading-relaxed">{event.description}</p>
                              </Card>
                            </div>
                          </motion.div>
                        ))}
                      </div>
                    </div>
                  )}
                </Card>
              </motion.div>

              {/* Right Column - Aura's Live Summary */}
              <motion.div
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.4 }}
                className="lg:sticky lg:top-24"
              >
                <Card className="p-6 bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm border-gray-200 dark:border-gray-700">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="p-2 bg-[#007BFF]/10 rounded-lg">
                      <Brain className="w-6 h-6 text-[#007BFF]" />
                    </div>
                    <h2 className="text-2xl font-semibold text-gray-900 dark:text-white">
                      Aura's Real-Time Case Summary
                    </h2>
                  </div>

                  <div className="space-y-6">
                    {/* Overview */}
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">Case Overview</h3>
                      <p className="text-gray-700 dark:text-gray-200 leading-relaxed">{auraSummary.overview}</p>
                    </div>

                    {/* Key Facts */}
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">Key Facts</h3>
                      <ul className="space-y-2">
                        {auraSummary.keyFacts.map((fact, index) => (
                          <li key={index} className="flex items-start gap-3">
                            <span className="flex-shrink-0 w-6 h-6 bg-[#007BFF] text-white rounded-full flex items-center justify-center text-sm font-semibold mt-0.5">
                              {index + 1}
                            </span>
                            <span className="text-gray-700 dark:text-gray-200">{fact}</span>
                          </li>
                        ))}
                      </ul>
                    </div>

                    {/* Legal Considerations */}
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">Legal Considerations</h3>
                      <ul className="space-y-2">
                        {auraSummary.legalConsiderations.map((consideration, index) => (
                          <li key={index} className="flex items-start gap-3">
                            <span className="flex-shrink-0 w-2 h-2 bg-[#007BFF] rounded-full mt-2"></span>
                            <span className="text-gray-700 dark:text-gray-200">{consideration}</span>
                          </li>
                        ))}
                      </ul>
                    </div>

                    {/* Recommendations */}
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                        Aura's Recommendations
                      </h3>
                      <ul className="space-y-2">
                        {auraSummary.recommendations.map((recommendation, index) => (
                          <li key={index} className="flex items-start gap-3">
                            <span className="flex-shrink-0 w-2 h-2 bg-green-500 rounded-full mt-2"></span>
                            <span className="text-gray-700 dark:text-gray-200">{recommendation}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </Card>
              </motion.div>
            </div>
          </div>
        </main>

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
                <Card className="p-6 bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700">
                  <div className="flex justify-between items-center mb-6">
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white">Add New Event</h3>
                    <button
                      onClick={() => setShowModal(false)}
                      className="text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200"
                    >
                      <X className="w-5 h-5" />
                    </button>
                  </div>

                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-900 dark:text-white mb-2">Event Type</label>
                      <select
                        value={newEvent.type}
                        onChange={(e) => setNewEvent((prev) => ({ ...prev, type: e.target.value as any }))}
                        className="w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:border-[#007BFF] focus:outline-none"
                      >
                        <option value="incident">Incident</option>
                        <option value="document">Document</option>
                        <option value="date">Important Date</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-900 dark:text-white mb-2">Title</label>
                      <Input
                        value={newEvent.title}
                        onChange={(e) => setNewEvent((prev) => ({ ...prev, title: e.target.value }))}
                        placeholder="Event title..."
                        className="bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 focus:border-[#007BFF]"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-900 dark:text-white mb-2">Date</label>
                      <Input
                        type="date"
                        value={newEvent.date}
                        onChange={(e) => setNewEvent((prev) => ({ ...prev, date: e.target.value }))}
                        className="bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 focus:border-[#007BFF]"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-900 dark:text-white mb-2">Importance</label>
                      <select
                        value={newEvent.importance}
                        onChange={(e) => setNewEvent((prev) => ({ ...prev, importance: e.target.value as any }))}
                        className="w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:border-[#007BFF] focus:outline-none"
                      >
                        <option value="low">Low</option>
                        <option value="medium">Medium</option>
                        <option value="high">High</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-900 dark:text-white mb-2">
                        Description
                      </label>
                      <Textarea
                        value={newEvent.description}
                        onChange={(e) => setNewEvent((prev) => ({ ...prev, description: e.target.value }))}
                        placeholder="Event description..."
                        className="bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 focus:border-[#007BFF] min-h-[100px]"
                      />
                    </div>
                  </div>

                  <div className="flex gap-3 mt-6">
                    <Button onClick={addEvent} className="flex-1 bg-[#007BFF] hover:bg-[#0056b3] text-white">
                      Add Event
                    </Button>
                    <Button
                      variant="outline"
                      onClick={() => setShowModal(false)}
                      className="border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 bg-transparent"
                    >
                      Cancel
                    </Button>
                  </div>
                </Card>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </PageContainer>
    </>
  )
}

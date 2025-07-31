"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { AnimatedBackground } from "@/components/animated-background"
import { CursorLight } from "@/components/cursor-light"
import { Navigation } from "@/components/navigation"
import { GlassCard } from "@/components/glass-card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Filter, MapPin, Calendar, DollarSign } from "lucide-react"

const mockCases = [
  {
    id: 1,
    title: "Property Dispute - Commercial Lease",
    location: "Mumbai, Maharashtra",
    type: "Property Law",
    date: "2024-01-15",
    priority: "High",
    budget: "₹50,000 - ₹1,00,000",
    description: "Commercial lease agreement dispute regarding rent escalation clauses.",
  },
  {
    id: 2,
    title: "Employment Termination Case",
    location: "Delhi, NCR",
    type: "Employment Law",
    date: "2024-01-12",
    priority: "Medium",
    budget: "₹25,000 - ₹50,000",
    description: "Wrongful termination case with severance pay disputes.",
  },
  {
    id: 3,
    title: "Intellectual Property Infringement",
    location: "Bangalore, Karnataka",
    type: "IP Law",
    date: "2024-01-10",
    priority: "High",
    budget: "₹1,00,000+",
    description: "Patent infringement case in software technology sector.",
  },
]

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState("all")
  const [locationFilter, setLocationFilter] = useState("")
  const [typeFilter, setTypeFilter] = useState("")
  const [filteredCases, setFilteredCases] = useState(mockCases)

  const applyFilters = () => {
    let filtered = mockCases
    if (locationFilter) {
      filtered = filtered.filter((case_) => case_.location.toLowerCase().includes(locationFilter.toLowerCase()))
    }
    if (typeFilter) {
      filtered = filtered.filter((case_) => case_.type.toLowerCase().includes(typeFilter.toLowerCase()))
    }
    setFilteredCases(filtered)
  }

  return (
    <div className="min-h-screen relative overflow-hidden">
      <AnimatedBackground />
      <CursorLight />
      <Navigation />

      <main className="pt-20 px-4">
        <div className="max-w-7xl mx-auto">
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8">
            <h1 className="text-4xl font-bold text-charcoal dark:text-off-white mb-2">Legal Command Center</h1>
            <p className="text-charcoal/70 dark:text-off-white/70">Manage your cases and discover new opportunities</p>
          </motion.div>

          {/* Filters */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="mb-8"
          >
            <GlassCard className="p-6">
              <div className="flex flex-wrap gap-4 items-end">
                <div className="flex-1 min-w-[200px]">
                  <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">Location</label>
                  <Input
                    placeholder="Filter by location..."
                    value={locationFilter}
                    onChange={(e) => setLocationFilter(e.target.value)}
                    className="bg-white/10 border-white/20"
                  />
                </div>
                <div className="flex-1 min-w-[200px]">
                  <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">Case Type</label>
                  <Input
                    placeholder="Filter by case type..."
                    value={typeFilter}
                    onChange={(e) => setTypeFilter(e.target.value)}
                    className="bg-white/10 border-white/20"
                  />
                </div>
                <Button
                  onClick={applyFilters}
                  className="bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90"
                >
                  <Filter className="w-4 h-4 mr-2" />
                  Apply Filters
                </Button>
              </div>
            </GlassCard>
          </motion.div>

          {/* Tabs */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="mb-6"
          >
            <div className="flex gap-2">
              {["all", "recommended", "active", "completed"].map((tab) => (
                <Button
                  key={tab}
                  variant={activeTab === tab ? "default" : "ghost"}
                  onClick={() => setActiveTab(tab)}
                  className={
                    activeTab === tab
                      ? "bg-prestige-blue dark:bg-electric-blue text-white"
                      : "text-charcoal dark:text-off-white hover:bg-white/10"
                  }
                >
                  {tab.charAt(0).toUpperCase() + tab.slice(1)}
                  {tab === "recommended" && " For You"}
                </Button>
              ))}
            </div>
          </motion.div>

          {/* Cases List */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="space-y-4"
          >
            {filteredCases.map((case_, index) => (
              <motion.div
                key={case_.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 * index }}
                layout
              >
                <GlassCard className="p-6 hover:bg-white/10 transition-all duration-300 cursor-pointer">
                  <div className="flex justify-between items-start mb-4">
                    <div>
                      <h3 className="text-xl font-semibold text-charcoal dark:text-off-white mb-2">{case_.title}</h3>
                      <p className="text-charcoal/70 dark:text-off-white/70 mb-3">{case_.description}</p>
                    </div>
                    <Badge variant={case_.priority === "High" ? "destructive" : "secondary"} className="ml-4">
                      {case_.priority}
                    </Badge>
                  </div>

                  <div className="flex flex-wrap gap-4 text-sm text-charcoal/70 dark:text-off-white/70">
                    <div className="flex items-center gap-1">
                      <MapPin className="w-4 h-4" />
                      {case_.location}
                    </div>
                    <div className="flex items-center gap-1">
                      <Calendar className="w-4 h-4" />
                      {case_.date}
                    </div>
                    <div className="flex items-center gap-1">
                      <DollarSign className="w-4 h-4" />
                      {case_.budget}
                    </div>
                    <Badge variant="outline" className="border-prestige-blue/30 dark:border-electric-blue/30">
                      {case_.type}
                    </Badge>
                  </div>
                </GlassCard>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </main>
    </div>
  )
}

"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { ProNavigation } from "@/components/pro-navigation"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { MapPin, Calendar, DollarSign, Filter, Star, Briefcase } from "lucide-react"

const mockCases = [
  {
    id: 1,
    title: "Property Dispute - Commercial Lease Agreement",
    description:
      "Dispute over rent escalation clauses in commercial lease agreement. Client seeking legal remedy for unfair terms.",
    location: "Mumbai, Maharashtra",
    specialization: "Property Law",
    budget: "₹75,000 - ₹1,50,000",
    urgency: "High",
    postedDate: "2024-01-15",
    clientRating: 4.8,
    auraMatch: 95,
    auraReason: "Perfect match for your Property Law expertise and Mumbai location",
  },
  {
    id: 2,
    title: "Employment Termination Without Notice",
    description:
      "Wrongful termination case involving senior executive. Seeking compensation and reinstatement options.",
    location: "Delhi, NCR",
    specialization: "Employment Law",
    budget: "₹50,000 - ₹1,00,000",
    urgency: "Medium",
    postedDate: "2024-01-14",
    clientRating: 4.6,
    auraMatch: 88,
    auraReason: "Matches your Employment Law specialization",
  },
  {
    id: 3,
    title: "Intellectual Property Infringement Case",
    description: "Patent infringement in software technology. Need expert legal counsel for litigation proceedings.",
    location: "Bangalore, Karnataka",
    specialization: "IP Law",
    budget: "₹2,00,000+",
    urgency: "High",
    postedDate: "2024-01-13",
    clientRating: 4.9,
    auraMatch: 72,
    auraReason: "High-value case matching your litigation experience",
  },
  {
    id: 4,
    title: "Corporate Merger Legal Advisory",
    description: "Legal advisory for mid-size company merger. Due diligence and regulatory compliance required.",
    location: "Chennai, Tamil Nadu",
    specialization: "Corporate Law",
    budget: "₹3,00,000+",
    urgency: "Medium",
    postedDate: "2024-01-12",
    clientRating: 4.7,
    auraMatch: 85,
    auraReason: "Corporate expertise aligns with your practice areas",
  },
]

const locations = ["All Locations", "Mumbai, Maharashtra", "Delhi, NCR", "Bangalore, Karnataka", "Chennai, Tamil Nadu"]
const specializations = [
  "All Specializations",
  "Property Law",
  "Employment Law",
  "IP Law",
  "Corporate Law",
  "Criminal Law",
]

export default function ProDashboard() {
  const [activeTab, setActiveTab] = useState("live-feed")
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedLocation, setSelectedLocation] = useState("All Locations")
  const [selectedSpecialization, setSelectedSpecialization] = useState("All Specializations")
  const [filteredCases, setFilteredCases] = useState(mockCases)

  const applyFilters = () => {
    let filtered = mockCases

    if (selectedLocation !== "All Locations") {
      filtered = filtered.filter((case_) => case_.location === selectedLocation)
    }

    if (selectedSpecialization !== "All Specializations") {
      filtered = filtered.filter((case_) => case_.specialization === selectedSpecialization)
    }

    if (searchQuery.trim()) {
      filtered = filtered.filter(
        (case_) =>
          case_.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          case_.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
          case_.specialization.toLowerCase().includes(searchQuery.toLowerCase()),
      )
    }

    setFilteredCases(filtered)
  }

  const getUrgencyColor = (urgency: string) => {
    switch (urgency) {
      case "High":
        return "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
      case "Medium":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
      case "Low":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    }
  }

  const auraRecommendations = mockCases.filter((case_) => case_.auraMatch >= 85)

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <ProNavigation />

        <main className="pt-24 pb-16">
          <div className="px-6 max-w-7xl mx-auto">
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8">
              <h1 className="text-4xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">Professional Dashboard</h1>
              <p className="text-xl text-gray-600 dark:text-gray-300">
                Manage your legal practice with AI-powered insights
              </p>
            </motion.div>

            <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
              <TabsList className="grid w-full grid-cols-2 bg-gray-100 dark:bg-[#0D1B2A]/50">
                <TabsTrigger
                  value="live-feed"
                  className="data-[state=active]:bg-[#007BFF] dark:data-[state=active]:bg-[#00FFFF] data-[state=active]:text-white dark:data-[state=active]:text-[#0D1B2A]"
                >
                  Live Lead Feed
                </TabsTrigger>
                <TabsTrigger
                  value="aura-recommendations"
                  className="data-[state=active]:bg-[#007BFF] dark:data-[state=active]:bg-[#00FFFF] data-[state=active]:text-white dark:data-[state=active]:text-[#0D1B2A]"
                >
                  Aura's Recommendations
                </TabsTrigger>
              </TabsList>

              <TabsContent value="live-feed" className="space-y-6">
                {/* Filters */}
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                    <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                          Keywords
                        </label>
                        <Input
                          value={searchQuery}
                          onChange={(e) => setSearchQuery(e.target.value)}
                          placeholder="Search cases..."
                          className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                          onKeyPress={(e) => e.key === "Enter" && applyFilters()}
                        />
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                          Location
                        </label>
                        <select
                          value={selectedLocation}
                          onChange={(e) => setSelectedLocation(e.target.value)}
                          className="w-full px-3 py-2 bg-white dark:bg-[#0D1B2A]/50 border border-gray-300 dark:border-[#1B263B] rounded-md text-gray-900 dark:text-[#E0E6F1] focus:border-[#007BFF] dark:focus:border-[#00FFFF] focus:outline-none transition-all duration-300"
                        >
                          {locations.map((location) => (
                            <option key={location} value={location}>
                              {location}
                            </option>
                          ))}
                        </select>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                          Legal Specialization
                        </label>
                        <select
                          value={selectedSpecialization}
                          onChange={(e) => setSelectedSpecialization(e.target.value)}
                          className="w-full px-3 py-2 bg-white dark:bg-[#0D1B2A]/50 border border-gray-300 dark:border-[#1B263B] rounded-md text-gray-900 dark:text-[#E0E6F1] focus:border-[#007BFF] dark:focus:border-[#00FFFF] focus:outline-none transition-all duration-300"
                        >
                          {specializations.map((spec) => (
                            <option key={spec} value={spec}>
                              {spec}
                            </option>
                          ))}
                        </select>
                      </div>

                      <div className="flex items-end">
                        <Button
                          onClick={applyFilters}
                          className="w-full bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                        >
                          <Filter className="w-4 h-4 mr-2" />
                          Apply Filters
                        </Button>
                      </div>
                    </div>
                  </Card>
                </motion.div>

                {/* Cases List */}
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.2 }}
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
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF]/50 dark:hover:border-[#00FFFF]/50 transition-all duration-300 prestigious-hover dark:hover:glow-cyan">
                        <div className="flex justify-between items-start mb-4">
                          <div className="flex-1">
                            <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">
                              {case_.title}
                            </h3>
                            <p className="text-gray-600 dark:text-gray-300 mb-4 leading-relaxed">{case_.description}</p>
                          </div>
                          <Badge className={getUrgencyColor(case_.urgency)}>{case_.urgency} Priority</Badge>
                        </div>

                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4 text-sm">
                          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
                            <MapPin className="w-4 h-4" />
                            {case_.location}
                          </div>
                          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
                            <Briefcase className="w-4 h-4" />
                            {case_.specialization}
                          </div>
                          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
                            <DollarSign className="w-4 h-4" />
                            {case_.budget}
                          </div>
                          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
                            <Calendar className="w-4 h-4" />
                            {new Date(case_.postedDate).toLocaleDateString()}
                          </div>
                        </div>

                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-4">
                            <div className="flex items-center gap-1">
                              <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                              <span className="text-sm font-medium text-gray-900 dark:text-[#E0E6F1]">
                                {case_.clientRating}
                              </span>
                              <span className="text-sm text-gray-600 dark:text-gray-300">Client Rating</span>
                            </div>
                          </div>

                          <div className="flex gap-3">
                            <Button
                              variant="outline"
                              size="sm"
                              className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                            >
                              View Details
                            </Button>
                            <Button
                              size="sm"
                              className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                            >
                              Express Interest
                            </Button>
                          </div>
                        </div>
                      </Card>
                    </motion.div>
                  ))}
                </motion.div>
              </TabsContent>

              <TabsContent value="aura-recommendations" className="space-y-6">
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center mb-8">
                  <h2 className="text-3xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">Aura's Recommendations</h2>
                  <p className="text-xl text-gray-600 dark:text-gray-300">
                    Cases specially selected by Aura based on your expertise and preferences
                  </p>
                </motion.div>

                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.2 }}
                  className="space-y-4"
                >
                  {auraRecommendations.map((case_, index) => (
                    <motion.div
                      key={case_.id}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.1 * index }}
                    >
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF]/50 dark:hover:border-[#00FFFF]/50 transition-all duration-300 relative prestigious-hover dark:hover:glow-cyan">
                        {/* Aura Match Badge */}
                        <div className="absolute top-4 right-4">
                          <Badge className="bg-[#007BFF] dark:bg-[#00FFFF] text-white dark:text-[#0D1B2A]">
                            {case_.auraMatch}% Match
                          </Badge>
                        </div>

                        <div className="flex justify-between items-start mb-4 pr-20">
                          <div className="flex-1">
                            <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">
                              {case_.title}
                            </h3>
                            <p className="text-gray-600 dark:text-gray-300 mb-4 leading-relaxed">{case_.description}</p>
                          </div>
                        </div>

                        {/* Aura's Reasoning */}
                        <div className="bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg p-4 mb-4">
                          <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">
                            Why Aura recommends this case:
                          </h4>
                          <p className="text-gray-600 dark:text-gray-300 text-sm">{case_.auraReason}</p>
                        </div>

                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4 text-sm">
                          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
                            <MapPin className="w-4 h-4" />
                            {case_.location}
                          </div>
                          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
                            <Briefcase className="w-4 h-4" />
                            {case_.specialization}
                          </div>
                          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
                            <DollarSign className="w-4 h-4" />
                            {case_.budget}
                          </div>
                          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
                            <Calendar className="w-4 h-4" />
                            {new Date(case_.postedDate).toLocaleDateString()}
                          </div>
                        </div>

                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-4">
                            <div className="flex items-center gap-1">
                              <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                              <span className="text-sm font-medium text-gray-900 dark:text-[#E0E6F1]">
                                {case_.clientRating}
                              </span>
                              <span className="text-sm text-gray-600 dark:text-gray-300">Client Rating</span>
                            </div>
                            <Badge className={getUrgencyColor(case_.urgency)}>{case_.urgency} Priority</Badge>
                          </div>

                          <div className="flex gap-3">
                            <Button
                              variant="outline"
                              size="sm"
                              className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                            >
                              View Details
                            </Button>
                            <Button
                              size="sm"
                              className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                            >
                              Accept Recommendation
                            </Button>
                          </div>
                        </div>
                      </Card>
                    </motion.div>
                  ))}
                </motion.div>
              </TabsContent>
            </Tabs>
          </div>
        </main>
      </PageContainer>
    </>
  )
}

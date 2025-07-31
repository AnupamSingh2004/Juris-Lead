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
import { MapPin, Calendar, DollarSign, Filter, Star, Briefcase, Clock, CheckCircle, AlertCircle } from "lucide-react"

const mockAcceptedCases = [
  {
    id: 1,
    title: "Property Dispute - Commercial Lease Agreement",
    client: "Rajesh Enterprises Pvt Ltd",
    description:
      "Dispute over rent escalation clauses in commercial lease agreement. Client seeking legal remedy for unfair terms.",
    location: "Mumbai, Maharashtra",
    specialization: "Property Law",
    budget: "₹75,000",
    status: "active",
    priority: "high",
    acceptedDate: "2024-01-10",
    deadline: "2024-03-15",
    progress: 65,
    clientRating: 4.8,
    lastUpdate: "2024-01-20",
  },
  {
    id: 2,
    title: "Employment Termination Case",
    client: "Priya Sharma",
    description:
      "Wrongful termination case involving senior executive. Seeking compensation and reinstatement options.",
    location: "Delhi, NCR",
    specialization: "Employment Law",
    budget: "₹50,000",
    status: "pending",
    priority: "medium",
    acceptedDate: "2024-01-12",
    deadline: "2024-02-28",
    progress: 30,
    clientRating: 4.6,
    lastUpdate: "2024-01-18",
  },
  {
    id: 3,
    title: "Contract Breach Litigation",
    client: "TechCorp Solutions",
    description: "Breach of software development contract. Multiple parties involved with complex liability issues.",
    location: "Bangalore, Karnataka",
    specialization: "Corporate Law",
    budget: "₹1,20,000",
    status: "completed",
    priority: "high",
    acceptedDate: "2023-12-01",
    deadline: "2024-01-15",
    progress: 100,
    clientRating: 4.9,
    lastUpdate: "2024-01-15",
  },
]

export default function MyCasesPage() {
  const [activeTab, setActiveTab] = useState("all")
  const [searchQuery, setSearchQuery] = useState("")
  const [filteredCases, setFilteredCases] = useState(mockAcceptedCases)

  const applyFilters = () => {
    let filtered = mockAcceptedCases

    if (activeTab !== "all") {
      filtered = filtered.filter((case_) => case_.status === activeTab)
    }

    if (searchQuery.trim()) {
      filtered = filtered.filter(
        (case_) =>
          case_.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          case_.client.toLowerCase().includes(searchQuery.toLowerCase()) ||
          case_.specialization.toLowerCase().includes(searchQuery.toLowerCase()),
      )
    }

    setFilteredCases(filtered)
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
      case "pending":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
      case "completed":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "active":
        return <Clock className="w-4 h-4" />
      case "pending":
        return <AlertCircle className="w-4 h-4" />
      case "completed":
        return <CheckCircle className="w-4 h-4" />
      default:
        return <Clock className="w-4 h-4" />
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
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

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <ProNavigation />

        <main className="pt-24 pb-16">
          <div className="px-6 max-w-7xl mx-auto">
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8">
              <h1 className="text-4xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">My Cases</h1>
              <p className="text-xl text-gray-600 dark:text-gray-300">Manage your accepted cases and track progress</p>
            </motion.div>

            {/* Stats Cards */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8"
            >
              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover dark:hover:glow-cyan">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                    <Briefcase className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-300">Total Cases</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">{mockAcceptedCases.length}</p>
                  </div>
                </div>
              </Card>

              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover dark:hover:glow-cyan">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                    <Clock className="w-6 h-6 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-300">Active Cases</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">
                      {mockAcceptedCases.filter((c) => c.status === "active").length}
                    </p>
                  </div>
                </div>
              </Card>

              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover dark:hover:glow-cyan">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-green-100 dark:bg-green-900/30 rounded-lg">
                    <CheckCircle className="w-6 h-6 text-green-600 dark:text-green-400" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-300">Completed</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">
                      {mockAcceptedCases.filter((c) => c.status === "completed").length}
                    </p>
                  </div>
                </div>
              </Card>

              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover dark:hover:glow-cyan">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-yellow-100 dark:bg-yellow-900/30 rounded-lg">
                    <DollarSign className="w-6 h-6 text-yellow-600 dark:text-yellow-400" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600 dark:text-gray-300">Total Earnings</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">₹2,45,000</p>
                  </div>
                </div>
              </Card>
            </motion.div>

            <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
              <div className="flex flex-col md:flex-row gap-4 items-start md:items-center justify-between">
                <TabsList className="bg-gray-100 dark:bg-[#0D1B2A]/50">
                  <TabsTrigger
                    value="all"
                    className="data-[state=active]:bg-[#007BFF] dark:data-[state=active]:bg-[#00FFFF] data-[state=active]:text-white dark:data-[state=active]:text-[#0D1B2A]"
                  >
                    All Cases
                  </TabsTrigger>
                  <TabsTrigger
                    value="active"
                    className="data-[state=active]:bg-[#007BFF] dark:data-[state=active]:bg-[#00FFFF] data-[state=active]:text-white dark:data-[state=active]:text-[#0D1B2A]"
                  >
                    Active
                  </TabsTrigger>
                  <TabsTrigger
                    value="pending"
                    className="data-[state=active]:bg-[#007BFF] dark:data-[state=active]:bg-[#00FFFF] data-[state=active]:text-white dark:data-[state=active]:text-[#0D1B2A]"
                  >
                    Pending
                  </TabsTrigger>
                  <TabsTrigger
                    value="completed"
                    className="data-[state=active]:bg-[#007BFF] dark:data-[state=active]:bg-[#00FFFF] data-[state=active]:text-white dark:data-[state=active]:text-[#0D1B2A]"
                  >
                    Completed
                  </TabsTrigger>
                </TabsList>

                <div className="flex gap-4 w-full md:w-auto">
                  <Input
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="Search cases..."
                    className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                    onKeyPress={(e) => e.key === "Enter" && applyFilters()}
                  />
                  <Button
                    onClick={applyFilters}
                    className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                  >
                    <Filter className="w-4 h-4 mr-2" />
                    Filter
                  </Button>
                </div>
              </div>

              <TabsContent value={activeTab} className="space-y-6">
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
                            <div className="flex items-center gap-3 mb-2">
                              <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1]">{case_.title}</h3>
                              <Badge className={getStatusColor(case_.status)}>
                                {getStatusIcon(case_.status)}
                                <span className="ml-1 capitalize">{case_.status}</span>
                              </Badge>
                              <Badge className={getPriorityColor(case_.priority)}>{case_.priority} Priority</Badge>
                            </div>
                            <p className="text-gray-600 dark:text-gray-300 mb-2">
                              <strong>Client:</strong> {case_.client}
                            </p>
                            <p className="text-gray-600 dark:text-gray-300 mb-4 leading-relaxed">{case_.description}</p>
                          </div>
                        </div>

                        {/* Progress Bar */}
                        {case_.status !== "completed" && (
                          <div className="mb-4">
                            <div className="flex justify-between items-center mb-2">
                              <span className="text-sm font-medium text-gray-700 dark:text-gray-300">Progress</span>
                              <span className="text-sm text-gray-600 dark:text-gray-400">{case_.progress}%</span>
                            </div>
                            <div className="w-full bg-gray-200 dark:bg-[#0D1B2A]/50 rounded-full h-2">
                              <div
                                className="bg-[#007BFF] dark:bg-[#00FFFF] h-2 rounded-full transition-all duration-300"
                                style={{ width: `${case_.progress}%` }}
                              ></div>
                            </div>
                          </div>
                        )}

                        <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-4 text-sm">
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
                            Due: {new Date(case_.deadline).toLocaleDateString()}
                          </div>
                          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
                            <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                            {case_.clientRating}
                          </div>
                        </div>

                        <div className="flex items-center justify-between">
                          <div className="text-sm text-gray-500 dark:text-gray-400">
                            Last updated: {new Date(case_.lastUpdate).toLocaleDateString()}
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
                              Update Progress
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

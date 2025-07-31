"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { Navigation } from "@/components/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Star, MapPin, Phone, Mail, Award, Filter, Users, Briefcase, Clock, CheckCircle } from "lucide-react"
import Link from "next/link"

const lawyers = [
  {
    id: 1,
    name: "Adv. Priya Sharma",
    specialization: "Criminal Law",
    location: "Mumbai, Maharashtra",
    experience: 15,
    rating: 4.9,
    reviews: 127,
    budget: "Premium",
    phone: "+91 98765 43210",
    email: "priya.sharma@example.com",
    image: "/placeholder.svg?height=100&width=100",
    expertise: ["White Collar Crime", "Criminal Defense", "Bail Applications"],
    languages: ["English", "Hindi", "Marathi"],
    description: "Specialized in complex criminal cases with over 15 years of experience in high-profile matters.",
    verified: true,
    responseTime: "Within 2 hours",
    successRate: 94,
  },
  {
    id: 2,
    name: "Adv. Rajesh Kumar",
    specialization: "Corporate Law",
    location: "Delhi, NCR",
    experience: 12,
    rating: 4.7,
    reviews: 89,
    budget: "Moderate",
    phone: "+91 98765 43211",
    email: "rajesh.kumar@example.com",
    image: "/placeholder.svg?height=100&width=100",
    expertise: ["Mergers & Acquisitions", "Corporate Compliance", "Contract Law"],
    languages: ["English", "Hindi"],
    description: "Expert in corporate transactions and regulatory compliance for businesses of all sizes.",
    verified: true,
    responseTime: "Within 4 hours",
    successRate: 91,
  },
  {
    id: 3,
    name: "Adv. Meera Patel",
    specialization: "Family Law",
    location: "Bangalore, Karnataka",
    experience: 10,
    rating: 4.8,
    reviews: 156,
    budget: "Affordable",
    phone: "+91 98765 43212",
    email: "meera.patel@example.com",
    image: "/placeholder.svg?height=100&width=100",
    expertise: ["Divorce Proceedings", "Child Custody", "Property Settlement"],
    languages: ["English", "Hindi", "Kannada"],
    description: "Compassionate approach to family law matters with focus on amicable resolutions.",
    verified: true,
    responseTime: "Within 6 hours",
    successRate: 88,
  },
  {
    id: 4,
    name: "Adv. Arjun Singh",
    specialization: "Property Law",
    location: "Chennai, Tamil Nadu",
    experience: 18,
    rating: 4.6,
    reviews: 203,
    budget: "Premium",
    phone: "+91 98765 43213",
    email: "arjun.singh@example.com",
    image: "/placeholder.svg?height=100&width=100",
    expertise: ["Real Estate Transactions", "Land Acquisition", "Property Disputes"],
    languages: ["English", "Hindi", "Tamil"],
    description: "Extensive experience in property law with successful track record in complex real estate matters.",
    verified: true,
    responseTime: "Within 3 hours",
    successRate: 92,
  },
]

const locations = ["All Locations", "Mumbai, Maharashtra", "Delhi, NCR", "Bangalore, Karnataka", "Chennai, Tamil Nadu"]
const specializations = [
  "All Specializations",
  "Criminal Law",
  "Corporate Law",
  "Family Law",
  "Property Law",
  "Employment Law",
]
const budgetRanges = ["All Budgets", "Affordable", "Moderate", "Premium"]

export default function FindLawyerPage() {
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedLocation, setSelectedLocation] = useState("All Locations")
  const [selectedSpecialization, setSelectedSpecialization] = useState("All Specializations")
  const [selectedBudget, setSelectedBudget] = useState("All Budgets")
  const [filteredLawyers, setFilteredLawyers] = useState(lawyers)
  const [showFilters, setShowFilters] = useState(false)

  const applyFilters = () => {
    try {
      let filtered = lawyers

      if (selectedLocation !== "All Locations") {
        filtered = filtered.filter((lawyer) => lawyer.location === selectedLocation)
      }

      if (selectedSpecialization !== "All Specializations") {
        filtered = filtered.filter((lawyer) => lawyer.specialization === selectedSpecialization)
      }

      if (selectedBudget !== "All Budgets") {
        filtered = filtered.filter((lawyer) => lawyer.budget === selectedBudget)
      }

      if (searchQuery.trim()) {
        filtered = filtered.filter(
          (lawyer) =>
            lawyer.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            lawyer.specialization.toLowerCase().includes(searchQuery.toLowerCase()) ||
            lawyer.expertise.some((exp) => exp.toLowerCase().includes(searchQuery.toLowerCase())),
        )
      }

      setFilteredLawyers(filtered)
    } catch (error) {
      console.error("Error filtering lawyers:", error)
      setFilteredLawyers([])
    }
  }

  const getBudgetColor = (budget: string) => {
    switch (budget) {
      case "Affordable":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      case "Moderate":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
      case "Premium":
        return "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    }
  }

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <Navigation />

        <main className="pt-24 pb-16">
          <div className="px-6 max-w-6xl mx-auto">
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
                  <Users className="w-10 h-10 text-white" />
                </motion.div>
                <div className="text-left">
                  <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">
                    Find Expert Legal Counsel
                  </h1>
                  <p className="text-xl text-gray-600 dark:text-gray-300">Connect with verified lawyers across India</p>
                </div>
              </div>
            </motion.div>

            {/* Search and Filters */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="mb-8"
            >
              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                <div className="flex flex-col md:flex-row gap-4 mb-4">
                  <div className="flex-1">
                    <Input
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      placeholder="Search by name, specialization, or expertise..."
                      className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                      onKeyPress={(e) => e.key === "Enter" && applyFilters()}
                    />
                  </div>
                  <Button
                    onClick={() => setShowFilters(!showFilters)}
                    variant="outline"
                    className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                  >
                    <Filter className="w-4 h-4 mr-2" />
                    Filters
                  </Button>
                  <motion.div
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    transition={{ type: "spring", stiffness: 300 }}
                  >
                    <Button
                      onClick={applyFilters}
                      className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                    >
                      Search
                    </Button>
                  </motion.div>
                </div>

                {showFilters && (
                  <motion.div
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: "auto" }}
                    className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-4 border-t border-gray-200 dark:border-[#1B263B]"
                  >
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
                        Specialization
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

                    <div>
                      <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                        Budget Range
                      </label>
                      <select
                        value={selectedBudget}
                        onChange={(e) => setSelectedBudget(e.target.value)}
                        className="w-full px-3 py-2 bg-white dark:bg-[#0D1B2A]/50 border border-gray-300 dark:border-[#1B263B] rounded-md text-gray-900 dark:text-[#E0E6F1] focus:border-[#007BFF] dark:focus:border-[#00FFFF] focus:outline-none transition-all duration-300"
                      >
                        {budgetRanges.map((budget) => (
                          <option key={budget} value={budget}>
                            {budget}
                          </option>
                        ))}
                      </select>
                    </div>
                  </motion.div>
                )}
              </Card>
            </motion.div>

            {/* Results */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.3 }}
              className="space-y-6"
            >
              <div className="flex justify-between items-center">
                <h2 className="text-2xl font-semibold text-gray-900 dark:text-[#E0E6F1]">
                  {filteredLawyers.length} Lawyers Found
                </h2>
              </div>

              <div className="grid gap-6">
                {filteredLawyers.map((lawyer, index) => (
                  <motion.div
                    key={lawyer.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.1 * index }}
                    whileHover={{ y: -2 }}
                  >
                    <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF]/50 dark:hover:border-[#00FFFF]/50 transition-all duration-300 prestigious-hover dark:hover:glow-cyan">
                      <div className="flex flex-col lg:flex-row gap-6">
                        <div className="flex-shrink-0">
                          <div className="relative">
                            <img
                              src={lawyer.image || "/placeholder.svg"}
                              alt={lawyer.name}
                              className="w-24 h-24 rounded-full object-cover border-4 border-[#007BFF] dark:border-[#00FFFF] shadow-lg"
                            />
                            {lawyer.verified && (
                              <div className="absolute -bottom-1 -right-1 w-8 h-8 bg-green-500 rounded-full flex items-center justify-center border-2 border-white dark:border-[#1B263B]">
                                <CheckCircle className="w-5 h-5 text-white" />
                              </div>
                            )}
                          </div>
                        </div>

                        <div className="flex-1">
                          <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between mb-4">
                            <div className="flex-1">
                              <div className="flex items-center gap-3 mb-2">
                                <h3 className="text-2xl font-semibold text-gray-900 dark:text-[#E0E6F1]">
                                  {lawyer.name}
                                </h3>
                                {lawyer.verified && (
                                  <Badge className="bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300">
                                    <CheckCircle className="w-3 h-3 mr-1" />
                                    Verified
                                  </Badge>
                                )}
                              </div>
                              <p className="text-[#007BFF] dark:text-[#00FFFF] font-medium mb-2 text-lg">
                                {lawyer.specialization}
                              </p>
                              <div className="flex flex-wrap items-center gap-4 text-sm text-gray-600 dark:text-gray-300 mb-3">
                                <div className="flex items-center gap-1">
                                  <MapPin className="w-4 h-4" />
                                  {lawyer.location}
                                </div>
                                <div className="flex items-center gap-1">
                                  <Award className="w-4 h-4" />
                                  {lawyer.experience} years
                                </div>
                                <div className="flex items-center gap-1">
                                  <Clock className="w-4 h-4" />
                                  {lawyer.responseTime}
                                </div>
                                <div className="flex items-center gap-1">
                                  <Briefcase className="w-4 h-4" />
                                  {lawyer.successRate}% success rate
                                </div>
                              </div>
                            </div>

                            <div className="flex flex-col items-start lg:items-end gap-2">
                              <div className="flex items-center gap-2">
                                <div className="flex items-center gap-1">
                                  <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                                  <span className="font-semibold text-gray-900 dark:text-[#E0E6F1]">
                                    {lawyer.rating}
                                  </span>
                                </div>
                                <span className="text-sm text-gray-600 dark:text-gray-300">
                                  ({lawyer.reviews} reviews)
                                </span>
                              </div>
                              <Badge className={getBudgetColor(lawyer.budget)}>{lawyer.budget}</Badge>
                            </div>
                          </div>

                          <p className="text-gray-700 dark:text-gray-300 mb-4 leading-relaxed">{lawyer.description}</p>

                          <div className="flex flex-wrap gap-2 mb-4">
                            {lawyer.expertise.map((skill, skillIndex) => (
                              <Badge
                                key={skillIndex}
                                variant="outline"
                                className="border-gray-300 dark:border-[#1B263B] text-gray-600 dark:text-gray-300"
                              >
                                {skill}
                              </Badge>
                            ))}
                          </div>

                          <div className="flex flex-wrap gap-2 mb-4">
                            {lawyer.languages.map((language, langIndex) => (
                              <Badge
                                key={langIndex}
                                variant="secondary"
                                className="bg-gray-100 dark:bg-[#0D1B2A]/50 text-gray-600 dark:text-gray-300"
                              >
                                {language}
                              </Badge>
                            ))}
                          </div>

                          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                            <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-300">
                              <div className="flex items-center gap-1">
                                <Phone className="w-4 h-4" />
                                {lawyer.phone}
                              </div>
                              <div className="flex items-center gap-1">
                                <Mail className="w-4 h-4" />
                                {lawyer.email}
                              </div>
                            </div>

                            <div className="flex gap-3">
                              <Button
                                asChild
                                variant="outline"
                                className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                              >
                                <Link href={`/find-lawyer/${lawyer.id}`}>View Profile</Link>
                              </Button>
                              <motion.div
                                whileHover={{ scale: 1.05 }}
                                whileTap={{ scale: 0.95 }}
                                transition={{ type: "spring", stiffness: 300 }}
                              >
                                <Button className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan">
                                  Contact Lawyer
                                </Button>
                              </motion.div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </Card>
                  </motion.div>
                ))}
              </div>

              {filteredLawyers.length === 0 && (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="text-center py-16">
                  <Users className="w-16 h-16 text-gray-400 dark:text-gray-500 mx-auto mb-4" />
                  <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">No lawyers found</h3>
                  <p className="text-gray-600 dark:text-gray-300">Try adjusting your search criteria or filters</p>
                </motion.div>
              )}
            </motion.div>
          </div>
        </main>
      </PageContainer>
    </>
  )
}

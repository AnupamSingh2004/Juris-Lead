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
import { Search, BookOpen, Scale, Users, Building, Briefcase, Shield, ArrowRight, Clock, Star, FileText, AlertTriangle, CheckCircle } from "lucide-react"
import ipcData from '../../ipc.json'

const legalTopics = [
  {
    id: 1,
    title: "Criminal Law",
    description: "Understanding criminal offenses, procedures, and penalties under Indian law",
    icon: <Scale className="w-8 h-8" />,
    articles: 45,
    category: "Core Law",
    tags: ["IPC", "CrPC", "Evidence Act"],
    difficulty: "Intermediate",
    readTime: "15 min",
    rating: 4.8,
    color: "from-red-500 to-pink-500",
  },
  {
    id: 2,
    title: "Contract Law",
    description: "Formation, performance, and breach of contracts in commercial transactions",
    icon: <BookOpen className="w-8 h-8" />,
    articles: 32,
    category: "Commercial Law",
    tags: ["Indian Contract Act", "Commercial", "Business"],
    difficulty: "Beginner",
    readTime: "12 min",
    rating: 4.6,
    color: "from-blue-500 to-cyan-500",
  },
  {
    id: 3,
    title: "Property Law",
    description: "Real estate transactions, property rights, and land acquisition laws",
    icon: <Building className="w-8 h-8" />,
    articles: 28,
    category: "Property",
    tags: ["Real Estate", "Land Rights", "Registration"],
    difficulty: "Advanced",
    readTime: "20 min",
    rating: 4.7,
    color: "from-green-500 to-emerald-500",
  },
  {
    id: 4,
    title: "Family Law",
    description: "Marriage, divorce, custody, and inheritance matters under personal laws",
    icon: <Users className="w-8 h-8" />,
    articles: 38,
    category: "Personal Law",
    tags: ["Marriage", "Divorce", "Custody", "Inheritance"],
    difficulty: "Intermediate",
    readTime: "18 min",
    rating: 4.9,
    color: "from-purple-500 to-violet-500",
  },
  {
    id: 5,
    title: "Employment Law",
    description: "Labor rights, workplace disputes, and employment regulations",
    icon: <Briefcase className="w-8 h-8" />,
    articles: 25,
    category: "Labor Law",
    tags: ["Labor Rights", "Employment", "Workplace"],
    difficulty: "Intermediate",
    readTime: "14 min",
    rating: 4.5,
    color: "from-orange-500 to-red-500",
  },
  {
    id: 6,
    title: "Consumer Protection",
    description: "Consumer rights, product liability, and service deficiency remedies",
    icon: <Shield className="w-8 h-8" />,
    articles: 22,
    category: "Consumer Law",
    tags: ["Consumer Rights", "Product Liability", "Services"],
    difficulty: "Beginner",
    readTime: "10 min",
    rating: 4.4,
    color: "from-indigo-500 to-blue-500",
  },
]

// IPC Sections Database - Loaded from JSON file
const ipcSections = ipcData.filter(section => section.section && section.title) // Filter out incomplete entries

const categories = ["All", "Core Law", "Commercial Law", "Property", "Personal Law", "Labor Law", "Consumer Law", "IPC Sections"]

export default function ExplorePage() {
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("All")
  const [filteredTopics, setFilteredTopics] = useState(legalTopics)
  const [filteredIPCSections, setFilteredIPCSections] = useState<any[]>([])
  const [showIPCResults, setShowIPCResults] = useState(false)
  const [selectedIPCSection, setSelectedIPCSection] = useState<any>(null)
  const [showIPCModal, setShowIPCModal] = useState(false)

  const handleSearch = () => {
    try {
      let filteredLegalTopics = legalTopics
      let filteredIPC: any[] = []
      let showIPC = false

      // Enhanced search logic for IPC sections
      if (searchQuery.trim()) {
        const query = searchQuery.toLowerCase().trim()
        
        // Check if search query contains IPC section numbers (various formats)
        const ipcPatterns = [
          /(?:section\s*)?(\d{2,3}[a-z]?)\s*(?:ipc|of\s*ipc)?/i,  // Section 302, 302 IPC, etc.
          /ipc\s*(\d{2,3}[a-z]?)/i,  // IPC 302
          /(\d{2,3}[a-z]?)\s*(?:of\s*)?ipc/i  // 302 of IPC
        ]
        
        let sectionNumberMatch = null
        for (const pattern of ipcPatterns) {
          const match = query.match(pattern)
          if (match) {
            sectionNumberMatch = match[1]
            break
          }
        }

        // Always search IPC sections if:
        // 1. Query contains IPC section numbers
        // 2. Query contains "ipc" keyword
        // 3. Category is "IPC Sections"
        // 4. Query matches common crime keywords
        const crimeKeywords = [
          // Violence & Murder
          'murder', 'kill', 'killing', 'death', 'homicide', 'assault', 'hurt', 'violence', 'attack', 'harm',
          'fight', 'beating', 'stabbing', 'shooting', 'weapon', 'knife', 'gun', 'acid', 'poisoning',
          // Property Crimes  
          'theft', 'steal', 'stealing', 'rob', 'robbery', 'burglary', 'house', 'dwelling', 'property',
          'fraud', 'cheat', 'cheating', 'scam', 'money', 'extortion', 'blackmail', 'ransom',
          'forgery', 'counterfeit', 'fake', 'document', 'misappropriation', 'embezzlement',
          // Sexual Crimes
          'rape', 'sexual', 'molestation', 'harassment', 'modesty', 'consent', 'women', 'stalking',
          'eve-teasing', 'obscene', 'indecent', 'pornography',
          // Domestic & Social
          'domestic', 'dowry', 'cruelty', 'husband', 'wife', 'marriage', 'family', 'in-laws',
          'woman', 'child', 'minor', 'trafficking', 'kidnapping', 'abduction',
          // Public Order
          'intimidation', 'threat', 'fear', 'criminal', 'menace', 'insult', 'defamation',
          'riot', 'unlawful', 'assembly', 'protest', 'public', 'peace', 'disturbance',
          // Modern Crimes
          'cyber', 'hacking', 'computer', 'internet', 'online', 'digital', 'electronic', 'technology',
          'phone', 'mobile', 'social media', 'identity', 'phishing',
          // Legal Concepts
          'attempt', 'conspiracy', 'negligence', 'rash', 'accident', 'intention', 'knowledge',
          'abetment', 'instigation', 'conspiracy', 'common intention', 'wrongful'
        ]
        
        const hasCommonCrimeKeyword = crimeKeywords.some(keyword => 
          query.includes(keyword)
        )

        if (sectionNumberMatch || query.includes('ipc') || selectedCategory === "IPC Sections" || hasCommonCrimeKeyword) {
          // Search IPC sections with multiple criteria
          filteredIPC = ipcSections.filter((section: any) => {
            // Skip incomplete entries
            if (!section.section || !section.title) return false
            
            // Direct section number match (highest priority)
            if (sectionNumberMatch) {
              return section.section.toLowerCase().includes(sectionNumberMatch.toLowerCase())
            }
            
            // Comprehensive keyword matching
            const searchTerms = query.split(/\s+/).filter((term: string) => term.length > 2)
            
            return searchTerms.some((term: string) => 
              // Section number and title
              section.section.toLowerCase().includes(term) ||
              section.title.toLowerCase().includes(term) ||
              // Safe optional chaining for potentially undefined fields
              (section.description && section.description.toLowerCase().includes(term)) ||
              (section.category && section.category.toLowerCase().includes(term)) ||
              (section.chapter && section.chapter.toLowerCase().includes(term)) ||
              // Keywords array matching (check if exists and is array)
              (section.keywords && Array.isArray(section.keywords) && 
                section.keywords.some((keyword: string) => 
                  keyword.toLowerCase().includes(term) || 
                  term.includes(keyword.toLowerCase())
                )) ||
              // Punishment text matching
              (section.punishment && section.punishment.toLowerCase().includes(term)) ||
              // Related sections matching (check if exists and is array)
              (section.relatedSections && Array.isArray(section.relatedSections) && 
                section.relatedSections.some((related: string) => 
                  related.toLowerCase().includes(term)
                ))
            )
          })
          
          // Sort results by relevance
          filteredIPC.sort((a: any, b: any) => {
            let scoreA = 0
            let scoreB = 0
            
            // Exact section match gets highest score
            if (sectionNumberMatch) {
              if (a.section && a.section.toLowerCase().includes(sectionNumberMatch.toLowerCase())) scoreA += 100
              if (b.section && b.section.toLowerCase().includes(sectionNumberMatch.toLowerCase())) scoreB += 100
            }
            
            // Title match gets high score
            const searchTerms = query.split(/\s+/).filter((term: string) => term.length > 2)
            searchTerms.forEach((term: string) => {
              if (a.title && a.title.toLowerCase().includes(term)) scoreA += 50
              if (b.title && b.title.toLowerCase().includes(term)) scoreB += 50
              
              // Keyword match gets medium score
              if (a.keywords && Array.isArray(a.keywords) && 
                  a.keywords.some((k: string) => k.toLowerCase().includes(term))) scoreA += 25
              if (b.keywords && Array.isArray(b.keywords) && 
                  b.keywords.some((k: string) => k.toLowerCase().includes(term))) scoreB += 25
              
              // Description match gets lower score
              if (a.description && a.description.toLowerCase().includes(term)) scoreA += 10
              if (b.description && b.description.toLowerCase().includes(term)) scoreB += 10
            })
            
            // Severity as tiebreaker (high severity first)
            const severityOrder: { [key: string]: number } = { 'high': 3, 'medium': 2, 'low': 1 }
            if (scoreA === scoreB) {
              const severityA = severityOrder[a.severity] || 0
              const severityB = severityOrder[b.severity] || 0
              return severityB - severityA
            }
            
            return scoreB - scoreA
          })
          
          showIPC = true
        }
      }

      // Show all IPC sections when "IPC Sections" category is selected without search
      if (selectedCategory === "IPC Sections" && !searchQuery.trim()) {
        filteredIPC = [...ipcSections].sort((a, b) => {
          // Sort by section number
          const numA = parseInt(a.section.match(/\d+/)?.[0] || '0')
          const numB = parseInt(b.section.match(/\d+/)?.[0] || '0')
          return numA - numB
        })
        showIPC = true
      }

      // Filter legal topics if not exclusively searching IPC
      if (selectedCategory !== "IPC Sections") {
        if (selectedCategory !== "All") {
          filteredLegalTopics = filteredLegalTopics.filter((topic) => topic.category === selectedCategory)
        }

        if (searchQuery.trim() && !showIPC) {
          const searchTerms = searchQuery.toLowerCase().split(/\s+/).filter(term => term.length > 2)
          filteredLegalTopics = filteredLegalTopics.filter(
            (topic) =>
              searchTerms.some(term =>
                topic.title.toLowerCase().includes(term) ||
                topic.description.toLowerCase().includes(term) ||
                topic.tags.some((tag) => tag.toLowerCase().includes(term))
              )
          )
        }
      } else {
        filteredLegalTopics = []
      }

      setFilteredTopics(filteredLegalTopics)
      setFilteredIPCSections(filteredIPC)
      setShowIPCResults(showIPC || selectedCategory === "IPC Sections")
    } catch (error) {
      console.error("Error filtering topics:", error)
      setFilteredTopics([])
      setFilteredIPCSections([])
    }
  }

  const getSeverityColor = (severity: string) => {
    switch (severity) {
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

  const getSeverityIcon = (severity: string) => {
    switch (severity) {
      case "high":
        return <AlertTriangle className="w-4 h-4" />
      case "medium":
        return <AlertTriangle className="w-4 h-4" />
      case "low":
        return <CheckCircle className="w-4 h-4" />
      default:
        return <FileText className="w-4 h-4" />
    }
  }

  const openIPCModal = (section: any) => {
    setSelectedIPCSection(section)
    setShowIPCModal(true)
  }

  const closeIPCModal = () => {
    setShowIPCModal(false)
    setSelectedIPCSection(null)
  }

  const getDifficultyColor = (difficulty: string) => {
    switch (difficulty) {
      case "Beginner":
        return "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      case "Intermediate":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
      case "Advanced":
        return "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
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
                  <BookOpen className="w-10 h-10 text-white" />
                </motion.div>
                <div className="text-left">
                  <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">
                    Explore Legal Topics
                  </h1>
                  <p className="text-xl text-gray-600 dark:text-gray-300">
                    Comprehensive guides on Indian law & searchable IPC database
                  </p>
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
                <div className="flex flex-col md:flex-row gap-4">
                  <div className="flex-1">
                    <div className="relative">
                      <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-gray-500 w-5 h-5" />
                      <Input
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        placeholder="Search IPC sections (e.g., '302', 'murder', 'fraud') or legal topics..."
                        className="pl-10 bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                        onKeyPress={(e) => e.key === "Enter" && handleSearch()}
                      />
                    </div>
                  </div>
                  <motion.div
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    transition={{ type: "spring", stiffness: 300 }}
                  >
                    <Button
                      onClick={handleSearch}
                      className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white px-8 prestigious-hover dark:glow-cyan"
                    >
                      Search
                    </Button>
                  </motion.div>
                </div>

                <div className="flex flex-wrap gap-2 mt-4">
                  {categories.map((category) => (
                    <Button
                      key={category}
                      variant={selectedCategory === category ? "default" : "outline"}
                      size="sm"
                      onClick={() => {
                        setSelectedCategory(category)
                        setTimeout(handleSearch, 0)
                      }}
                      className={
                        selectedCategory === category
                          ? "bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover"
                          : "border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                      }
                    >
                      {category}
                    </Button>
                  ))}
                </div>
              </Card>
            </motion.div>

            {/* Topics Grid */}
            {!showIPCResults && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.3 }}
                className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
              >
                {filteredTopics.map((topic, index) => (
                  <motion.div
                    key={topic.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.1 * index }}
                    whileHover={{ y: -5 }}
                    className="h-full"
                  >
                    <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF]/50 dark:hover:border-[#00FFFF]/50 transition-all duration-300 cursor-pointer h-full prestigious-hover dark:hover:glow-cyan group flex flex-col">
                      {/* Header */}
                      <div className="flex items-start gap-4 mb-4">
                        <motion.div
                          className={`p-3 bg-gradient-to-r ${topic.color} rounded-2xl shadow-lg group-hover:shadow-xl transition-all duration-300`}
                          whileHover={{ scale: 1.1, rotate: 5 }}
                          transition={{ type: "spring", stiffness: 300 }}
                        >
                          <div className="text-white">{topic.icon}</div>
                        </motion.div>
                        <div className="flex-1">
                          <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2 group-hover:text-[#007BFF] dark:group-hover:text-[#00FFFF] transition-colors duration-300">
                            {topic.title}
                          </h3>
                          <div className="flex items-center gap-2 mb-2">
                            <Badge
                              variant="outline"
                              className="border-gray-300 dark:border-[#1B263B] text-gray-600 dark:text-gray-300 text-xs"
                            >
                              {topic.category}
                            </Badge>
                            <Badge className={getDifficultyColor(topic.difficulty)}>{topic.difficulty}</Badge>
                          </div>
                        </div>
                      </div>

                      {/* Content */}
                      <div className="flex-1 flex flex-col">
                        <p className="text-gray-600 dark:text-gray-300 mb-4 leading-relaxed flex-1">
                          {topic.description}
                        </p>

                        {/* Tags */}
                        <div className="flex flex-wrap gap-1 mb-4">
                          {topic.tags.map((tag, tagIndex) => (
                            <Badge
                              key={tagIndex}
                              variant="secondary"
                              className="text-xs bg-gray-100 dark:bg-[#0D1B2A]/50 text-gray-600 dark:text-gray-300"
                            >
                              {tag}
                            </Badge>
                          ))}
                        </div>

                        {/* Stats */}
                        <div className="flex items-center justify-between text-sm text-gray-500 dark:text-gray-400 mb-4">
                          <div className="flex items-center gap-4">
                            <div className="flex items-center gap-1">
                              <BookOpen className="w-4 h-4" />
                              <span>{topic.articles} articles</span>
                            </div>
                            <div className="flex items-center gap-1">
                              <Clock className="w-4 h-4" />
                              <span>{topic.readTime}</span>
                            </div>
                          </div>
                          <div className="flex items-center gap-1">
                            <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                            <span>{topic.rating}</span>
                          </div>
                        </div>

                        {/* Action Button */}
                        <motion.div
                          whileHover={{ scale: 1.02 }}
                          whileTap={{ scale: 0.98 }}
                          transition={{ type: "spring", stiffness: 300 }}
                          className="mt-auto"
                        >
                          <Button
                            className="w-full bg-gradient-to-r from-[#007BFF] to-[#0056b3] dark:from-[#00FFFF] dark:to-[#00CCCC] hover:from-[#0056b3] hover:to-[#004085] dark:hover:from-[#00CCCC] dark:hover:to-[#00AAAA] text-white dark:text-[#0D1B2A] shadow-lg hover:shadow-xl transition-all duration-300 prestigious-hover dark:glow-cyan group/btn"
                            onClick={() => (window.location.href = `/explore/${topic.id}`)}
                          >
                            <span className="flex items-center justify-center gap-2">
                              Explore Topic
                              <ArrowRight className="w-4 h-4 group-hover/btn:translate-x-1 transition-transform duration-300" />
                            </span>
                          </Button>
                        </motion.div>
                      </div>
                    </Card>
                  </motion.div>
                ))}
              </motion.div>
            )}

            {/* IPC Sections Results */}
            {showIPCResults && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.3 }}
              >
                <div className="mb-6">
                  <h2 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">
                    IPC Sections ({filteredIPCSections.length} found)
                  </h2>
                  <p className="text-gray-600 dark:text-gray-300">
                    Click on any section to view detailed information including punishments and case studies
                  </p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {filteredIPCSections.map((section, index) => (
                    <motion.div
                      key={section.section}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.1 * index }}
                      whileHover={{ y: -3 }}
                      className="cursor-pointer"
                      onClick={() => openIPCModal(section)}
                    >
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF]/50 dark:hover:border-[#00FFFF]/50 transition-all duration-300 prestigious-hover dark:hover:glow-cyan group h-full">
                        {/* Header */}
                        <div className="flex items-start justify-between mb-4">
                          <div className="flex items-center gap-3">
                            <div className="p-2 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                              <Scale className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                            </div>
                            <div>
                              <h3 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] group-hover:text-[#007BFF] dark:group-hover:text-[#00FFFF] transition-colors">
                                {section.section}
                              </h3>
                              <p className="text-sm text-gray-500 dark:text-gray-400">{section.chapter}</p>
                            </div>
                          </div>
                          <Badge className={getSeverityColor(section.severity)}>
                            <div className="flex items-center gap-1">
                              {getSeverityIcon(section.severity)}
                              {section.severity.toUpperCase()}
                            </div>
                          </Badge>
                        </div>

                        {/* Title */}
                        <h4 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                          {section.title}
                        </h4>

                        {/* Description */}
                        <p className="text-gray-600 dark:text-gray-300 mb-4 leading-relaxed line-clamp-3">
                          {section.description}
                        </p>

                        {/* Punishment */}
                        <div className="mb-4 p-3 bg-red-50 dark:bg-red-900/20 rounded-lg border-l-4 border-red-500">
                          <p className="text-sm font-medium text-red-800 dark:text-red-200">
                            <span className="font-semibold">Punishment:</span> {section.punishment}
                          </p>
                        </div>

                        {/* Legal Status */}
                        <div className="flex gap-2 mb-4">
                          <Badge variant={section.bailable === "Bailable" ? "secondary" : "destructive"} className="text-xs">
                            {section.bailable || "Status Unknown"}
                          </Badge>
                          <Badge variant={section.cognizable === "Cognizable" ? "secondary" : "outline"} className="text-xs">
                            {section.cognizable || "Status Unknown"}
                          </Badge>
                        </div>

                        {/* Category */}
                        <div className="flex items-center justify-between">
                          <Badge variant="outline" className="text-xs">
                            {section.category}
                          </Badge>
                          <ArrowRight className="w-4 h-4 text-gray-400 group-hover:text-[#007BFF] dark:group-hover:text-[#00FFFF] group-hover:translate-x-1 transition-all duration-300" />
                        </div>
                      </Card>
                    </motion.div>
                  ))}
                </div>
              </motion.div>
            )}

            {(filteredTopics.length === 0 && filteredIPCSections.length === 0) && (
              <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="text-center py-16">
                <BookOpen className="w-16 h-16 text-gray-400 dark:text-gray-500 mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">No results found</h3>
                <p className="text-gray-600 dark:text-gray-300">
                  Try searching for IPC sections (e.g., "Section 302", "420") or legal topics
                </p>
              </motion.div>
            )}

            {/* IPC Section Detailed Modal */}
            {showIPCModal && selectedIPCSection && (
              <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                <motion.div
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.9 }}
                  className="bg-white dark:bg-[#1B263B] rounded-xl max-w-4xl max-h-[90vh] overflow-y-auto w-full"
                >
                  {/* Modal Header */}
                  <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-[#1B263B]">
                    <div className="flex items-center gap-4">
                      <div className="p-3 bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 rounded-lg">
                        <Scale className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                      </div>
                      <div>
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">
                          {selectedIPCSection.section}
                        </h2>
                        <p className="text-gray-600 dark:text-gray-300">
                          {selectedIPCSection.chapter} • {selectedIPCSection.category}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      <Badge className={getSeverityColor(selectedIPCSection.severity)}>
                        <div className="flex items-center gap-1">
                          {getSeverityIcon(selectedIPCSection.severity)}
                          {selectedIPCSection.severity.toUpperCase()}
                        </div>
                      </Badge>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={closeIPCModal}
                        className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                      >
                        ✕
                      </Button>
                    </div>
                  </div>

                  {/* Modal Content */}
                  <div className="p-6 space-y-6">
                    {/* Title and Description */}
                    <div>
                      <h3 className="text-3xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">
                        {selectedIPCSection.title}
                      </h3>
                      <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                        <h4 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">
                          Legal Definition
                        </h4>
                        <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                          {selectedIPCSection.description}
                        </p>
                      </Card>
                    </div>

                    {/* Punishment Details */}
                    <Card className="p-4 bg-red-50 dark:bg-red-900/20 border-l-4 border-red-500">
                      <h4 className="text-lg font-semibold text-red-800 dark:text-red-200 mb-2">
                        Punishment & Penalties
                      </h4>
                      <p className="text-red-700 dark:text-red-300 font-medium">
                        {selectedIPCSection.punishment}
                      </p>
                    </Card>

                    {/* Legal Status */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                        <h4 className="text-md font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">
                          Bail Status
                        </h4>
                        <Badge variant={selectedIPCSection.bailable === "Bailable" ? "secondary" : "destructive"}>
                          {selectedIPCSection.bailable || "Status Unknown"}
                        </Badge>
                        <p className="text-sm text-gray-600 dark:text-gray-300 mt-2">
                          {selectedIPCSection.bailable === "Bailable"
                            ? "Accused can be released on bail as a matter of right"
                            : selectedIPCSection.bailable === "Non-bailable"
                            ? "Bail is at the discretion of the court"
                            : "Bail status information not available"
                          }
                        </p>
                      </Card>

                      <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                        <h4 className="text-md font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">
                          Arrest Powers
                        </h4>
                        <Badge variant={selectedIPCSection.cognizable === "Cognizable" ? "secondary" : "outline"}>
                          {selectedIPCSection.cognizable || "Status Unknown"}
                        </Badge>
                        <p className="text-sm text-gray-600 dark:text-gray-300 mt-2">
                          {selectedIPCSection.cognizable === "Cognizable"
                            ? "Police can arrest without warrant"
                            : selectedIPCSection.cognizable === "Non-cognizable"
                            ? "Police cannot arrest without warrant"
                            : "Arrest powers information not available"
                          }
                        </p>
                      </Card>
                    </div>

                    {/* Related Sections */}
                    {selectedIPCSection.relatedSections && selectedIPCSection.relatedSections.length > 0 && (
                      <Card className="p-4 bg-blue-50 dark:bg-blue-900/20">
                        <h4 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                          Related IPC Sections
                        </h4>
                        <div className="flex flex-wrap gap-2">
                          {selectedIPCSection.relatedSections.map((relatedSection: string, index: number) => (
                            <Badge key={index} variant="outline" className="cursor-pointer hover:bg-blue-100 dark:hover:bg-blue-900/40">
                              {relatedSection}
                            </Badge>
                          ))}
                        </div>
                      </Card>
                    )}

                    {/* Keywords */}
                    {selectedIPCSection.keywords && selectedIPCSection.keywords.length > 0 && (
                    <Card className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50">
                      <h4 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                        Key Terms & Concepts
                      </h4>
                      <div className="flex flex-wrap gap-2">
                        {selectedIPCSection.keywords.map((keyword: string, index: number) => (
                          <Badge key={index} variant="secondary" className="text-xs">
                            {keyword}
                          </Badge>
                        ))}
                      </div>
                    </Card>
                    )}

                    {/* Case Studies */}
                    {selectedIPCSection.caseStudies && selectedIPCSection.caseStudies.length > 0 && (
                      <Card className="p-4 bg-green-50 dark:bg-green-900/20">
                        <h4 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">
                          Important Case Studies & Precedents
                        </h4>
                        <div className="space-y-2">
                          {selectedIPCSection.caseStudies.map((caseStudy: string, index: number) => (
                            <div key={index} className="flex items-center gap-3 p-2 bg-white dark:bg-[#1B263B] rounded">
                              <FileText className="w-4 h-4 text-green-600 dark:text-green-400 flex-shrink-0" />
                              <span className="text-gray-700 dark:text-gray-300">{caseStudy}</span>
                            </div>
                          ))}
                        </div>
                      </Card>
                    )}
                  </div>

                  {/* Modal Footer */}
                  <div className="flex justify-between items-center p-6 border-t border-gray-200 dark:border-[#1B263B]">
                    <Button
                      variant="outline"
                      onClick={() => window.location.href = `/analyzer?ipc=${selectedIPCSection.section}`}
                      className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50"
                    >
                      <ArrowRight className="w-4 h-4 mr-2" />
                      Analyze Case with this Section
                    </Button>
                    <Button
                      onClick={closeIPCModal}
                      className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white"
                    >
                      Close
                    </Button>
                  </div>
                </motion.div>
              </div>
            )}

            {/* Bottom CTA */}
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8, delay: 0.3 }}
              className="text-center mt-16"
            >
              <Card className="p-8 bg-gradient-to-r from-[#007BFF]/5 to-[#00FFFF]/5 dark:from-[#00FFFF]/5 dark:to-[#007BFF]/5 border-[#007BFF]/20 dark:border-[#00FFFF]/20 backdrop-blur-sm prestigious-hover">
                <h3 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">
                  Need Help with a Specific Legal Issue?
                </h3>
                <p className="text-gray-600 dark:text-gray-300 mb-6 max-w-2xl mx-auto">
                  Get personalized legal analysis and connect with expert lawyers for your specific situation.
                </p>
                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <motion.div
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    transition={{ type: "spring", stiffness: 300 }}
                  >
                    <Button
                      className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                      onClick={() => (window.location.href = "/analyzer")}
                    >
                      Analyze Your Case
                      <ArrowRight className="w-4 h-4 ml-2" />
                    </Button>
                  </motion.div>
                  <motion.div
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    transition={{ type: "spring", stiffness: 300 }}
                  >
                    <Button
                      variant="outline"
                      className="border-[#007BFF] dark:border-[#00FFFF] text-[#007BFF] dark:text-[#00FFFF] hover:bg-[#007BFF] dark:hover:bg-[#00FFFF] hover:text-white dark:hover:text-[#0D1B2A] prestigious-hover bg-transparent"
                      onClick={() => (window.location.href = "/find-lawyer")}
                    >
                      Find Expert Lawyers
                      <ArrowRight className="w-4 h-4 ml-2" />
                    </Button>
                  </motion.div>
                </div>
              </Card>
            </motion.div>
          </div>
        </main>
      </PageContainer>
    </>
  )
}

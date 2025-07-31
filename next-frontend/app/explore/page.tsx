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
import { Search, BookOpen, Scale, Users, Building, Briefcase, Shield, ArrowRight, Clock, Star } from "lucide-react"

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

const categories = ["All", "Core Law", "Commercial Law", "Property", "Personal Law", "Labor Law", "Consumer Law"]

export default function ExplorePage() {
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("All")
  const [filteredTopics, setFilteredTopics] = useState(legalTopics)

  const handleSearch = () => {
    try {
      let filtered = legalTopics

      if (selectedCategory !== "All") {
        filtered = filtered.filter((topic) => topic.category === selectedCategory)
      }

      if (searchQuery.trim()) {
        filtered = filtered.filter(
          (topic) =>
            topic.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            topic.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
            topic.tags.some((tag) => tag.toLowerCase().includes(searchQuery.toLowerCase())),
        )
      }

      setFilteredTopics(filtered)
    } catch (error) {
      console.error("Error filtering topics:", error)
      setFilteredTopics([])
    }
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
                  <p className="text-xl text-gray-600 dark:text-gray-300">Comprehensive guides on Indian law</p>
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
                        placeholder="Search legal topics, concepts, or keywords..."
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

            {filteredTopics.length === 0 && (
              <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="text-center py-16">
                <BookOpen className="w-16 h-16 text-gray-400 dark:text-gray-500 mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-2">No topics found</h3>
                <p className="text-gray-600 dark:text-gray-300">Try adjusting your search terms or category filter</p>
              </motion.div>
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

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
import { Star, MapPin, DollarSign, Award, MessageCircle } from "lucide-react"

const mockLawyers = [
  {
    id: 1,
    name: "Adv. Priya Sharma",
    specialization: "Corporate Law",
    location: "Mumbai, Maharashtra",
    rating: 4.9,
    reviews: 127,
    experience: "15+ years",
    affordability: "Premium",
    image: "/placeholder.svg?height=100&width=100",
    expertise: ["Mergers & Acquisitions", "Corporate Compliance", "Contract Law"],
    description: "Specialized in complex corporate transactions and regulatory compliance.",
  },
  {
    id: 2,
    name: "Adv. Rajesh Kumar",
    specialization: "Criminal Law",
    location: "Delhi, NCR",
    rating: 4.7,
    reviews: 89,
    experience: "12+ years",
    affordability: "Moderate",
    image: "/placeholder.svg?height=100&width=100",
    expertise: ["White Collar Crime", "Criminal Defense", "Bail Applications"],
    description: "Expert in criminal defense with a strong track record in high-profile cases.",
  },
  {
    id: 3,
    name: "Adv. Meera Patel",
    specialization: "Family Law",
    location: "Bangalore, Karnataka",
    rating: 4.8,
    reviews: 156,
    experience: "10+ years",
    affordability: "Affordable",
    image: "/placeholder.svg?height=100&width=100",
    expertise: ["Divorce Proceedings", "Child Custody", "Property Settlement"],
    description: "Compassionate approach to family law matters with focus on amicable resolutions.",
  },
]

export default function LawyersDirectory() {
  const [searchQuery, setSearchQuery] = useState("")
  const [filteredLawyers, setFilteredLawyers] = useState(mockLawyers)

  const handleSearch = () => {
    const filtered = mockLawyers.filter(
      (lawyer) =>
        lawyer.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        lawyer.specialization.toLowerCase().includes(searchQuery.toLowerCase()) ||
        lawyer.location.toLowerCase().includes(searchQuery.toLowerCase()),
    )
    setFilteredLawyers(filtered)
  }

  const getAffordabilityColor = (affordability: string) => {
    switch (affordability) {
      case "Affordable":
        return "bg-green-500/20 text-green-400 border-green-500/30"
      case "Moderate":
        return "bg-yellow-500/20 text-yellow-400 border-yellow-500/30"
      case "Premium":
        return "bg-purple-500/20 text-purple-400 border-purple-500/30"
      default:
        return "bg-gray-500/20 text-gray-400 border-gray-500/30"
    }
  }

  return (
    <div className="min-h-screen relative overflow-hidden">
      <AnimatedBackground />
      <CursorLight />
      <Navigation />

      <main className="pt-20 px-4">
        <div className="max-w-7xl mx-auto">
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8 text-center">
            <h1 className="text-4xl font-bold text-charcoal dark:text-off-white mb-4">Find Expert Legal Counsel</h1>
            <p className="text-charcoal/70 dark:text-off-white/70 text-lg">
              Connect with top-rated lawyers across India
            </p>
          </motion.div>

          {/* Search */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="mb-8"
          >
            <GlassCard className="p-6">
              <div className="flex gap-4">
                <Input
                  placeholder="Search by name, specialization, or location..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="flex-1 bg-white/10 border-white/20"
                />
                <Button
                  onClick={handleSearch}
                  className="bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90"
                >
                  Search
                </Button>
              </div>
            </GlassCard>
          </motion.div>

          {/* Lawyers Grid */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
          >
            {filteredLawyers.map((lawyer, index) => (
              <motion.div
                key={lawyer.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 * index }}
              >
                <GlassCard className="p-6 hover:bg-white/10 transition-all duration-300 h-full">
                  <div className="flex items-start gap-4 mb-4">
                    <img
                      src={lawyer.image || "/placeholder.svg"}
                      alt={lawyer.name}
                      className="w-16 h-16 rounded-full object-cover"
                    />
                    <div className="flex-1">
                      <h3 className="text-xl font-semibold text-charcoal dark:text-off-white mb-1">{lawyer.name}</h3>
                      <p className="text-prestige-blue dark:text-electric-blue font-medium">{lawyer.specialization}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 mb-3">
                    <div className="flex items-center gap-1">
                      <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                      <span className="text-charcoal dark:text-off-white font-medium">{lawyer.rating}</span>
                    </div>
                    <span className="text-charcoal/60 dark:text-off-white/60 text-sm">({lawyer.reviews} reviews)</span>
                  </div>

                  <div className="space-y-2 mb-4">
                    <div className="flex items-center gap-2 text-sm text-charcoal/70 dark:text-off-white/70">
                      <MapPin className="w-4 h-4" />
                      {lawyer.location}
                    </div>
                    <div className="flex items-center gap-2 text-sm text-charcoal/70 dark:text-off-white/70">
                      <Award className="w-4 h-4" />
                      {lawyer.experience}
                    </div>
                  </div>

                  <div className="flex items-center gap-2 mb-4">
                    <DollarSign className="w-4 h-4 text-charcoal/70 dark:text-off-white/70" />
                    <Badge className={getAffordabilityColor(lawyer.affordability)}>{lawyer.affordability}</Badge>
                  </div>

                  <p className="text-sm text-charcoal/70 dark:text-off-white/70 mb-4">{lawyer.description}</p>

                  <div className="flex flex-wrap gap-1 mb-4">
                    {lawyer.expertise.map((skill, idx) => (
                      <Badge
                        key={idx}
                        variant="outline"
                        className="text-xs border-prestige-blue/30 dark:border-electric-blue/30"
                      >
                        {skill}
                      </Badge>
                    ))}
                  </div>

                  <div className="flex gap-2">
                    <Button
                      size="sm"
                      className="flex-1 bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90"
                    >
                      View Profile
                    </Button>
                    <Button size="sm" variant="outline" className="border-white/20 hover:bg-white/10 bg-transparent">
                      <MessageCircle className="w-4 h-4" />
                    </Button>
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

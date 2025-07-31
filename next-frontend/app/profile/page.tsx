"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { AnimatedBackground } from "@/components/animated-background"
import { CursorLight } from "@/components/cursor-light"
import { Navigation } from "@/components/navigation"
import { GlassCard } from "@/components/glass-card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { User, Award, Plus, X } from "lucide-react"

export default function ProfilePage() {
  const [profile, setProfile] = useState({
    name: "Adv. Priya Sharma",
    email: "priya.sharma@example.com",
    phone: "+91 98765 43210",
    location: "Mumbai, Maharashtra",
    specialization: "Corporate Law",
    experience: "15",
    barCouncilId: "MH/12345/2009",
    description:
      "Specialized in complex corporate transactions and regulatory compliance with over 15 years of experience.",
    expertise: ["Mergers & Acquisitions", "Corporate Compliance", "Contract Law"],
    education: "LLB from Government Law College, Mumbai",
    languages: ["English", "Hindi", "Marathi"],
  })

  const [newExpertise, setNewExpertise] = useState("")
  const [isEditing, setIsEditing] = useState(false)

  const addExpertise = () => {
    if (newExpertise.trim() && !profile.expertise.includes(newExpertise.trim())) {
      setProfile((prev) => ({
        ...prev,
        expertise: [...prev.expertise, newExpertise.trim()],
      }))
      setNewExpertise("")
    }
  }

  const removeExpertise = (expertise: string) => {
    setProfile((prev) => ({
      ...prev,
      expertise: prev.expertise.filter((e) => e !== expertise),
    }))
  }

  const handleSave = () => {
    setIsEditing(false)
    // Here you would typically save to a backend
  }

  return (
    <div className="min-h-screen relative overflow-hidden">
      <AnimatedBackground />
      <CursorLight />
      <Navigation />

      <main className="pt-20 px-4">
        <div className="max-w-4xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-8 flex justify-between items-center"
          >
            <div>
              <h1 className="text-4xl font-bold text-charcoal dark:text-off-white mb-2">Professional Profile</h1>
              <p className="text-charcoal/70 dark:text-off-white/70">
                Manage your professional information and expertise
              </p>
            </div>
            <Button
              onClick={() => (isEditing ? handleSave() : setIsEditing(true))}
              className="bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90"
            >
              {isEditing ? "Save Changes" : "Edit Profile"}
            </Button>
          </motion.div>

          <div className="space-y-6">
            {/* Basic Information */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
              <GlassCard className="p-6">
                <h2 className="text-2xl font-semibold text-charcoal dark:text-off-white mb-6 flex items-center gap-2">
                  <User className="w-5 h-5" />
                  Basic Information
                </h2>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Full Name
                    </label>
                    <Input
                      value={profile.name}
                      onChange={(e) => setProfile((prev) => ({ ...prev, name: e.target.value }))}
                      disabled={!isEditing}
                      className="bg-white/10 border-white/20"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Email Address
                    </label>
                    <Input
                      type="email"
                      value={profile.email}
                      onChange={(e) => setProfile((prev) => ({ ...prev, email: e.target.value }))}
                      disabled={!isEditing}
                      className="bg-white/10 border-white/20"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Phone Number
                    </label>
                    <Input
                      value={profile.phone}
                      onChange={(e) => setProfile((prev) => ({ ...prev, phone: e.target.value }))}
                      disabled={!isEditing}
                      className="bg-white/10 border-white/20"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">Location</label>
                    <Input
                      value={profile.location}
                      onChange={(e) => setProfile((prev) => ({ ...prev, location: e.target.value }))}
                      disabled={!isEditing}
                      className="bg-white/10 border-white/20"
                    />
                  </div>
                </div>
              </GlassCard>
            </motion.div>

            {/* Professional Details */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
              <GlassCard className="p-6">
                <h2 className="text-2xl font-semibold text-charcoal dark:text-off-white mb-6 flex items-center gap-2">
                  <Award className="w-5 h-5" />
                  Professional Details
                </h2>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Primary Specialization
                    </label>
                    <Input
                      value={profile.specialization}
                      onChange={(e) => setProfile((prev) => ({ ...prev, specialization: e.target.value }))}
                      disabled={!isEditing}
                      className="bg-white/10 border-white/20"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Years of Experience
                    </label>
                    <Input
                      value={profile.experience}
                      onChange={(e) => setProfile((prev) => ({ ...prev, experience: e.target.value }))}
                      disabled={!isEditing}
                      className="bg-white/10 border-white/20"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Bar Council ID
                    </label>
                    <Input
                      value={profile.barCouncilId}
                      onChange={(e) => setProfile((prev) => ({ ...prev, barCouncilId: e.target.value }))}
                      disabled={!isEditing}
                      className="bg-white/10 border-white/20"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                      Education
                    </label>
                    <Input
                      value={profile.education}
                      onChange={(e) => setProfile((prev) => ({ ...prev, education: e.target.value }))}
                      disabled={!isEditing}
                      className="bg-white/10 border-white/20"
                    />
                  </div>
                </div>

                <div className="mb-6">
                  <label className="block text-sm font-medium text-charcoal dark:text-off-white mb-2">
                    Professional Description
                  </label>
                  <Textarea
                    value={profile.description}
                    onChange={(e) => setProfile((prev) => ({ ...prev, description: e.target.value }))}
                    disabled={!isEditing}
                    className="bg-white/10 border-white/20 min-h-[100px]"
                  />
                </div>
              </GlassCard>
            </motion.div>

            {/* Expertise */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
              <GlassCard className="p-6">
                <h2 className="text-2xl font-semibold text-charcoal dark:text-off-white mb-6">Areas of Expertise</h2>

                <div className="flex flex-wrap gap-2 mb-4">
                  {profile.expertise.map((skill, index) => (
                    <Badge
                      key={index}
                      className="bg-prestige-blue/20 dark:bg-electric-blue/20 text-prestige-blue dark:text-electric-blue border-prestige-blue/30 dark:border-electric-blue/30 flex items-center gap-1"
                    >
                      {skill}
                      {isEditing && (
                        <button
                          onClick={() => removeExpertise(skill)}
                          className="ml-1 hover:bg-red-500/20 rounded-full p-0.5"
                        >
                          <X className="w-3 h-3" />
                        </button>
                      )}
                    </Badge>
                  ))}
                </div>

                {isEditing && (
                  <div className="flex gap-2">
                    <Input
                      placeholder="Add new expertise area..."
                      value={newExpertise}
                      onChange={(e) => setNewExpertise(e.target.value)}
                      onKeyPress={(e) => e.key === "Enter" && addExpertise()}
                      className="bg-white/10 border-white/20"
                    />
                    <Button
                      onClick={addExpertise}
                      size="sm"
                      className="bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90"
                    >
                      <Plus className="w-4 h-4" />
                    </Button>
                  </div>
                )}
              </GlassCard>
            </motion.div>
          </div>
        </div>
      </main>
    </div>
  )
}

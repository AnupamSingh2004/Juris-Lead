"use client"

import type React from "react"

import { useState } from "react"
import { motion } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { ProNavigation } from "@/components/pro-navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Switch } from "@/components/ui/switch"
import { withLawyerAuth } from "@/lib/lawyer-auth"
import { Award, Plus, X, Camera } from "lucide-react"

const specializations = [
  "Criminal Law",
  "Corporate Law",
  "Family Law",
  "Property Law",
  "Employment Law",
  "Intellectual Property",
  "Tax Law",
  "Constitutional Law",
  "Environmental Law",
  "Immigration Law",
]

function ProfilePage() {
  const [profile, setProfile] = useState({
    name: "Adv. Priya Sharma",
    email: "priya.sharma@example.com",
    phone: "+91 98765 43210",
    location: "Mumbai, Maharashtra",
    barCouncilId: "MH/12345/2009",
    lawFirm: "Sharma & Associates",
    yearsOfPractice: "15",
    bio: "Specialized in complex corporate transactions and regulatory compliance with over 15 years of experience in handling high-profile cases.",
    expertise: ["Corporate Law", "Mergers & Acquisitions", "Contract Law"],
    languages: ["English", "Hindi", "Marathi"],
    isAvailable: true,
    profileImage: "/placeholder.svg?height=150&width=150",
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

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        setProfile((prev) => ({
          ...prev,
          profileImage: e.target?.result as string,
        }))
      }
      reader.readAsDataURL(file)
    }
  }

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <ProNavigation />

        <main className="pt-24 pb-16">
          <div className="px-6 max-w-4xl mx-auto">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="mb-8 flex justify-between items-center"
            >
              <div>
                <h1 className="text-4xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">Professional Profile</h1>
                <p className="text-xl text-gray-600 dark:text-gray-300">
                  Manage your professional information and expertise
                </p>
              </div>
              <Button
                onClick={() => (isEditing ? handleSave() : setIsEditing(true))}
                className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
              >
                {isEditing ? "Save Changes" : "Edit Profile"}
              </Button>
            </motion.div>

            <div className="space-y-8">
              {/* Profile Photo & Basic Info */}
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
                <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover dark:hover:glow-cyan">
                  <div className="flex flex-col md:flex-row gap-8 items-start">
                    {/* Profile Photo */}
                    <div className="flex flex-col items-center">
                      <div className="relative">
                        <img
                          src={profile.profileImage || "/placeholder.svg"}
                          alt="Profile"
                          className="w-32 h-32 rounded-full object-cover border-4 border-[#007BFF] dark:border-[#00FFFF] shadow-lg"
                        />
                        {isEditing && (
                          <label className="absolute bottom-0 right-0 p-2 bg-[#007BFF] dark:bg-[#00FFFF] text-white dark:text-[#0D1B2A] rounded-full cursor-pointer hover:scale-110 transition-transform shadow-lg">
                            <Camera className="w-4 h-4" />
                            <input type="file" accept="image/*" onChange={handleImageUpload} className="hidden" />
                          </label>
                        )}
                      </div>
                      <div className="mt-4 text-center">
                        <h2 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">{profile.name}</h2>
                        <p className="text-gray-600 dark:text-gray-300">{profile.lawFirm}</p>
                        <div className="flex items-center justify-center gap-2 mt-2">
                          <Switch
                            checked={profile.isAvailable}
                            onCheckedChange={(checked) => setProfile((prev) => ({ ...prev, isAvailable: checked }))}
                            disabled={!isEditing}
                          />
                          <span className="text-sm text-gray-600 dark:text-gray-300">
                            {profile.isAvailable ? "Available for new cases" : "Not accepting new cases"}
                          </span>
                        </div>
                      </div>
                    </div>

                    {/* Basic Information */}
                    <div className="flex-1 space-y-6">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                          <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                            Full Name
                          </label>
                          <Input
                            value={profile.name}
                            onChange={(e) => setProfile((prev) => ({ ...prev, name: e.target.value }))}
                            disabled={!isEditing}
                            className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                            Email Address
                          </label>
                          <Input
                            type="email"
                            value={profile.email}
                            onChange={(e) => setProfile((prev) => ({ ...prev, email: e.target.value }))}
                            disabled={!isEditing}
                            className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                            Phone Number
                          </label>
                          <Input
                            value={profile.phone}
                            onChange={(e) => setProfile((prev) => ({ ...prev, phone: e.target.value }))}
                            disabled={!isEditing}
                            className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                            Location
                          </label>
                          <Input
                            value={profile.location}
                            onChange={(e) => setProfile((prev) => ({ ...prev, location: e.target.value }))}
                            disabled={!isEditing}
                            className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                </Card>
              </motion.div>

              {/* Professional Details */}
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
                <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover dark:hover:glow-cyan">
                  <h2 className="text-2xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6 flex items-center gap-2">
                    <Award className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
                    Professional Details
                  </h2>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                        Bar Council ID
                      </label>
                      <Input
                        value={profile.barCouncilId}
                        onChange={(e) => setProfile((prev) => ({ ...prev, barCouncilId: e.target.value }))}
                        disabled={!isEditing}
                        className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                        Law Firm
                      </label>
                      <Input
                        value={profile.lawFirm}
                        onChange={(e) => setProfile((prev) => ({ ...prev, lawFirm: e.target.value }))}
                        disabled={!isEditing}
                        className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                        Years of Practice
                      </label>
                      <Input
                        value={profile.yearsOfPractice}
                        onChange={(e) => setProfile((prev) => ({ ...prev, yearsOfPractice: e.target.value }))}
                        disabled={!isEditing}
                        className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                      />
                    </div>
                  </div>

                  <div className="mb-6">
                    <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                      Professional Bio
                    </label>
                    <Textarea
                      value={profile.bio}
                      onChange={(e) => setProfile((prev) => ({ ...prev, bio: e.target.value }))}
                      disabled={!isEditing}
                      className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan min-h-[120px] transition-all duration-300"
                      placeholder="Describe your professional background, experience, and specializations..."
                    />
                  </div>
                </Card>
              </motion.div>

              {/* Areas of Expertise */}
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
                <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover dark:hover:glow-cyan">
                  <h2 className="text-2xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6">Areas of Expertise</h2>

                  <div className="flex flex-wrap gap-3 mb-6">
                    {profile.expertise.map((skill, index) => (
                      <Badge
                        key={index}
                        className="bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 text-[#007BFF] dark:text-[#00FFFF] border-[#007BFF]/30 dark:border-[#00FFFF]/30 flex items-center gap-2 px-3 py-1 text-sm hover:bg-[#007BFF]/20 dark:hover:bg-[#00FFFF]/20 transition-colors"
                      >
                        {skill}
                        {isEditing && (
                          <button
                            onClick={() => removeExpertise(skill)}
                            className="ml-1 hover:bg-red-500/20 rounded-full p-0.5 transition-colors"
                          >
                            <X className="w-3 h-3" />
                          </button>
                        )}
                      </Badge>
                    ))}
                  </div>

                  {isEditing && (
                    <div className="space-y-4">
                      <div className="flex gap-2">
                        <select
                          value={newExpertise}
                          onChange={(e) => setNewExpertise(e.target.value)}
                          className="flex-1 px-3 py-2 bg-white dark:bg-[#0D1B2A]/50 border border-gray-300 dark:border-[#1B263B] rounded-lg text-gray-900 dark:text-[#E0E6F1] focus:border-[#007BFF] dark:focus:border-[#00FFFF] focus:outline-none transition-all duration-300"
                        >
                          <option value="">Select specialization...</option>
                          {specializations
                            .filter((spec) => !profile.expertise.includes(spec))
                            .map((spec) => (
                              <option key={spec} value={spec}>
                                {spec}
                              </option>
                            ))}
                        </select>
                        <Button
                          onClick={addExpertise}
                          disabled={!newExpertise}
                          className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                        >
                          <Plus className="w-4 h-4" />
                        </Button>
                      </div>
                      <p className="text-sm text-gray-600 dark:text-gray-300">
                        Select from common specializations or add custom expertise areas
                      </p>
                    </div>
                  )}
                </Card>
              </motion.div>
            </div>
          </div>
        </main>
      </PageContainer>
    </>
  )
}

export default withLawyerAuth(ProfilePage)

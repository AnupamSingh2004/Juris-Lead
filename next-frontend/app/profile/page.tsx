"use client"

import { useState, useEffect } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { Navigation } from "@/components/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Card } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { 
  User, Award, Plus, X, Edit3, Save, Camera, MapPin, Mail, Phone, 
  Calendar, GraduationCap, Scale, Briefcase, Star, Clock, BookOpen,
  Building, Shield, Users, FileText, History, Settings, Trophy,
  Target, TrendingUp, Heart, Gavel, ChevronRight, CheckCircle,
  AlertCircle, Info
} from "lucide-react"
import { useAuth } from "@/lib/auth-context"

export default function ProfilePage() {
  const { user, isAuthenticated, isLawyer, isClient } = useAuth()
  const [isEditing, setIsEditing] = useState(false)
  const [activeTab, setActiveTab] = useState("overview")
  const [mounted, setMounted] = useState(false)

  // Lawyer Profile State
  const [lawyerProfile, setLawyerProfile] = useState({
    name: (user?.first_name && user?.last_name) ? user.first_name + " " + user.last_name : "",
    email: user?.email || "",
    phone: "",
    location: "",
    specialization: "",
    experience: "",
    barCouncilId: "",
    description: "",
    expertise: [] as string[],
    education: "",
    languages: [] as string[],
    achievements: [] as string[],
    practiceAreas: [] as string[],
    courtAdmissions: [] as string[],
    successRate: 0,
    totalCases: 0,
    activeCases: 0,
    rating: 0,
    reviews: 0
  })

  // Client Profile State
  const [clientProfile, setClientProfile] = useState({
    name: (user?.first_name && user?.last_name) ? user.first_name + " " + user.last_name : "",
    email: user?.email || "",
    phone: "",
    location: "",
    occupation: "",
    company: "",
    description: "",
    interests: [] as string[],
    totalCases: 0,
    activeCases: 0,
    preferredLanguages: [] as string[],
    caseHistory: [] as Array<{type: string, status: string, date: string, id?: string}>
  })

  const [newExpertise, setNewExpertise] = useState("")
  const [newInterest, setNewInterest] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [saveMessage, setSaveMessage] = useState("")
  const [caseHistory, setCaseHistory] = useState<Array<{type: string, status: string, date: string, id?: string}>>([])
  const [isLoadingHistory, setIsLoadingHistory] = useState(false)

  useEffect(() => {
    setMounted(true)
    if (user && isAuthenticated) {
      loadUserProfile()
      loadCaseHistory()
    }
  }, [user, isAuthenticated])

  // Load user profile data from backend
  const loadUserProfile = async () => {
    if (!user || !isAuthenticated) return

    try {
      const token = localStorage.getItem('access_token')
      const response = await fetch(`http://localhost:8001/api/profile/`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      })

      if (response.ok) {
        const profileData = await response.json()
        
        if (isLawyer) {
          setLawyerProfile(prev => ({
            ...prev,
            ...profileData,
            name: profileData.name || (user.first_name + " " + user.last_name),
            email: profileData.email || user.email,
            expertise: Array.isArray(profileData.expertise) ? profileData.expertise : 
                      profileData.expertise ? JSON.parse(profileData.expertise || '[]') : prev.expertise,
            achievements: Array.isArray(profileData.achievements) ? profileData.achievements : 
                         profileData.achievements ? JSON.parse(profileData.achievements || '[]') : prev.achievements,
            practiceAreas: Array.isArray(profileData.practice_areas) ? profileData.practice_areas : 
                          profileData.practice_areas ? JSON.parse(profileData.practice_areas || '[]') : prev.practiceAreas,
            courtAdmissions: Array.isArray(profileData.court_admissions) ? profileData.court_admissions : 
                           profileData.court_admissions ? JSON.parse(profileData.court_admissions || '[]') : prev.courtAdmissions,
            languages: Array.isArray(profileData.languages) ? profileData.languages : 
                      profileData.languages ? JSON.parse(profileData.languages || '[]') : prev.languages,
          }))
        } else {
          setClientProfile(prev => ({
            ...prev,
            ...profileData,
            name: profileData.name || (user.first_name + " " + user.last_name),
            email: profileData.email || user.email,
            interests: Array.isArray(profileData.interests) ? profileData.interests : 
                      profileData.interests ? JSON.parse(profileData.interests || '[]') : prev.interests,
            preferredLanguages: Array.isArray(profileData.preferred_languages) ? profileData.preferred_languages : 
                               profileData.preferred_languages ? JSON.parse(profileData.preferred_languages || '[]') : prev.preferredLanguages,
          }))
        }
      }
    } catch (error) {
      console.error('Error loading profile:', error)
    }
  }

  // Load case history from backend
  const loadCaseHistory = async () => {
    if (!user || !isAuthenticated) return

    setIsLoadingHistory(true)
    try {
      const token = localStorage.getItem('access_token')
      
      // Try to fetch from different endpoints based on user role
      let historyEndpoint = ''
      if (isLawyer) {
        historyEndpoint = 'http://localhost:8001/api/v1/legal/cases/' // Lawyer cases
      } else {
        historyEndpoint = 'http://localhost:8001/api/v1/legal/history/' // Client history
      }

      const response = await fetch(historyEndpoint, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      })

      if (response.ok) {
        const historyData = await response.json()
        
        // Transform the data to match our case history format
        const formattedHistory = historyData.map((item: any) => ({
          type: item.case_type || item.query_type || item.title || 'Legal Query',
          status: item.status || 'Completed',
          date: item.created_at ? new Date(item.created_at).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
          id: item.id
        }))

        setCaseHistory(formattedHistory)
        
        // Update profile with case statistics
        if (isClient) {
          setClientProfile(prev => ({
            ...prev,
            totalCases: historyData.length,
            activeCases: historyData.filter((item: any) => item.status === 'In Progress' || item.status === 'Active').length,
            caseHistory: formattedHistory
          }))
        } else if (isLawyer) {
          setLawyerProfile(prev => ({
            ...prev,
            totalCases: historyData.length,
            activeCases: historyData.filter((item: any) => item.status === 'In Progress' || item.status === 'Active').length,
          }))
        }
      }
    } catch (error) {
      console.error('Error loading case history:', error)
      // Set some default data if API fails
      setCaseHistory([])
    } finally {
      setIsLoadingHistory(false)
    }
  }

  // Save profile data to backend
  const saveProfile = async () => {
    if (!user || !isAuthenticated) return

    setIsLoading(true)
    try {
      const token = localStorage.getItem('access_token')
      const profileData = isLawyer ? lawyerProfile : clientProfile
      
      const response = await fetch(`http://localhost:8001/api/profile/`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...profileData,
          user_type: isLawyer ? 'lawyer' : 'client',
          // Convert arrays to JSON strings for backend
          expertise: JSON.stringify(lawyerProfile.expertise),
          achievements: JSON.stringify(lawyerProfile.achievements),
          practice_areas: JSON.stringify(lawyerProfile.practiceAreas),
          court_admissions: JSON.stringify(lawyerProfile.courtAdmissions),
          interests: JSON.stringify(clientProfile.interests),
          preferred_languages: JSON.stringify(clientProfile.preferredLanguages),
        }),
      })

      if (response.ok) {
        setSaveMessage("Profile saved successfully!")
        setTimeout(() => setSaveMessage(""), 3000)
      } else {
        throw new Error('Failed to save profile')
      }
    } catch (error) {
      console.error('Error saving profile:', error)
      setSaveMessage("Error saving profile. Please try again.")
      setTimeout(() => setSaveMessage(""), 3000)
    } finally {
      setIsLoading(false)
    }
  }

  if (!mounted) return null

  if (!isAuthenticated) {
    return (
      <>
        <LivingBackground />
        <PageContainer>
          <Navigation />
          <main className="pt-24 pb-16">
            <div className="px-6 max-w-6xl mx-auto text-center">
              <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm">
                <h1 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">
                  Please Login to View Profile
                </h1>
                <p className="text-gray-600 dark:text-gray-300">
                  You need to be authenticated to access your profile.
                </p>
              </Card>
            </div>
          </main>
        </PageContainer>
      </>
    )
  }

  const addExpertise = () => {
    if (newExpertise.trim() && !lawyerProfile.expertise.includes(newExpertise.trim())) {
      setLawyerProfile((prev) => ({
        ...prev,
        expertise: [...prev.expertise, newExpertise.trim()],
      }))
      setNewExpertise("")
    }
  }

  const removeExpertise = (expertise: string) => {
    setLawyerProfile((prev) => ({
      ...prev,
      expertise: prev.expertise.filter((e) => e !== expertise),
    }))
  }

  const addInterest = () => {
    if (newInterest.trim() && !clientProfile.interests.includes(newInterest.trim())) {
      setClientProfile((prev) => ({
        ...prev,
        interests: [...prev.interests, newInterest.trim()],
      }))
      setNewInterest("")
    }
  }

  const removeInterest = (interest: string) => {
    setClientProfile((prev) => ({
      ...prev,
      interests: prev.interests.filter((i) => i !== interest),
    }))
  }

  const handleSave = async () => {
    await saveProfile()
    setIsEditing(false)
    // Refresh data after saving
    await loadUserProfile()
    await loadCaseHistory()
  }

  const profile = isLawyer ? lawyerProfile : clientProfile
  const setProfile = isLawyer ? setLawyerProfile : setClientProfile

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <Navigation />

        <main className="pt-24 pb-16">
          <div className="px-6 max-w-6xl mx-auto">
            {/* Profile Header */}
            <motion.div 
              initial={{ opacity: 0, y: 20 }} 
              animate={{ opacity: 1, y: 0 }}
              className="mb-8"
            >
              <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                <div className="flex flex-col lg:flex-row items-start lg:items-center gap-6">
                  {/* Profile Picture */}
                  <div className="relative">
                    <div className="w-32 h-32 rounded-full bg-gradient-to-r from-[#007BFF] to-[#00FFFF] dark:from-[#00FFFF] dark:to-[#007BFF] flex items-center justify-center shadow-2xl">
                      <User className="w-16 h-16 text-white dark:text-[#0D1B2A]" />
                    </div>
                    {isEditing && (
                      <Button
                        size="sm"
                        className="absolute -bottom-2 -right-2 w-10 h-10 rounded-full bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] shadow-lg"
                      >
                        <Camera className="w-4 h-4" />
                      </Button>
                    )}
                  </div>

                  {/* Profile Info */}
                  <div className="flex-1">
                    <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4 mb-4">
                      <div>
                        <h1 className="text-4xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">
                          {profile.name || user?.full_name || 'User Profile'}
                        </h1>
                        <div className="flex flex-wrap items-center gap-4 text-gray-600 dark:text-gray-300">
                          <div className="flex items-center gap-2">
                            <Mail className="w-4 h-4" />
                            <span>{profile.email || user?.email || 'No email'}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <MapPin className="w-4 h-4" />
                            <span>{profile.location}</span>
                          </div>
                          {isLawyer && (
                            <Badge className="bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300">
                              <Shield className="w-3 h-3 mr-1" />
                              Lawyer
                            </Badge>
                          )}
                          {isClient && (
                            <Badge className="bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300">
                              <Users className="w-3 h-3 mr-1" />
                              Client
                            </Badge>
                          )}
                        </div>
                      </div>
                      
                      <Button
                        onClick={() => isEditing ? handleSave() : setIsEditing(true)}
                        disabled={isLoading}
                        className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                      >
                        {isLoading ? (
                          <>
                            <div className="w-4 h-4 mr-2 border-2 border-white border-t-transparent rounded-full animate-spin" />
                            Saving...
                          </>
                        ) : isEditing ? (
                          <>
                            <Save className="w-4 h-4 mr-2" />
                            Save Changes
                          </>
                        ) : (
                          <>
                            <Edit3 className="w-4 h-4 mr-2" />
                            Edit Profile
                          </>
                        )}
                      </Button>
                    </div>

                    {saveMessage && (
                      <div className={`mt-2 p-2 rounded text-sm ${
                        saveMessage.includes('Error') 
                          ? 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300' 
                          : 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300'
                      }`}>
                        {saveMessage}
                      </div>
                    )}

                    <p className="text-gray-600 dark:text-gray-300 text-lg leading-relaxed mb-4">
                      {profile.description || (isLawyer ? "Add a professional bio to showcase your expertise and experience." : "Add a brief description about yourself and your legal needs.")}
                    </p>

                    {/* Stats Row */}
                    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                      {isLawyer ? (
                        <>
                          <div className="text-center p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                            <div className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">{lawyerProfile.totalCases}</div>
                            <div className="text-sm text-gray-600 dark:text-gray-300">Total Cases</div>
                          </div>
                          <div className="text-center p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                            <div className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">{lawyerProfile.successRate}%</div>
                            <div className="text-sm text-gray-600 dark:text-gray-300">Success Rate</div>
                          </div>
                          <div className="text-center p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                            <div className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">
                              {lawyerProfile.experience || "0"}
                            </div>
                            <div className="text-sm text-gray-600 dark:text-gray-300">Years Experience</div>
                          </div>
                          <div className="text-center p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                            <div className="flex items-center justify-center gap-1">
                              <span className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">{lawyerProfile.rating}</span>
                              <Star className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                            </div>
                            <div className="text-sm text-gray-600 dark:text-gray-300">{lawyerProfile.reviews} Reviews</div>
                          </div>
                        </>
                      ) : (
                        <>
                          <div className="text-center p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                            <div className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">{clientProfile.totalCases}</div>
                            <div className="text-sm text-gray-600 dark:text-gray-300">Total Cases</div>
                          </div>
                          <div className="text-center p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                            <div className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">{clientProfile.activeCases}</div>
                            <div className="text-sm text-gray-600 dark:text-gray-300">Active Cases</div>
                          </div>
                          <div className="text-center p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                            <div className="text-lg font-bold text-[#007BFF] dark:text-[#00FFFF]">
                              {clientProfile.company || "Not specified"}
                            </div>
                            <div className="text-sm text-gray-600 dark:text-gray-300">Company</div>
                          </div>
                          <div className="text-center p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                            <div className="text-lg font-bold text-[#007BFF] dark:text-[#00FFFF]">
                              {clientProfile.occupation || "Not specified"}
                            </div>
                            <div className="text-sm text-gray-600 dark:text-gray-300">Occupation</div>
                          </div>
                        </>
                      )}
                    </div>
                  </div>
                </div>
              </Card>
            </motion.div>

            {/* Profile Tabs */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
            >
              <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
                <TabsList className="grid w-full grid-cols-2 lg:grid-cols-4 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm">
                  <TabsTrigger value="overview" className="data-[state=active]:bg-[#007BFF] data-[state=active]:text-white dark:data-[state=active]:bg-[#00FFFF] dark:data-[state=active]:text-[#0D1B2A]">
                    Overview
                  </TabsTrigger>
                  <TabsTrigger value="details" className="data-[state=active]:bg-[#007BFF] data-[state=active]:text-white dark:data-[state=active]:bg-[#00FFFF] dark:data-[state=active]:text-[#0D1B2A]">
                    {isLawyer ? "Professional" : "Personal"}
                  </TabsTrigger>
                  <TabsTrigger value="expertise" className="data-[state=active]:bg-[#007BFF] data-[state=active]:text-white dark:data-[state=active]:bg-[#00FFFF] dark:data-[state=active]:text-[#0D1B2A]">
                    {isLawyer ? "Expertise" : "Interests"}
                  </TabsTrigger>
                  <TabsTrigger value="activity" className="data-[state=active]:bg-[#007BFF] data-[state=active]:text-white dark:data-[state=active]:bg-[#00FFFF] dark:data-[state=active]:text-[#0D1B2A]">
                    Activity
                  </TabsTrigger>
                </TabsList>

                {/* Overview Tab */}
                <TabsContent value="overview" className="space-y-6">
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Quick Info */}
                    <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                      <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4 flex items-center gap-2">
                        <Info className="w-5 h-5" />
                        Quick Info
                      </h3>
                      <div className="space-y-3">
                        <div className="flex items-center gap-3">
                          <Phone className="w-4 h-4 text-gray-500" />
                          <span className="text-gray-700 dark:text-gray-300">
                            {profile.phone || "No phone number added"}
                          </span>
                        </div>
                        <div className="flex items-center gap-3">
                          <MapPin className="w-4 h-4 text-gray-500" />
                          <span className="text-gray-700 dark:text-gray-300">
                            {profile.location || "Location not specified"}
                          </span>
                        </div>
                        {isLawyer && (
                          <>
                            <div className="flex items-center gap-3">
                              <Scale className="w-4 h-4 text-gray-500" />
                              <span className="text-gray-700 dark:text-gray-300">
                                {lawyerProfile.specialization || "Specialization not added"}
                              </span>
                            </div>
                            <div className="flex items-center gap-3">
                              <Award className="w-4 h-4 text-gray-500" />
                              <span className="text-gray-700 dark:text-gray-300">
                                Bar ID: {lawyerProfile.barCouncilId || "Not provided"}
                              </span>
                            </div>
                          </>
                        )}
                        {isClient && (
                          <>
                            <div className="flex items-center gap-3">
                              <Briefcase className="w-4 h-4 text-gray-500" />
                              <span className="text-gray-700 dark:text-gray-300">
                                {clientProfile.occupation || "Occupation not specified"}
                              </span>
                            </div>
                            <div className="flex items-center gap-3">
                              <Building className="w-4 h-4 text-gray-500" />
                              <span className="text-gray-700 dark:text-gray-300">
                                {clientProfile.company || "Company not specified"}
                              </span>
                            </div>
                          </>
                        )}
                      </div>
                    </Card>

                    {/* Recent Activity */}
                    <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                      <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4 flex items-center gap-2">
                        <Clock className="w-5 h-5" />
                        Recent Activity
                      </h3>
                      {isLoadingHistory ? (
                        <div className="flex items-center justify-center py-4">
                          <div className="w-6 h-6 border-2 border-[#007BFF] border-t-transparent rounded-full animate-spin"></div>
                        </div>
                      ) : (
                        <div className="space-y-3">
                          {caseHistory.length === 0 ? (
                            <div className="text-center py-4 text-gray-500 dark:text-gray-400">
                              <FileText className="w-8 h-8 mx-auto mb-2 opacity-50" />
                              <p className="text-sm font-medium">No recent activity found</p>
                              <p className="text-xs mt-1">
                                {isLawyer ? "Start taking on cases to see your activity here" : "Submit a case analysis to see your history here"}
                              </p>
                            </div>
                          ) : (
                            caseHistory.slice(0, 3).map((case_item, index) => (
                              <div key={case_item.id || index} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                                <div>
                                  <p className="font-medium text-gray-900 dark:text-[#E0E6F1]">{case_item.type}</p>
                                  <p className="text-sm text-gray-600 dark:text-gray-300">{case_item.date}</p>
                                </div>
                                <Badge variant={case_item.status === 'Completed' ? 'default' : case_item.status === 'Resolved' ? 'secondary' : 'outline'}>
                                  {case_item.status}
                                </Badge>
                              </div>
                            ))
                          )}
                        </div>
                      )}
                    </Card>
                  </div>
                </TabsContent>

                {/* Details Tab */}
                <TabsContent value="details" className="space-y-6">
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6 flex items-center gap-2">
                      <User className="w-5 h-5" />
                      {isLawyer ? "Professional Information" : "Personal Information"}
                    </h3>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                          Full Name
                        </label>
                        <Input
                          value={profile.name}
                          onChange={(e) => setProfile((prev: any) => ({ ...prev, name: e.target.value }))}
                          disabled={!isEditing}
                          placeholder="Enter your full name"
                          className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                        />
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                          Email Address
                        </label>
                        <Input
                          type="email"
                          value={profile.email}
                          onChange={(e) => setProfile((prev: any) => ({ ...prev, email: e.target.value }))}
                          disabled={!isEditing}
                          placeholder="Enter your email address"
                          className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                        />
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                          Phone Number
                        </label>
                        <Input
                          value={profile.phone}
                          onChange={(e) => setProfile((prev: any) => ({ ...prev, phone: e.target.value }))}
                          disabled={!isEditing}
                          placeholder="Enter your phone number"
                          className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                        />
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                          Location
                        </label>
                        <Input
                          value={profile.location}
                          onChange={(e) => setProfile((prev: any) => ({ ...prev, location: e.target.value }))}
                          disabled={!isEditing}
                          placeholder="Enter your city, state"
                          className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                        />
                      </div>

                      {isLawyer && (
                        <>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                              Primary Specialization
                            </label>
                            <Input
                              value={lawyerProfile.specialization}
                              onChange={(e) => setLawyerProfile((prev) => ({ ...prev, specialization: e.target.value }))}
                              disabled={!isEditing}
                              placeholder="e.g., Criminal Law, Corporate Law"
                              className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                              Years of Experience
                            </label>
                            <Input
                              value={lawyerProfile.experience}
                              onChange={(e) => setLawyerProfile((prev) => ({ ...prev, experience: e.target.value }))}
                              disabled={!isEditing}
                              placeholder="e.g., 5 years"
                              className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                              Bar Council ID
                            </label>
                            <Input
                              value={lawyerProfile.barCouncilId}
                              onChange={(e) => setLawyerProfile((prev) => ({ ...prev, barCouncilId: e.target.value }))}
                              disabled={!isEditing}
                              placeholder="Enter your Bar Council ID"
                              className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                              Education
                            </label>
                            <Input
                              value={lawyerProfile.education}
                              onChange={(e) => setLawyerProfile((prev) => ({ ...prev, education: e.target.value }))}
                              disabled={!isEditing}
                              placeholder="e.g., LLB from Delhi University"
                              className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                            />
                          </div>
                        </>
                      )}

                      {isClient && (
                        <>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                              Occupation
                            </label>
                            <Input
                              value={clientProfile.occupation}
                              onChange={(e) => setClientProfile((prev) => ({ ...prev, occupation: e.target.value }))}
                              disabled={!isEditing}
                              placeholder="e.g., Software Engineer, Business Owner"
                              className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                              Company
                            </label>
                            <Input
                              value={clientProfile.company}
                              onChange={(e) => setClientProfile((prev) => ({ ...prev, company: e.target.value }))}
                              disabled={!isEditing}
                              placeholder="e.g., Microsoft, Self-employed"
                              className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                            />
                          </div>
                        </>
                      )}
                    </div>

                    <div className="mt-6">
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                        {isLawyer ? "Professional Description" : "About You"}
                      </label>
                      <Textarea
                        value={profile.description}
                        onChange={(e) => setProfile((prev: any) => ({ ...prev, description: e.target.value }))}
                        disabled={!isEditing}
                        placeholder={isLawyer ? 
                          "Describe your professional background, expertise, and what makes you unique as a legal professional..." : 
                          "Tell us about yourself, your background, and what kind of legal assistance you're looking for..."}
                        className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] min-h-[120px]"
                      />
                    </div>
                  </Card>

                  {isLawyer && (
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                      {/* Practice Areas */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h4 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">Practice Areas</h4>
                        <div className="space-y-2">
                          {lawyerProfile.practiceAreas.map((area, index) => (
                            <div key={index} className="flex items-center gap-2 p-2 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded">
                              <Scale className="w-4 h-4 text-[#007BFF] dark:text-[#00FFFF]" />
                              <span className="text-gray-700 dark:text-gray-300">{area}</span>
                            </div>
                          ))}
                        </div>
                      </Card>

                      {/* Court Admissions */}
                      <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                        <h4 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">Court Admissions</h4>
                        <div className="space-y-2">
                          {lawyerProfile.courtAdmissions.map((court, index) => (
                            <div key={index} className="flex items-center gap-2 p-2 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded">
                              <Gavel className="w-4 h-4 text-[#007BFF] dark:text-[#00FFFF]" />
                              <span className="text-gray-700 dark:text-gray-300">{court}</span>
                            </div>
                          ))}
                        </div>
                      </Card>
                    </div>
                  )}
                </TabsContent>

                {/* Expertise/Interests Tab */}
                <TabsContent value="expertise" className="space-y-6">
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6 flex items-center gap-2">
                      {isLawyer ? <Award className="w-5 h-5" /> : <Heart className="w-5 h-5" />}
                      {isLawyer ? "Areas of Expertise" : "Legal Interests"}
                    </h3>

                    <div className="flex flex-wrap gap-2 mb-6">
                      {(isLawyer ? lawyerProfile.expertise : clientProfile.interests).length === 0 ? (
                        <div className="text-center py-8 text-gray-500 dark:text-gray-400 w-full">
                          <Award className="w-12 h-12 mx-auto mb-3 opacity-50" />
                          <p className="text-sm font-medium">
                            {isLawyer ? "No expertise areas added yet" : "No legal interests added yet"}
                          </p>
                          <p className="text-xs mt-1">
                            {isLawyer ? 
                              "Click 'Edit Profile' to add your areas of legal expertise" : 
                              "Click 'Edit Profile' to add your areas of legal interest"}
                          </p>
                        </div>
                      ) : (
                        (isLawyer ? lawyerProfile.expertise : clientProfile.interests).map((item, index) => (
                          <Badge
                            key={index}
                            className="bg-[#007BFF]/10 dark:bg-[#00FFFF]/10 text-[#007BFF] dark:text-[#00FFFF] border-[#007BFF]/30 dark:border-[#00FFFF]/30 flex items-center gap-1 px-3 py-1"
                          >
                            {item}
                            {isEditing && (
                              <button
                                onClick={() => isLawyer ? removeExpertise(item) : removeInterest(item)}
                                className="ml-1 hover:bg-red-500/20 rounded-full p-0.5"
                              >
                                <X className="w-3 h-3" />
                              </button>
                            )}
                          </Badge>
                        ))
                      )}
                    </div>

                    {isEditing && (
                      <div className="flex gap-2">
                        <Input
                          placeholder={`Add new ${isLawyer ? 'expertise area' : 'legal interest'}...`}
                          value={isLawyer ? newExpertise : newInterest}
                          onChange={(e) => isLawyer ? setNewExpertise(e.target.value) : setNewInterest(e.target.value)}
                          onKeyPress={(e) => e.key === "Enter" && (isLawyer ? addExpertise() : addInterest())}
                          className="bg-white/50 dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B]"
                        />
                        <Button
                          onClick={isLawyer ? addExpertise : addInterest}
                          size="sm"
                          className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white"
                        >
                          <Plus className="w-4 h-4" />
                        </Button>
                      </div>
                    )}
                  </Card>

                  {isLawyer && (
                    <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                      <h4 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4 flex items-center gap-2">
                        <Trophy className="w-5 h-5" />
                        Achievements & Recognition
                      </h4>
                      <div className="space-y-3">
                        {lawyerProfile.achievements.map((achievement, index) => (
                          <div key={index} className="flex items-start gap-3 p-3 bg-gradient-to-r from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20 rounded-lg border border-yellow-200 dark:border-yellow-700">
                            <Trophy className="w-5 h-5 text-yellow-600 dark:text-yellow-400 mt-0.5" />
                            <span className="text-gray-700 dark:text-gray-300">{achievement}</span>
                          </div>
                        ))}
                      </div>
                    </Card>
                  )}
                </TabsContent>

                {/* Activity Tab */}
                <TabsContent value="activity" className="space-y-6">
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Performance Metrics */}
                    <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                      <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6 flex items-center gap-2">
                        <TrendingUp className="w-5 h-5" />
                        Performance Overview
                      </h3>
                      <div className="space-y-4">
                        {isLawyer ? (
                          <>
                            <div className="flex items-center justify-between">
                              <span className="text-gray-600 dark:text-gray-300">Success Rate</span>
                              <div className="flex items-center gap-2">
                                <div className="w-24 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                                  <div className="h-full bg-gradient-to-r from-[#007BFF] to-[#00FFFF] rounded-full" style={{ width: `${lawyerProfile.successRate}%` }}></div>
                                </div>
                                <span className="font-semibold text-[#007BFF] dark:text-[#00FFFF]">{lawyerProfile.successRate}%</span>
                              </div>
                            </div>
                            <div className="flex justify-between">
                              <span className="text-gray-600 dark:text-gray-300">Active Cases</span>
                              <span className="font-semibold text-gray-900 dark:text-[#E0E6F1]">{lawyerProfile.activeCases}</span>
                            </div>
                            <div className="flex justify-between">
                              <span className="text-gray-600 dark:text-gray-300">Total Cases</span>
                              <span className="font-semibold text-gray-900 dark:text-[#E0E6F1]">{lawyerProfile.totalCases}</span>
                            </div>
                          </>
                        ) : (
                          <>
                            <div className="flex justify-between">
                              <span className="text-gray-600 dark:text-gray-300">Active Cases</span>
                              <span className="font-semibold text-gray-900 dark:text-[#E0E6F1]">{clientProfile.activeCases}</span>
                            </div>
                            <div className="flex justify-between">
                              <span className="text-gray-600 dark:text-gray-300">Total Cases</span>
                              <span className="font-semibold text-gray-900 dark:text-[#E0E6F1]">{clientProfile.totalCases}</span>
                            </div>
                            <div className="flex justify-between">
                              <span className="text-gray-600 dark:text-gray-300">Account Since</span>
                              <span className="font-semibold text-gray-900 dark:text-[#E0E6F1]">Jan 2023</span>
                            </div>
                          </>
                        )}
                      </div>
                    </Card>

                    {/* Case History */}
                    <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
                      <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6 flex items-center gap-2">
                        <History className="w-5 h-5" />
                        Case History
                      </h3>
                      {isLoadingHistory ? (
                        <div className="flex items-center justify-center py-8">
                          <div className="w-6 h-6 border-2 border-[#007BFF] border-t-transparent rounded-full animate-spin"></div>
                        </div>
                      ) : (
                        <div className="space-y-3">
                          {caseHistory.length === 0 ? (
                            <div className="text-center py-8 text-gray-500 dark:text-gray-400">
                              <FileText className="w-12 h-12 mx-auto mb-3 opacity-50" />
                              <p>No case history found</p>
                              {isClient && (
                                <Button 
                                  variant="outline" 
                                  className="mt-2" 
                                  onClick={() => window.location.href = "/analysis"}
                                >
                                  <ChevronRight className="w-4 h-4 mr-1" />
                                  Start First Case
                                </Button>
                              )}
                            </div>
                          ) : (
                            <>
                              {caseHistory.map((case_item, index) => (
                                <div key={case_item.id || index} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-[#0D1B2A]/50 rounded-lg">
                                  <div>
                                    <p className="font-medium text-gray-900 dark:text-[#E0E6F1]">{case_item.type}</p>
                                    <p className="text-sm text-gray-600 dark:text-gray-300">{case_item.date}</p>
                                  </div>
                                  <Badge 
                                    variant={case_item.status === 'Completed' ? 'default' : 
                                           case_item.status === 'Resolved' ? 'secondary' : 'outline'}
                                    className={case_item.status === 'In Progress' ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300' : ''}
                                  >
                                    {case_item.status}
                                  </Badge>
                                </div>
                              ))}
                              {caseHistory.length > 5 && (
                                <div className="text-center pt-4">
                                  <Button 
                                    variant="outline" 
                                    className="mt-2" 
                                    onClick={() => window.location.href = isLawyer ? "/pro/my-cases" : "/client-history"}
                                  >
                                    <ChevronRight className="w-4 h-4 mr-1" />
                                    View All Cases
                                  </Button>
                                </div>
                              )}
                            </>
                          )}
                        </div>
                      )}
                    </Card>
                  </div>
                </TabsContent>
              </Tabs>
            </motion.div>
          </div>
        </main>
      </PageContainer>
    </>
  )
}

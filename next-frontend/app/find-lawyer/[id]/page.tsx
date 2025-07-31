"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { Navigation } from "@/components/navigation"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Textarea } from "@/components/ui/textarea"
import {
  Star,
  MapPin,
  Phone,
  Mail,
  Award,
  Calendar,
  CheckCircle,
  User,
  GraduationCap,
  Building,
  Clock,
} from "lucide-react"

// Mock lawyer data - in real app this would come from API
const lawyerData = {
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
  image: "/placeholder.svg?height=200&width=200",
  expertise: ["White Collar Crime", "Criminal Defense", "Bail Applications", "Corporate Fraud"],
  languages: ["English", "Hindi", "Marathi"],
  description:
    "Specialized in complex criminal cases with over 15 years of experience in high-profile matters. Known for meticulous case preparation and strong courtroom presence.",
  education: [
    { degree: "LLM in Criminal Law", institution: "National Law School, Bangalore", year: "2010" },
    { degree: "LLB", institution: "Government Law College, Mumbai", year: "2008" },
  ],
  barAdmission: "Bar Council of Maharashtra, 2009",
  lawFirm: "Sharma & Associates",
  successRate: 89,
  casesHandled: 450,
  availability: "Available",
  consultationFee: "₹5,000",
  hourlyRate: "₹8,000",
}

const mockReviews = [
  {
    id: 1,
    clientName: "Rajesh Kumar",
    rating: 5,
    date: "2024-01-15",
    caseType: "Criminal Defense",
    review:
      "Excellent lawyer with deep knowledge of criminal law. Handled my case professionally and got favorable outcome. Highly recommended!",
    verified: true,
  },
  {
    id: 2,
    clientName: "Anita Patel",
    rating: 5,
    date: "2024-01-10",
    caseType: "White Collar Crime",
    review:
      "Priya ma'am is extremely knowledgeable and fought my case with dedication. Her expertise in white collar crimes is exceptional.",
    verified: true,
  },
  {
    id: 3,
    clientName: "Suresh Gupta",
    rating: 4,
    date: "2023-12-20",
    caseType: "Bail Application",
    review: "Got bail within 48 hours of hiring her. Very efficient and knows the system well. Worth every penny.",
    verified: true,
  },
  {
    id: 4,
    clientName: "Meera Singh",
    rating: 5,
    date: "2023-12-15",
    caseType: "Corporate Fraud",
    review:
      "Outstanding representation in a complex corporate fraud case. Her attention to detail and strategic approach led to complete acquittal.",
    verified: true,
  },
]

export default function LawyerProfilePage() {
  const [activeTab, setActiveTab] = useState("overview")
  const [newReview, setNewReview] = useState("")
  const [newRating, setNewRating] = useState(5)

  const submitReview = () => {
    // In real app, this would submit to API
    console.log("Submitting review:", { review: newReview, rating: newRating })
    setNewReview("")
    setNewRating(5)
  }

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <Navigation />

        <main className="pt-24 pb-16">
          <div className="px-6 max-w-6xl mx-auto">
            {/* Header Section */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8">
              <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                <div className="flex flex-col md:flex-row gap-8">
                  <div className="flex-shrink-0">
                    <img
                      src={lawyerData.image || "/placeholder.svg"}
                      alt={lawyerData.name}
                      className="w-32 h-32 rounded-full object-cover border-4 border-[#007BFF] dark:border-[#00FFFF] shadow-lg"
                    />
                  </div>

                  <div className="flex-1">
                    <div className="flex flex-col md:flex-row md:items-start md:justify-between mb-4">
                      <div>
                        <h1 className="text-3xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">{lawyerData.name}</h1>
                        <p className="text-xl text-[#007BFF] dark:text-[#00FFFF] font-medium mb-3">
                          {lawyerData.specialization}
                        </p>
                        <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-300 mb-4">
                          <div className="flex items-center gap-1">
                            <MapPin className="w-4 h-4" />
                            {lawyerData.location}
                          </div>
                          <div className="flex items-center gap-1">
                            <Award className="w-4 h-4" />
                            {lawyerData.experience} years experience
                          </div>
                          <div className="flex items-center gap-1">
                            <Building className="w-4 h-4" />
                            {lawyerData.lawFirm}
                          </div>
                        </div>
                      </div>

                      <div className="flex flex-col items-end gap-3">
                        <div className="flex items-center gap-2">
                          <Star className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                          <span className="text-xl font-bold text-gray-900 dark:text-[#E0E6F1]">
                            {lawyerData.rating}
                          </span>
                          <span className="text-gray-600 dark:text-gray-300">({lawyerData.reviews} reviews)</span>
                        </div>
                        <Badge
                          className={
                            lawyerData.availability === "Available"
                              ? "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
                              : "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
                          }
                        >
                          <Clock className="w-4 h-4 mr-1" />
                          {lawyerData.availability}
                        </Badge>
                      </div>
                    </div>

                    <p className="text-gray-700 dark:text-gray-300 leading-relaxed mb-6">{lawyerData.description}</p>

                    <div className="flex flex-wrap gap-2 mb-6">
                      {lawyerData.expertise.map((skill, index) => (
                        <Badge
                          key={index}
                          variant="outline"
                          className="border-[#007BFF]/30 dark:border-[#00FFFF]/30 text-[#007BFF] dark:text-[#00FFFF]"
                        >
                          {skill}
                        </Badge>
                      ))}
                    </div>

                    <div className="flex gap-4">
                      <Button className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan">
                        <Phone className="w-4 h-4 mr-2" />
                        Contact Now
                      </Button>
                      <Button
                        variant="outline"
                        className="border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                      >
                        <Calendar className="w-4 h-4 mr-2" />
                        Schedule Consultation
                      </Button>
                    </div>
                  </div>
                </div>
              </Card>
            </motion.div>

            {/* Stats Cards */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8"
            >
              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover text-center">
                <div className="text-3xl font-bold text-[#007BFF] dark:text-[#00FFFF] mb-2">
                  {lawyerData.successRate}%
                </div>
                <div className="text-sm text-gray-600 dark:text-gray-300">Success Rate</div>
              </Card>

              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover text-center">
                <div className="text-3xl font-bold text-[#007BFF] dark:text-[#00FFFF] mb-2">
                  {lawyerData.casesHandled}
                </div>
                <div className="text-sm text-gray-600 dark:text-gray-300">Cases Handled</div>
              </Card>

              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover text-center">
                <div className="text-3xl font-bold text-[#007BFF] dark:text-[#00FFFF] mb-2">
                  {lawyerData.consultationFee}
                </div>
                <div className="text-sm text-gray-600 dark:text-gray-300">Consultation Fee</div>
              </Card>

              <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover text-center">
                <div className="text-3xl font-bold text-[#007BFF] dark:text-[#00FFFF] mb-2">
                  {lawyerData.hourlyRate}
                </div>
                <div className="text-sm text-gray-600 dark:text-gray-300">Hourly Rate</div>
              </Card>
            </motion.div>

            {/* Tabbed Content */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
              <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
                <TabsList className="grid w-full grid-cols-3 bg-gray-100 dark:bg-[#0D1B2A]/50">
                  <TabsTrigger
                    value="overview"
                    className="data-[state=active]:bg-[#007BFF] dark:data-[state=active]:bg-[#00FFFF] data-[state=active]:text-white dark:data-[state=active]:text-[#0D1B2A]"
                  >
                    Overview
                  </TabsTrigger>
                  <TabsTrigger
                    value="reviews"
                    className="data-[state=active]:bg-[#007BFF] dark:data-[state=active]:bg-[#00FFFF] data-[state=active]:text-white dark:data-[state=active]:text-[#0D1B2A]"
                  >
                    Reviews & Ratings
                  </TabsTrigger>
                  <TabsTrigger
                    value="contact"
                    className="data-[state=active]:bg-[#007BFF] dark:data-[state=active]:bg-[#00FFFF] data-[state=active]:text-white dark:data-[state=active]:text-[#0D1B2A]"
                  >
                    Contact & Booking
                  </TabsTrigger>
                </TabsList>

                <TabsContent value="overview" className="space-y-6">
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4 flex items-center gap-2">
                      <GraduationCap className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                      Education & Qualifications
                    </h3>
                    <div className="space-y-3">
                      {lawyerData.education.map((edu, index) => (
                        <div key={index} className="border-l-4 border-[#007BFF] dark:border-[#00FFFF] pl-4">
                          <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">{edu.degree}</h4>
                          <p className="text-gray-600 dark:text-gray-300">
                            {edu.institution} • {edu.year}
                          </p>
                        </div>
                      ))}
                      <div className="border-l-4 border-[#007BFF] dark:border-[#00FFFF] pl-4">
                        <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">Bar Admission</h4>
                        <p className="text-gray-600 dark:text-gray-300">{lawyerData.barAdmission}</p>
                      </div>
                    </div>
                  </Card>

                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">Languages</h3>
                    <div className="flex flex-wrap gap-2">
                      {lawyerData.languages.map((language, index) => (
                        <Badge
                          key={index}
                          variant="secondary"
                          className="bg-gray-100 dark:bg-[#0D1B2A]/50 text-gray-700 dark:text-gray-300"
                        >
                          {language}
                        </Badge>
                      ))}
                    </div>
                  </Card>
                </TabsContent>

                <TabsContent value="reviews" className="space-y-6">
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6">
                      Client Reviews & Ratings
                    </h3>

                    <div className="space-y-6">
                      {mockReviews.map((review) => (
                        <div
                          key={review.id}
                          className="border-b border-gray-200 dark:border-[#1B263B] pb-6 last:border-b-0"
                        >
                          <div className="flex items-start justify-between mb-3">
                            <div className="flex items-center gap-3">
                              <div className="w-10 h-10 bg-[#007BFF] dark:bg-[#00FFFF] rounded-full flex items-center justify-center">
                                <User className="w-5 h-5 text-white dark:text-[#0D1B2A]" />
                              </div>
                              <div>
                                <div className="flex items-center gap-2">
                                  <h4 className="font-semibold text-gray-900 dark:text-[#E0E6F1]">
                                    {review.clientName}
                                  </h4>
                                  {review.verified && (
                                    <Badge className="bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300 text-xs">
                                      <CheckCircle className="w-3 h-3 mr-1" />
                                      Verified Client
                                    </Badge>
                                  )}
                                </div>
                                <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-300">
                                  <div className="flex">
                                    {[...Array(5)].map((_, i) => (
                                      <Star
                                        key={i}
                                        className={`w-4 h-4 ${
                                          i < review.rating
                                            ? "fill-yellow-400 text-yellow-400"
                                            : "text-gray-300 dark:text-gray-600"
                                        }`}
                                      />
                                    ))}
                                  </div>
                                  <span>•</span>
                                  <span>{review.caseType}</span>
                                  <span>•</span>
                                  <span>{new Date(review.date).toLocaleDateString()}</span>
                                </div>
                              </div>
                            </div>
                          </div>
                          <p className="text-gray-700 dark:text-gray-300 leading-relaxed">{review.review}</p>
                        </div>
                      ))}
                    </div>
                  </Card>

                  {/* Submit Review Form */}
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-4">Write a Review</h3>
                    <div className="space-y-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                          Rating
                        </label>
                        <div className="flex gap-1">
                          {[1, 2, 3, 4, 5].map((star) => (
                            <button key={star} onClick={() => setNewRating(star)} className="p-1">
                              <Star
                                className={`w-6 h-6 ${
                                  star <= newRating
                                    ? "fill-yellow-400 text-yellow-400"
                                    : "text-gray-300 dark:text-gray-600"
                                }`}
                              />
                            </button>
                          ))}
                        </div>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">
                          Your Review
                        </label>
                        <Textarea
                          value={newReview}
                          onChange={(e) => setNewReview(e.target.value)}
                          placeholder="Share your experience working with this lawyer..."
                          className="bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300"
                          rows={4}
                        />
                      </div>

                      <Button
                        onClick={submitReview}
                        disabled={!newReview.trim()}
                        className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan"
                      >
                        Submit Review
                      </Button>
                    </div>
                  </Card>
                </TabsContent>

                <TabsContent value="contact" className="space-y-6">
                  <Card className="p-6 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] prestigious-hover">
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6">
                      Contact Information
                    </h3>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div className="space-y-4">
                        <div className="flex items-center gap-3">
                          <Phone className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                          <div>
                            <p className="font-medium text-gray-900 dark:text-[#E0E6F1]">Phone</p>
                            <p className="text-gray-600 dark:text-gray-300">{lawyerData.phone}</p>
                          </div>
                        </div>

                        <div className="flex items-center gap-3">
                          <Mail className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                          <div>
                            <p className="font-medium text-gray-900 dark:text-[#E0E6F1]">Email</p>
                            <p className="text-gray-600 dark:text-gray-300">{lawyerData.email}</p>
                          </div>
                        </div>

                        <div className="flex items-center gap-3">
                          <MapPin className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                          <div>
                            <p className="font-medium text-gray-900 dark:text-[#E0E6F1]">Location</p>
                            <p className="text-gray-600 dark:text-gray-300">{lawyerData.location}</p>
                          </div>
                        </div>
                      </div>

                      <div className="space-y-4">
                        <div>
                          <p className="font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">Consultation Fee</p>
                          <p className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">
                            {lawyerData.consultationFee}
                          </p>
                        </div>

                        <div>
                          <p className="font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">Hourly Rate</p>
                          <p className="text-2xl font-bold text-[#007BFF] dark:text-[#00FFFF]">
                            {lawyerData.hourlyRate}
                          </p>
                        </div>

                        <div>
                          <p className="font-medium text-gray-900 dark:text-[#E0E6F1] mb-2">Availability</p>
                          <Badge
                            className={
                              lawyerData.availability === "Available"
                                ? "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
                                : "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
                            }
                          >
                            {lawyerData.availability}
                          </Badge>
                        </div>
                      </div>
                    </div>

                    <div className="mt-8 pt-6 border-t border-gray-200 dark:border-[#1B263B]">
                      <div className="flex gap-4">
                        <Button className="flex-1 bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan">
                          <Phone className="w-4 h-4 mr-2" />
                          Call Now
                        </Button>
                        <Button
                          variant="outline"
                          className="flex-1 border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                        >
                          <Mail className="w-4 h-4 mr-2" />
                          Send Email
                        </Button>
                        <Button
                          variant="outline"
                          className="flex-1 border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 prestigious-hover bg-transparent"
                        >
                          <Calendar className="w-4 h-4 mr-2" />
                          Book Consultation
                        </Button>
                      </div>
                    </div>
                  </Card>
                </TabsContent>
              </Tabs>
            </motion.div>
          </div>
        </main>
      </PageContainer>
    </>
  )
}

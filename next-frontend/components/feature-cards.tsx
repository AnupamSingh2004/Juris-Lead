"use client"

import { motion } from "framer-motion"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  BarChart3,
  FileText,
  Users,
  BookOpen,
  Scale,
  Briefcase,
  ArrowRight,
  Sparkles,
  Clock,
  Shield,
} from "lucide-react"

const features = [
  {
    icon: <BarChart3 className="w-8 h-8" />,
    title: "Incident Analyzer",
    description: "Get comprehensive legal analysis of your situation with AI-powered insights and recommendations.",
    features: ["Legal issue identification", "Severity assessment", "Action recommendations", "Timeline estimation"],
    href: "/analyzer",
    color: "from-blue-500 to-cyan-500",
    badge: "Most Popular",
  },
  {
    icon: <FileText className="w-8 h-8" />,
    title: "Document Summarizer",
    description: "Transform complex legal documents into clear, actionable summaries with key points highlighted.",
    features: ["Multi-format support", "Key point extraction", "Legal implications", "Action items"],
    href: "/summarizer",
    color: "from-green-500 to-emerald-500",
    badge: "Time Saver",
  },
  {
    icon: <Briefcase className="w-8 h-8" />,
    title: "Case Builder",
    description: "Build comprehensive case timelines with interactive tools and real-time AI analysis.",
    features: ["Timeline creation", "Evidence tracking", "Real-time analysis", "Export capabilities"],
    href: "/case-builder",
    color: "from-purple-500 to-violet-500",
    badge: "Professional",
  },
  {
    icon: <Users className="w-8 h-8" />,
    title: "Find Expert Lawyers",
    description: "Connect with qualified legal professionals specializing in your specific case type.",
    features: ["Verified profiles", "Specialization matching", "Reviews & ratings", "Direct contact"],
    href: "/find-lawyer",
    color: "from-orange-500 to-red-500",
    badge: "Verified",
  },
  {
    icon: <BookOpen className="w-8 h-8" />,
    title: "Legal Knowledge Hub",
    description: "Explore comprehensive guides and resources on various areas of Indian law.",
    features: ["Expert articles", "Case studies", "Legal precedents", "Regular updates"],
    href: "/explore",
    color: "from-indigo-500 to-blue-500",
    badge: "Educational",
  },
  {
    icon: <Scale className="w-8 h-8" />,
    title: "Pro Dashboard",
    description: "Advanced tools for legal professionals to manage cases and connect with clients.",
    features: ["Lead management", "Case tracking", "Client communication", "Analytics"],
    href: "/pro/dashboard",
    color: "from-gray-600 to-gray-800",
    badge: "For Lawyers",
  },
]

export function FeatureCards() {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2,
      },
    },
  }

  const cardVariants = {
    hidden: { opacity: 0, y: 50, scale: 0.9 },
    visible: {
      opacity: 1,
      y: 0,
      scale: 1,
      transition: {
        duration: 0.6,
        ease: [0.25, 0.46, 0.45, 0.94],
      },
    },
  }

  return (
    <section className="py-20 px-6 relative overflow-hidden">
      {/* Background Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute top-1/4 left-1/4 w-64 h-64 bg-gradient-to-r from-[#007BFF]/5 to-[#00FFFF]/5 rounded-full blur-3xl"
          animate={{
            x: [0, 100, 0],
            y: [0, -50, 0],
          }}
          transition={{
            duration: 20,
            repeat: Number.POSITIVE_INFINITY,
            ease: "easeInOut",
          }}
        />
        <motion.div
          className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-gradient-to-l from-[#00FFFF]/5 to-[#007BFF]/5 rounded-full blur-3xl"
          animate={{
            x: [0, -80, 0],
            y: [0, 60, 0],
          }}
          transition={{
            duration: 25,
            repeat: Number.POSITIVE_INFINITY,
            ease: "easeInOut",
            delay: 5,
          }}
        />
      </div>

      <div className="max-w-7xl mx-auto relative z-10">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <motion.div
            className="inline-flex items-center gap-2 mb-4"
            whileHover={{ scale: 1.05 }}
            transition={{ type: "spring", stiffness: 300 }}
          >
            <Sparkles className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
            <Badge
              variant="outline"
              className="border-[#007BFF]/30 dark:border-[#00FFFF]/30 text-[#007BFF] dark:text-[#00FFFF] bg-[#007BFF]/5 dark:bg-[#00FFFF]/5"
            >
              Powered by Advanced AI
            </Badge>
          </motion.div>
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-6">
            Complete Legal Technology Suite
          </h2>
          <p className="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto leading-relaxed">
            Everything you need to understand, analyze, and act on legal matters with confidence and precision.
          </p>
        </motion.div>

        {/* Feature Cards Grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
        >
          {features.map((feature, index) => (
            <motion.div key={index} variants={cardVariants} className="h-full">
              <Card className="p-8 bg-white/90 dark:bg-[#1B263B]/90 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF]/50 dark:hover:border-[#00FFFF]/50 transition-all duration-500 prestigious-hover dark:hover:glow-cyan group h-full flex flex-col">
                {/* Card Header */}
                <div className="flex items-start justify-between mb-6">
                  <motion.div
                    className={`p-4 bg-gradient-to-r ${feature.color} rounded-2xl shadow-lg group-hover:shadow-xl transition-all duration-300`}
                    whileHover={{ scale: 1.1, rotate: 5 }}
                    transition={{ type: "spring", stiffness: 300 }}
                  >
                    <div className="text-white">{feature.icon}</div>
                  </motion.div>
                  <Badge
                    variant="secondary"
                    className="bg-gray-100 dark:bg-[#0D1B2A]/50 text-gray-600 dark:text-gray-300 group-hover:bg-[#007BFF]/10 dark:group-hover:bg-[#00FFFF]/10 transition-all duration-300"
                  >
                    {feature.badge}
                  </Badge>
                </div>

                {/* Card Content */}
                <div className="flex-1 flex flex-col">
                  <h3 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4 group-hover:text-[#007BFF] dark:group-hover:text-[#00FFFF] transition-colors duration-300">
                    {feature.title}
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300 mb-6 leading-relaxed flex-1">{feature.description}</p>

                  {/* Feature List */}
                  <div className="space-y-3 mb-8">
                    {feature.features.map((item, idx) => (
                      <motion.div
                        key={idx}
                        className="flex items-center gap-3"
                        initial={{ opacity: 0, x: -20 }}
                        whileInView={{ opacity: 1, x: 0 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.1 * idx }}
                      >
                        <div className="w-2 h-2 bg-gradient-to-r from-[#007BFF] to-[#00FFFF] rounded-full" />
                        <span className="text-sm text-gray-600 dark:text-gray-300">{item}</span>
                      </motion.div>
                    ))}
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
                      onClick={() => (window.location.href = feature.href)}
                    >
                      <span className="flex items-center justify-center gap-2">
                        Get Started
                        <ArrowRight className="w-4 h-4 group-hover/btn:translate-x-1 transition-transform duration-300" />
                      </span>
                    </Button>
                  </motion.div>
                </div>

                {/* Hover Effect Overlay */}
                <motion.div
                  className="absolute inset-0 bg-gradient-to-r from-[#007BFF]/5 to-[#00FFFF]/5 dark:from-[#00FFFF]/5 dark:to-[#007BFF]/5 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none"
                  initial={false}
                />
              </Card>
            </motion.div>
          ))}
        </motion.div>

        {/* Bottom CTA */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, delay: 0.3 }}
          className="text-center mt-16"
        >
          <Card className="p-8 bg-gradient-to-r from-[#007BFF]/5 to-[#00FFFF]/5 dark:from-[#00FFFF]/5 dark:to-[#007BFF]/5 border-[#007BFF]/20 dark:border-[#00FFFF]/20 backdrop-blur-sm">
            <div className="flex items-center justify-center gap-3 mb-4">
              <Clock className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
              <Shield className="w-6 h-6 text-[#007BFF] dark:text-[#00FFFF]" />
            </div>
            <h3 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">Ready to Get Started?</h3>
            <p className="text-gray-600 dark:text-gray-300 mb-6 max-w-2xl mx-auto">
              Join thousands of users who trust Juris-Lead for their legal analysis needs. Start your first analysis
              today.
            </p>
            <motion.div
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              transition={{ type: "spring", stiffness: 300 }}
            >
              <Button
                size="lg"
                className="px-8 py-4 text-lg font-semibold bg-gradient-to-r from-[#007BFF] to-[#0056b3] dark:from-[#00FFFF] dark:to-[#00CCCC] hover:from-[#0056b3] hover:to-[#004085] dark:hover:from-[#00CCCC] dark:hover:to-[#00AAAA] text-white dark:text-[#0D1B2A] shadow-xl hover:shadow-2xl transition-all duration-300 prestigious-hover dark:glow-cyan"
                onClick={() => (window.location.href = "/analyzer")}
              >
                <Sparkles className="w-5 h-5 mr-2" />
                Start Your Analysis
                <ArrowRight className="w-5 h-5 ml-2" />
              </Button>
            </motion.div>
          </Card>
        </motion.div>
      </div>
    </section>
  )
}

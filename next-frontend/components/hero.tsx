"use client"

import { useState, useEffect } from "react"
import { motion } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { Scale, Sparkles, ArrowRight, History, Shield, AlertTriangle } from "lucide-react"

export function Hero() {
  const [isLoggedIn, setIsLoggedIn] = useState(false)
  const [historyCount, setHistoryCount] = useState(0)

  useEffect(() => {
    try {
      const loggedIn = localStorage.getItem("juris-logged-in")
      setIsLoggedIn(loggedIn === "true")

      const history = JSON.parse(localStorage.getItem("juris-history") || "[]")
      setHistoryCount(history.length)
    } catch (error) {
      console.error("Error loading user state:", error)
      setIsLoggedIn(false)
      setHistoryCount(0)
    }
  }, [])

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2,
        delayChildren: 0.1,
      },
    },
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.8,
        ease: [0.25, 0.46, 0.45, 0.94],
      },
    },
  }

  const floatingVariants = {
    animate: {
      y: [-10, 10, -10],
      transition: {
        duration: 6,
        repeat: Number.POSITIVE_INFINITY,
        ease: "easeInOut",
      },
    },
  }

  return (
    <section className="relative min-h-screen flex items-center justify-center px-6 py-20 overflow-hidden">
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute top-20 left-10 w-72 h-72 bg-gradient-to-r from-[#007BFF]/10 to-[#00FFFF]/10 dark:from-[#00FFFF]/10 dark:to-[#007BFF]/10 rounded-full blur-3xl"
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.6, 0.3],
          }}
          transition={{
            duration: 8,
            repeat: Number.POSITIVE_INFINITY,
            ease: "easeInOut",
          }}
        />
        <motion.div
          className="absolute bottom-20 right-10 w-96 h-96 bg-gradient-to-l from-[#007BFF]/10 to-[#00FFFF]/10 dark:from-[#00FFFF]/10 dark:to-[#007BFF]/10 rounded-full blur-3xl"
          animate={{
            scale: [1.2, 1, 1.2],
            opacity: [0.4, 0.7, 0.4],
          }}
          transition={{
            duration: 10,
            repeat: Number.POSITIVE_INFINITY,
            ease: "easeInOut",
            delay: 2,
          }}
        />
      </div>

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="max-w-6xl mx-auto text-center relative z-10"
      >
        {/* Main Hero Content */}
        <motion.div variants={itemVariants} className="mb-8">
          <motion.div
            className="inline-flex items-center gap-3 mb-6"
            whileHover={{ scale: 1.05 }}
            transition={{ type: "spring", stiffness: 300 }}
          >
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
              <Scale className="w-12 h-12 text-white" />
            </motion.div>
            <div className="text-left">
              <h1 className="text-5xl md:text-7xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 dark:from-[#E0E6F1] dark:to-[#00FFFF] bg-clip-text text-transparent leading-tight">
                Juris-Lead
              </h1>
              <motion.p
                className="text-xl md:text-2xl text-gray-600 dark:text-gray-300 mt-2"
                animate={{
                  opacity: [0.7, 1, 0.7],
                }}
                transition={{
                  duration: 4,
                  repeat: Number.POSITIVE_INFINITY,
                  ease: "easeInOut",
                }}
              >
                Legal Clarity with AI Precision
              </motion.p>
            </div>
          </motion.div>
        </motion.div>

        <motion.div variants={itemVariants} className="mb-12">
          <h2 className="text-2xl md:text-4xl font-semibold text-gray-800 dark:text-[#E0E6F1] mb-6 leading-relaxed">
            Navigate Complex Legal Situations with{" "}
            <motion.span
              className="bg-gradient-to-r from-[#007BFF] to-[#00FFFF] bg-clip-text text-transparent"
              animate={{
                backgroundPosition: ["0% 50%", "100% 50%", "0% 50%"],
              }}
              transition={{
                duration: 5,
                repeat: Number.POSITIVE_INFINITY,
                ease: "linear",
              }}
            >
              Intelligent Analysis
            </motion.span>
          </h2>
          <p className="text-lg md:text-xl text-gray-600 dark:text-gray-300 max-w-4xl mx-auto leading-relaxed">
            From incident analysis to document summaries, get expert-level legal insights powered by advanced AI
            technology. Make informed decisions with confidence.
          </p>
        </motion.div>

        {/* Action Buttons */}
        <motion.div variants={itemVariants} className="flex flex-col sm:flex-row gap-6 justify-center mb-16">
          <motion.div
            whileHover={{ scale: 1.05, y: -2 }}
            whileTap={{ scale: 0.95 }}
            transition={{ type: "spring", stiffness: 300 }}
          >
            <Button
              size="lg"
              className="px-8 py-4 text-lg font-semibold bg-gradient-to-r from-[#007BFF] to-[#0056b3] dark:from-[#00FFFF] dark:to-[#00CCCC] hover:from-[#0056b3] hover:to-[#004085] dark:hover:from-[#00CCCC] dark:hover:to-[#00AAAA] text-white dark:text-[#0D1B2A] shadow-xl hover:shadow-2xl transition-all duration-300 prestigious-hover dark:glow-cyan"
              onClick={() => (window.location.href = "/analyzer")}
            >
              <Sparkles className="w-5 h-5 mr-2" />
              Start Analysis
              <ArrowRight className="w-5 h-5 ml-2" />
            </Button>
          </motion.div>

          {isLoggedIn && historyCount > 0 && (
            <motion.div
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
              transition={{ type: "spring", stiffness: 300 }}
            >
              <Button
                size="lg"
                variant="outline"
                className="px-8 py-4 text-lg font-semibold border-2 border-[#007BFF] dark:border-[#00FFFF] text-[#007BFF] dark:text-[#00FFFF] hover:bg-[#007BFF] dark:hover:bg-[#00FFFF] hover:text-white dark:hover:text-[#0D1B2A] shadow-lg hover:shadow-xl transition-all duration-300 prestigious-hover bg-transparent"
                onClick={() => (window.location.href = "/client-history")}
              >
                <History className="w-5 h-5 mr-2" />
                My History ({historyCount})
                <ArrowRight className="w-5 h-5 ml-2" />
              </Button>
            </motion.div>
          )}

          <motion.div
            whileHover={{ scale: 1.05, y: -2 }}
            whileTap={{ scale: 0.95 }}
            transition={{ type: "spring", stiffness: 300 }}
          >
            <Button
              size="lg"
              variant="outline"
              className="px-8 py-4 text-lg font-semibold border-2 border-gray-300 dark:border-[#1B263B] text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 shadow-lg hover:shadow-xl transition-all duration-300 prestigious-hover bg-transparent"
              onClick={() => (window.location.href = "/explore")}
            >
              Explore Legal Topics
              <ArrowRight className="w-5 h-5 ml-2" />
            </Button>
          </motion.div>
        </motion.div>

        {/* AI Disclaimer */}
        <motion.div variants={itemVariants} className="mb-12">
          <Card className="p-6 bg-yellow-50/80 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800 backdrop-blur-sm max-w-4xl mx-auto">
            <div className="flex items-start gap-4">
              <div className="flex-shrink-0">
                <AlertTriangle className="w-6 h-6 text-yellow-600 dark:text-yellow-400" />
              </div>
              <div className="text-left">
                <h3 className="font-semibold text-yellow-800 dark:text-yellow-200 mb-2">Important Disclaimer</h3>
                <p className="text-yellow-700 dark:text-yellow-300 leading-relaxed">
                  All analyses and summaries are generated by AI technology and are for informational purposes only.
                  This content should not be considered as legal advice and should not be blindly trusted. Always
                  consult with qualified legal professionals for specific legal matters and decisions.
                </p>
              </div>
            </div>
          </Card>
        </motion.div>

        {/* Floating Feature Highlights */}
        <motion.div variants={itemVariants} className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl mx-auto">
          {[
            {
              icon: <Scale className="w-8 h-8" />,
              title: "AI-Powered Analysis",
              description: "Advanced algorithms analyze your legal situations with precision",
            },
            {
              icon: <Shield className="w-8 h-8" />,
              title: "Secure & Private",
              description: "Your data is encrypted and protected with enterprise-grade security",
            },
            {
              icon: <Sparkles className="w-8 h-8" />,
              title: "Expert Insights",
              description: "Get professional-level legal insights in minutes, not hours",
            },
          ].map((feature, index) => (
            <motion.div
              key={index}
              variants={floatingVariants}
              animate="animate"
              transition={{ delay: index * 0.5 }}
              whileHover={{ scale: 1.05, y: -5 }}
              className="group"
            >
              <Card className="p-6 bg-white/80 dark:bg-[#1B263B]/80 backdrop-blur-sm border-gray-200 dark:border-[#1B263B] hover:border-[#007BFF] dark:hover:border-[#00FFFF] transition-all duration-300 prestigious-hover dark:hover:glow-cyan h-full">
                <div className="text-center">
                  <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-[#007BFF]/10 to-[#00FFFF]/10 rounded-2xl mb-4 group-hover:from-[#007BFF]/20 group-hover:to-[#00FFFF]/20 transition-all duration-300">
                    <div className="text-[#007BFF] dark:text-[#00FFFF]">{feature.icon}</div>
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900 dark:text-[#E0E6F1] mb-3">{feature.title}</h3>
                  <p className="text-gray-600 dark:text-gray-300 leading-relaxed">{feature.description}</p>
                </div>
              </Card>
            </motion.div>
          ))}
        </motion.div>
      </motion.div>
    </section>
  )
}

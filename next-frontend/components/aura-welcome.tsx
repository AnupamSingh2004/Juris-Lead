"use client"

import { useState, useEffect } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { Scale, Sparkles, ArrowRight, Brain, Shield, Zap } from "lucide-react"

interface AuraWelcomeProps {
  onComplete: () => void
}

// Deterministic positions for floating elements to avoid hydration mismatch
const FLOATING_POSITIONS = [
  { left: 10, top: 20 },
  { left: 85, top: 15 },
  { left: 25, top: 75 },
  { left: 70, top: 85 },
  { left: 15, top: 45 },
  { left: 90, top: 60 },
  { left: 45, top: 10 },
  { left: 60, top: 90 },
  { left: 30, top: 35 },
  { left: 80, top: 25 },
  { left: 5, top: 70 },
  { left: 95, top: 40 }
]

export function AuraWelcome({ onComplete }: AuraWelcomeProps) {
  const [currentStep, setCurrentStep] = useState(0)
  const [isVisible, setIsVisible] = useState(true)
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const steps = [
    {
      icon: <Scale className="w-16 h-16" />,
      title: "Welcome to Juris-Lead",
      subtitle: "Your AI-Powered Legal Assistant",
      description: "Experience the future of legal analysis with cutting-edge artificial intelligence technology.",
      color: "from-[#007BFF] to-[#0056b3]",
    },
    {
      icon: <Brain className="w-16 h-16" />,
      title: "Meet Aura",
      subtitle: "Advanced Legal Intelligence",
      description: "Aura analyzes complex legal situations and provides expert-level insights in seconds.",
      color: "from-[#00FFFF] to-[#00CCCC]",
    },
    {
      icon: <Shield className="w-16 h-16" />,
      title: "Secure & Private",
      subtitle: "Your Data is Protected",
      description: "Enterprise-grade security ensures your sensitive legal information remains confidential.",
      color: "from-[#007BFF] to-[#00FFFF]",
    },
    {
      icon: <Zap className="w-16 h-16" />,
      title: "Ready to Begin",
      subtitle: "Start Your Legal Journey",
      description: "Transform how you understand and navigate legal challenges with AI-powered precision.",
      color: "from-[#00FFFF] to-[#007BFF]",
    },
  ]

  useEffect(() => {
    const timer = setTimeout(() => {
      if (currentStep < steps.length - 1) {
        setCurrentStep(currentStep + 1)
      }
    }, 3000)

    return () => clearTimeout(timer)
  }, [currentStep, steps.length])

  const handleComplete = () => {
    setIsVisible(false)
    setTimeout(onComplete, 500)
  }

  const handleSkip = () => {
    setCurrentStep(steps.length - 1)
  }

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-50 flex items-center justify-center bg-gradient-to-br from-[#0D1B2A] via-[#1B263B] to-[#0D1B2A] overflow-hidden"
        >
          {/* Animated Background */}
          <div className="absolute inset-0 overflow-hidden">
            <motion.div
              className="absolute top-1/4 left-1/4 w-96 h-96 bg-gradient-to-r from-[#007BFF]/20 to-[#00FFFF]/20 rounded-full blur-3xl"
              animate={{
                scale: [1, 1.5, 1],
                opacity: [0.3, 0.6, 0.3],
                x: [0, 100, 0],
                y: [0, -50, 0],
              }}
              transition={{
                duration: 8,
                repeat: Number.POSITIVE_INFINITY,
                ease: "easeInOut",
              }}
            />
            <motion.div
              className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-gradient-to-l from-[#00FFFF]/20 to-[#007BFF]/20 rounded-full blur-3xl"
              animate={{
                scale: [1.2, 1, 1.2],
                opacity: [0.4, 0.7, 0.4],
                x: [0, -80, 0],
                y: [0, 60, 0],
              }}
              transition={{
                duration: 10,
                repeat: Number.POSITIVE_INFINITY,
                ease: "easeInOut",
                delay: 2,
              }}
            />
          </div>

          {/* Main Content */}
          <div className="relative z-10 max-w-2xl mx-auto px-6 text-center">
            <AnimatePresence mode="wait">
              <motion.div
                key={currentStep}
                initial={{ opacity: 0, y: 50, scale: 0.9 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: -50, scale: 0.9 }}
                transition={{ duration: 0.6, ease: [0.25, 0.46, 0.45, 0.94] }}
              >
                <Card className="p-12 bg-white/10 backdrop-blur-xl border-white/20 shadow-2xl">
                  {/* Icon */}
                  <motion.div
                    className={`inline-flex items-center justify-center w-24 h-24 bg-gradient-to-r ${steps[currentStep].color} rounded-3xl mb-8 shadow-2xl`}
                    animate={{
                      scale: [1, 1.1, 1],
                      rotate: [0, 5, -5, 0],
                    }}
                    transition={{
                      duration: 3,
                      repeat: Number.POSITIVE_INFINITY,
                      ease: "easeInOut",
                    }}
                  >
                    <div className="text-white">{steps[currentStep].icon}</div>
                  </motion.div>

                  {/* Content */}
                  <motion.h1
                    className="text-4xl md:text-5xl font-bold text-white mb-4"
                    animate={{
                      backgroundPosition: ["0% 50%", "100% 50%", "0% 50%"],
                    }}
                    style={{
                      background: `linear-gradient(45deg, #007BFF, #00FFFF, #007BFF)`,
                      backgroundSize: "200% 200%",
                      WebkitBackgroundClip: "text",
                      WebkitTextFillColor: "transparent",
                      backgroundClip: "text",
                    }}
                    transition={{
                      duration: 4,
                      repeat: Number.POSITIVE_INFINITY,
                      ease: "linear",
                    }}
                  >
                    {steps[currentStep].title}
                  </motion.h1>

                  <motion.h2
                    className="text-xl md:text-2xl text-[#00FFFF] mb-6 font-medium"
                    animate={{
                      opacity: [0.7, 1, 0.7],
                    }}
                    transition={{
                      duration: 2,
                      repeat: Number.POSITIVE_INFINITY,
                      ease: "easeInOut",
                    }}
                  >
                    {steps[currentStep].subtitle}
                  </motion.h2>

                  <p className="text-lg text-white/80 mb-8 leading-relaxed max-w-lg mx-auto">
                    {steps[currentStep].description}
                  </p>

                  {/* Progress Indicators */}
                  <div className="flex justify-center gap-3 mb-8">
                    {steps.map((_, index) => (
                      <motion.div
                        key={index}
                        className={`w-3 h-3 rounded-full transition-all duration-300 ${
                          index === currentStep
                            ? "bg-[#00FFFF] shadow-lg shadow-[#00FFFF]/50"
                            : index < currentStep
                              ? "bg-[#007BFF]"
                              : "bg-white/30"
                        }`}
                        animate={
                          index === currentStep
                            ? {
                                scale: [1, 1.3, 1],
                                opacity: [0.7, 1, 0.7],
                              }
                            : {}
                        }
                        transition={{
                          duration: 1.5,
                          repeat: Number.POSITIVE_INFINITY,
                          ease: "easeInOut",
                        }}
                      />
                    ))}
                  </div>

                  {/* Action Buttons */}
                  <div className="flex flex-col sm:flex-row gap-4 justify-center">
                    {currentStep === steps.length - 1 ? (
                      <motion.div
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        transition={{ type: "spring", stiffness: 300 }}
                      >
                        <Button
                          onClick={handleComplete}
                          size="lg"
                          className="px-8 py-4 text-lg font-semibold bg-gradient-to-r from-[#00FFFF] to-[#00CCCC] hover:from-[#00CCCC] hover:to-[#00AAAA] text-[#0D1B2A] shadow-xl hover:shadow-2xl transition-all duration-300"
                        >
                          <Sparkles className="w-5 h-5 mr-2" />
                          Enter Juris-Lead
                          <ArrowRight className="w-5 h-5 ml-2" />
                        </Button>
                      </motion.div>
                    ) : (
                      <>
                        <motion.div
                          whileHover={{ scale: 1.05 }}
                          whileTap={{ scale: 0.95 }}
                          transition={{ type: "spring", stiffness: 300 }}
                        >
                          <Button
                            onClick={() => setCurrentStep(currentStep + 1)}
                            size="lg"
                            className="px-8 py-4 text-lg font-semibold bg-gradient-to-r from-[#007BFF] to-[#0056b3] hover:from-[#0056b3] hover:to-[#004085] text-white shadow-xl hover:shadow-2xl transition-all duration-300"
                          >
                            Continue
                            <ArrowRight className="w-5 h-5 ml-2" />
                          </Button>
                        </motion.div>
                        <Button
                          onClick={handleSkip}
                          variant="ghost"
                          size="lg"
                          className="px-8 py-4 text-lg font-medium text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300"
                        >
                          Skip Introduction
                        </Button>
                      </>
                    )}
                  </div>
                </Card>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Floating Elements - only render on client to avoid hydration mismatch */}
          {mounted && FLOATING_POSITIONS.map((position, i) => (
            <motion.div
              key={i}
              className="absolute w-2 h-2 bg-[#00FFFF]/40 rounded-full"
              style={{
                left: `${position.left}%`,
                top: `${position.top}%`,
              }}
              animate={{
                y: [0, -100, 0],
                opacity: [0, 1, 0],
                scale: [0, 1, 0],
              }}
              transition={{
                duration: (i % 3 + 1) * 2 + 6, // Deterministic duration based on index
                repeat: Number.POSITIVE_INFINITY,
                delay: (i % 4) * 1.25, // Deterministic delay based on index
                ease: "easeInOut",
              }}
            />
          ))}
        </motion.div>
      )}
    </AnimatePresence>
  )
}

"use client"

import { motion } from "framer-motion"
import { useState, useEffect } from "react"

// Deterministic particle positions to avoid hydration mismatch
const PARTICLE_POSITIONS = [
  { left: 15, top: 25 },
  { left: 75, top: 10 },
  { left: 30, top: 60 },
  { left: 85, top: 45 },
  { left: 10, top: 80 },
  { left: 60, top: 20 },
  { left: 40, top: 90 },
  { left: 90, top: 70 },
  { left: 20, top: 40 },
  { left: 70, top: 85 },
  { left: 50, top: 15 },
  { left: 25, top: 75 },
  { left: 80, top: 30 },
  { left: 35, top: 55 },
  { left: 95, top: 5 },
  { left: 5, top: 95 },
  { left: 65, top: 35 },
  { left: 45, top: 65 },
  { left: 55, top: 50 },
  { left: 18, top: 88 }
]

export function LivingBackground() {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <div className="fixed inset-0 -z-10 overflow-hidden">
      {/* Base gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-white via-gray-50 to-blue-50 dark:from-[#0D1B2A] dark:via-[#1B263B] dark:to-[#0D1B2A]" />

      {/* Animated orbs */}
      <motion.div
        className="absolute top-1/4 left-1/4 w-96 h-96 bg-gradient-to-r from-[#007BFF]/20 to-[#00FFFF]/20 dark:from-[#00FFFF]/20 dark:to-[#007BFF]/20 rounded-full blur-3xl"
        animate={{
          x: [0, 100, -50, 0],
          y: [0, -100, 50, 0],
          scale: [1, 1.2, 0.8, 1],
        }}
        transition={{
          duration: 20,
          repeat: Number.POSITIVE_INFINITY,
          ease: "easeInOut",
        }}
      />

      <motion.div
        className="absolute top-3/4 right-1/4 w-80 h-80 bg-gradient-to-l from-[#00FFFF]/15 to-[#007BFF]/15 dark:from-[#007BFF]/15 dark:to-[#00FFFF]/15 rounded-full blur-3xl"
        animate={{
          x: [0, -80, 60, 0],
          y: [0, 80, -40, 0],
          scale: [1, 0.9, 1.1, 1],
        }}
        transition={{
          duration: 25,
          repeat: Number.POSITIVE_INFINITY,
          ease: "easeInOut",
          delay: 5,
        }}
      />

      <motion.div
        className="absolute bottom-1/4 left-1/2 w-64 h-64 bg-gradient-to-r from-[#007BFF]/10 to-[#00FFFF]/10 dark:from-[#00FFFF]/10 dark:to-[#007BFF]/10 rounded-full blur-3xl"
        animate={{
          x: [0, 120, -80, 0],
          y: [0, -60, 40, 0],
          scale: [1, 1.3, 0.7, 1],
        }}
        transition={{
          duration: 30,
          repeat: Number.POSITIVE_INFINITY,
          ease: "easeInOut",
          delay: 10,
        }}
      />

      {/* Floating particles - only render on client to avoid hydration mismatch */}
      {mounted && PARTICLE_POSITIONS.map((position, i) => (
        <motion.div
          key={i}
          className="absolute w-2 h-2 bg-[#007BFF]/30 dark:bg-[#00FFFF]/30 rounded-full"
          style={{
            left: `${position.left}%`,
            top: `${position.top}%`,
          }}
          animate={{
            y: [0, -100, 0],
            opacity: [0, 1, 0],
          }}
          transition={{
            duration: (i % 3 + 1) * 5 + 10, // Deterministic duration based on index
            repeat: Number.POSITIVE_INFINITY,
            delay: (i % 5) * 2, // Deterministic delay based on index
            ease: "easeInOut",
          }}
        />
      ))}

      {/* Grid pattern overlay */}
      <div className="absolute inset-0 bg-[linear-gradient(rgba(0,123,255,0.03)_1px,transparent_1px),linear-gradient(90deg,rgba(0,123,255,0.03)_1px,transparent_1px)] dark:bg-[linear-gradient(rgba(0,255,255,0.03)_1px,transparent_1px),linear-gradient(90deg,rgba(0,255,255,0.03)_1px,transparent_1px)] bg-[size:50px_50px]" />
    </div>
  )
}

"use client"

import { motion } from "framer-motion"

export function AuraAnimation() {
  return (
    <div className="flex items-center justify-center">
      <div className="relative w-24 h-24">
        {/* Outer ring */}
        <motion.div
          className="absolute inset-0 rounded-full border-4 border-[#007BFF]/30 dark:border-[#00FFFF]/30"
          animate={{ rotate: 360 }}
          transition={{ duration: 3, repeat: Number.POSITIVE_INFINITY, ease: "linear" }}
        />

        {/* Middle ring */}
        <motion.div
          className="absolute inset-2 rounded-full border-4 border-[#007BFF]/50 dark:border-[#00FFFF]/50"
          animate={{ rotate: -360 }}
          transition={{ duration: 2, repeat: Number.POSITIVE_INFINITY, ease: "linear" }}
        />

        {/* Inner core */}
        <motion.div
          className="absolute inset-6 rounded-full bg-gradient-to-r from-[#007BFF] to-[#00FFFF] dark:from-[#00FFFF] dark:to-[#007BFF]"
          animate={{ scale: [1, 1.2, 1] }}
          transition={{ duration: 1.5, repeat: Number.POSITIVE_INFINITY, ease: "easeInOut" }}
        />

        {/* Pulsing dots */}
        {[0, 1, 2, 3].map((i) => (
          <motion.div
            key={i}
            className="absolute w-2 h-2 bg-[#007BFF] dark:bg-[#00FFFF] rounded-full"
            style={{
              top: "50%",
              left: "50%",
              transformOrigin: "0 0",
            }}
            animate={{
              rotate: i * 90,
              x: [0, 30, 0],
              opacity: [0.3, 1, 0.3],
            }}
            transition={{
              duration: 2,
              repeat: Number.POSITIVE_INFINITY,
              delay: i * 0.2,
              ease: "easeInOut",
            }}
          />
        ))}
      </div>
    </div>
  )
}

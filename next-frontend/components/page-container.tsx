"use client"

import type React from "react"

import { motion } from "framer-motion"

interface PageContainerProps {
  children: React.ReactNode
  className?: string
}

export function PageContainer({ children, className = "" }: PageContainerProps) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.5 }}
      className={`min-h-screen relative ${className}`}
    >
      {children}
    </motion.div>
  )
}

"use client"

import { useState, useEffect } from "react"
import { AnimatePresence } from "framer-motion"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { Navigation } from "@/components/navigation"
import { Hero } from "@/components/hero"
import { FeatureCards } from "@/components/feature-cards"
import { Footer } from "@/components/footer"
import { AuraWelcome } from "@/components/aura-welcome"

export default function HomePage() {
  const [showAuraWelcome, setShowAuraWelcome] = useState(false)
  const [hasSeenWelcome, setHasSeenWelcome] = useState(false)

  useEffect(() => {
    try {
      const hasSeenAura = localStorage.getItem("juris-aura-welcome-seen")
      if (!hasSeenAura) {
        setShowAuraWelcome(true)
      } else {
        setHasSeenWelcome(true)
      }
    } catch (error) {
      console.error("Error checking welcome status:", error)
      setHasSeenWelcome(true)
    }
  }, [])

  const handleWelcomeComplete = () => {
    setShowAuraWelcome(false)
    setHasSeenWelcome(true)
    try {
      localStorage.setItem("juris-aura-welcome-seen", "true")
    } catch (error) {
      console.error("Error saving welcome status:", error)
    }
  }

  return (
    <>
      <LivingBackground />

      <AnimatePresence mode="wait">
        {showAuraWelcome ? (
          <AuraWelcome key="aura-welcome" onComplete={handleWelcomeComplete} />
        ) : (
          <PageContainer key="main-content">
            <Navigation />
            <main className="pt-16">
              <Hero />
              <FeatureCards />
              <Footer />
            </main>
          </PageContainer>
        )}
      </AnimatePresence>
    </>
  )
}

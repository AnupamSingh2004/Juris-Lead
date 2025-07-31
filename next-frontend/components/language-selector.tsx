"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Globe, ChevronDown, Check } from "lucide-react"

const languages = [
  { code: "en", name: "English", flag: "🇺🇸" },
  { code: "hi", name: "हिंदी", flag: "🇮🇳" },
  { code: "mr", name: "मराठी", flag: "🇮🇳" },
  { code: "gu", name: "ગુજરાતી", flag: "🇮🇳" },
  { code: "ta", name: "தமிழ்", flag: "🇮🇳" },
  { code: "te", name: "తెలుగు", flag: "🇮🇳" },
]

export function LanguageSelector() {
  const [isOpen, setIsOpen] = useState(false)
  const [selectedLanguage, setSelectedLanguage] = useState(languages[0])

  const handleLanguageSelect = (language: (typeof languages)[0]) => {
    setSelectedLanguage(language)
    setIsOpen(false)
    // Here you would implement actual language switching logic
  }

  return (
    <div className="relative">
      <Button
        variant="ghost"
        size="sm"
        onClick={() => setIsOpen(!isOpen)}
        className="text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-100 dark:hover:bg-[#1B263B] prestigious-hover transition-all duration-300 dark:glow-cyan"
      >
        <Globe className="w-4 h-4 mr-2" />
        <span className="hidden sm:inline">{selectedLanguage.name}</span>
        <span className="sm:hidden">{selectedLanguage.flag}</span>
        <ChevronDown className="w-4 h-4 ml-1" />
      </Button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.95 }}
            transition={{ duration: 0.2 }}
            className="absolute right-0 top-full mt-2 w-48 bg-white dark:bg-[#1B263B] rounded-lg shadow-xl border border-gray-200 dark:border-[#1B263B] overflow-hidden z-50"
          >
            {languages.map((language) => (
              <motion.button
                key={language.code}
                onClick={() => handleLanguageSelect(language)}
                className="w-full flex items-center gap-3 px-4 py-3 text-left text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 transition-colors duration-200 prestigious-hover"
                whileHover={{ x: 4 }}
                transition={{ type: "spring", stiffness: 300 }}
              >
                <span className="text-lg">{language.flag}</span>
                <span className="flex-1">{language.name}</span>
                {selectedLanguage.code === language.code && (
                  <Check className="w-4 h-4 text-[#007BFF] dark:text-[#00FFFF]" />
                )}
              </motion.button>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

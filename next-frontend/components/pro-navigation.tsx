"use client"

import { useState } from "react"
import { useTheme } from "next-themes"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { motion, AnimatePresence } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Scale, Sun, Moon, Menu, X } from "lucide-react"
import { LanguageSelector } from "@/components/language-selector"

export function ProNavigation() {
  const { theme, setTheme } = useTheme()
  const pathname = usePathname()
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  const navItems = [
    { href: "/pro/dashboard", label: "Dashboard" },
    { href: "/pro/my-cases", label: "My Cases" },
    { href: "/pro/profile", label: "Profile" },
    { href: "/pro/billing", label: "Billing" },
  ]

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 backdrop-blur-[16px] bg-white/80 dark:bg-[#0D1B2A]/80 border-b border-gray-200/50 dark:border-gray-700/50">
      <div className="max-w-[1400px] mx-auto px-6">
        <div className="flex items-center justify-between h-16">
          <Link href="/pro/dashboard" className="flex items-center gap-3">
            <Scale className="w-8 h-8 text-[#007BFF] dark:text-[#00FFFF]" />
            <span className="text-2xl font-bold text-gray-900 dark:text-white">
              Juris-Lead <span className="text-[#007BFF] dark:text-[#00FFFF]">Pro</span>
            </span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden lg:flex items-center gap-8">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={`text-sm font-medium transition-colors hover:text-[#007BFF] dark:hover:text-[#00FFFF] ${
                  pathname === item.href ? "text-[#007BFF] dark:text-[#00FFFF]" : "text-gray-700 dark:text-gray-200"
                }`}
              >
                {item.label}
              </Link>
            ))}
          </div>

          <div className="flex items-center gap-4">
            <LanguageSelector />

            <Button
              variant="ghost"
              size="sm"
              onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
              className="text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-800"
            >
              {theme === "dark" ? <Sun className="w-4 h-4" /> : <Moon className="w-4 h-4" />}
            </Button>

            <Link
              href="/"
              className="hidden lg:block text-sm font-medium text-gray-700 dark:text-gray-200 hover:text-[#007BFF] dark:hover:text-[#00FFFF] transition-colors"
            >
              Citizen Platform
            </Link>

            {/* Mobile Menu Button */}
            <Button
              variant="ghost"
              size="sm"
              className="lg:hidden text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-800"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
            >
              {isMenuOpen ? <X className="w-4 h-4" /> : <Menu className="w-4 h-4" />}
            </Button>
          </div>
        </div>

        {/* Mobile Navigation */}
        <AnimatePresence>
          {isMenuOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              className="lg:hidden py-4 border-t border-gray-200/50 dark:border-gray-700/50"
            >
              <div className="flex flex-col gap-4">
                {navItems.map((item) => (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={() => setIsMenuOpen(false)}
                    className={`text-sm font-medium transition-colors hover:text-[#007BFF] dark:hover:text-[#00FFFF] ${
                      pathname === item.href ? "text-[#007BFF] dark:text-[#00FFFF]" : "text-gray-700 dark:text-gray-200"
                    }`}
                  >
                    {item.label}
                  </Link>
                ))}
                <Link
                  href="/"
                  onClick={() => setIsMenuOpen(false)}
                  className="text-sm font-medium text-gray-700 dark:text-gray-200 hover:text-[#007BFF] dark:hover:text-[#00FFFF] transition-colors"
                >
                  Citizen Platform
                </Link>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </nav>
  )
}

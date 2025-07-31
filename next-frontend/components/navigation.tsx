"use client"

import { useState, useEffect } from "react"
import { useTheme } from "next-themes"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { motion, AnimatePresence } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Scale, Sun, Moon, Menu, X, User, History, LayoutDashboard, Settings, LogOut, ChevronDown } from "lucide-react"
import { LoginModal } from "@/components/login-modal"
import { LanguageSelector } from "@/components/language-selector"

interface UserProfile {
  name: string
  email: string
}

export function Navigation() {
  const { theme, setTheme } = useTheme()
  const pathname = usePathname()
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [showLoginModal, setShowLoginModal] = useState(false)
  const [mounted, setMounted] = useState(false)
  const [isLoggedIn, setIsLoggedIn] = useState(false)
  const [showProfileDropdown, setShowProfileDropdown] = useState(false)
  const [userProfile, setUserProfile] = useState<UserProfile>({ name: "John Doe", email: "john@example.com" })

  useEffect(() => {
    setMounted(true)

    // Check if user is logged in
    try {
      const loggedIn = localStorage.getItem("juris-logged-in")
      if (loggedIn === "true") {
        setIsLoggedIn(true)
        const profileData = localStorage.getItem("juris-user-profile")
        if (profileData) {
          const profile = JSON.parse(profileData)
          setUserProfile(profile)
        }
      }
    } catch (error) {
      console.error("Error loading user state:", error)
      // Reset to logged out state if there's an error
      setIsLoggedIn(false)
      localStorage.removeItem("juris-logged-in")
      localStorage.removeItem("juris-user-profile")
    }
  }, [])

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      const target = event.target as Element
      if (showProfileDropdown && !target.closest("[data-profile-dropdown]")) {
        setShowProfileDropdown(false)
      }
    }

    document.addEventListener("click", handleClickOutside)
    return () => document.removeEventListener("click", handleClickOutside)
  }, [showProfileDropdown])

  const navItems = [
    { href: "/analyzer", label: "Analyze Incident" },
    { href: "/summarizer", label: "Summarize Document" },
    { href: "/case-builder", label: "Case Builder" },
    { href: "/explore", label: "Explore Topics" },
    { href: "/find-lawyer", label: "Find a Lawyer" },
  ]

  const toggleTheme = () => {
    const newTheme = theme === "dark" ? "light" : "dark"
    setTheme(newTheme)
    try {
      localStorage.setItem("juris-theme", newTheme)
    } catch (error) {
      console.error("Error saving theme:", error)
    }
  }

  const handleLoginSuccess = (profile: UserProfile) => {
    setIsLoggedIn(true)
    setUserProfile(profile)
    setShowLoginModal(false)

    try {
      localStorage.setItem("juris-logged-in", "true")
      localStorage.setItem("juris-user-profile", JSON.stringify(profile))
    } catch (error) {
      console.error("Error saving user state:", error)
    }
  }

  const handleLogout = () => {
    setIsLoggedIn(false)
    setShowProfileDropdown(false)

    try {
      localStorage.removeItem("juris-logged-in")
      localStorage.removeItem("juris-user-profile")
    } catch (error) {
      console.error("Error clearing user state:", error)
    }

    // Redirect to home page
    window.location.href = "/"
  }

  if (!mounted) {
    return null
  }

  return (
    <>
      <nav className="fixed top-0 left-0 right-0 z-50 backdrop-blur-[16px] bg-white/80 dark:bg-[#0D1B2A]/90 border-b border-slate-200/50 dark:border-[#1B263B]/50 transition-all duration-300">
        <div className="max-w-[1400px] mx-auto px-6">
          <div className="flex items-center justify-between h-16">
            <Link href="/" className="flex items-center gap-3 prestigious-hover">
              <Scale className="w-8 h-8 text-[#007BFF] dark:text-[#00FFFF] transition-colors duration-300" />
              <span className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1] transition-colors duration-300">
                Juris-Lead
              </span>
            </Link>

            {/* Desktop Navigation */}
            <div className="hidden lg:flex items-center gap-8">
              {navItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`text-sm font-medium transition-all duration-300 hover:text-[#007BFF] dark:hover:text-[#00FFFF] prestigious-hover ${
                    pathname === item.href ? "text-[#007BFF] dark:text-[#00FFFF]" : "text-gray-700 dark:text-[#E0E6F1]"
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
                onClick={toggleTheme}
                className="text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-100 dark:hover:bg-[#1B263B] prestigious-hover transition-all duration-300 dark:glow-cyan"
              >
                {theme === "dark" ? <Sun className="w-4 h-4 text-[#00FFFF]" /> : <Moon className="w-4 h-4" />}
              </Button>

              {/* Authenticated User Profile Dropdown */}
              {isLoggedIn ? (
                <div className="relative" data-profile-dropdown>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setShowProfileDropdown(!showProfileDropdown)}
                    className="hidden lg:flex items-center gap-2 text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-100 dark:hover:bg-[#1B263B] prestigious-hover transition-all duration-300"
                  >
                    <div className="w-8 h-8 rounded-full bg-gradient-to-r from-[#007BFF] to-[#00FFFF] dark:from-[#00FFFF] dark:to-[#007BFF] flex items-center justify-center">
                      <User className="w-4 h-4 text-white dark:text-[#0D1B2A]" />
                    </div>
                    <ChevronDown className="w-4 h-4" />
                  </Button>

                  <AnimatePresence>
                    {showProfileDropdown && (
                      <motion.div
                        initial={{ opacity: 0, y: -10, scale: 0.95 }}
                        animate={{ opacity: 1, y: 0, scale: 1 }}
                        exit={{ opacity: 0, y: -10, scale: 0.95 }}
                        transition={{ duration: 0.2 }}
                        className="absolute right-0 top-full mt-2 w-64 bg-white dark:bg-[#1B263B] rounded-lg shadow-xl border border-gray-200 dark:border-[#1B263B] overflow-hidden z-50"
                      >
                        {/* User Info Header */}
                        <div className="p-4 bg-gray-50 dark:bg-[#0D1B2A]/50 border-b border-gray-200 dark:border-[#1B263B]">
                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-full bg-gradient-to-r from-[#007BFF] to-[#00FFFF] dark:from-[#00FFFF] dark:to-[#007BFF] flex items-center justify-center">
                              <User className="w-5 h-5 text-white dark:text-[#0D1B2A]" />
                            </div>
                            <div>
                              <p className="font-semibold text-gray-900 dark:text-[#E0E6F1]">{userProfile.name}</p>
                              <p className="text-sm text-gray-600 dark:text-gray-300">{userProfile.email}</p>
                            </div>
                          </div>
                        </div>

                        {/* Navigation Links */}
                        <div className="py-2">
                          <Link
                            href="/client-history"
                            onClick={() => setShowProfileDropdown(false)}
                            className="flex items-center gap-3 px-4 py-3 text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 transition-colors duration-200 prestigious-hover"
                          >
                            <History className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                            <span className="font-medium">My History</span>
                          </Link>

                          <Link
                            href="/client-dashboard"
                            onClick={() => setShowProfileDropdown(false)}
                            className="flex items-center gap-3 px-4 py-3 text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 transition-colors duration-200 prestigious-hover"
                          >
                            <LayoutDashboard className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                            <span>My Dashboard</span>
                          </Link>

                          <Link
                            href="/profile-settings"
                            onClick={() => setShowProfileDropdown(false)}
                            className="flex items-center gap-3 px-4 py-3 text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-50 dark:hover:bg-[#0D1B2A]/50 transition-colors duration-200 prestigious-hover"
                          >
                            <Settings className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                            <span>Profile Settings</span>
                          </Link>

                          <div className="border-t border-gray-200 dark:border-[#1B263B] my-2" />

                          <button
                            onClick={handleLogout}
                            className="flex items-center gap-3 px-4 py-3 w-full text-left text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors duration-200 prestigious-hover"
                          >
                            <LogOut className="w-5 h-5" />
                            <span>Logout</span>
                          </button>
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              ) : (
                <>
                  <Button
                    onClick={() => setShowLoginModal(true)}
                    className="hidden lg:flex bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover transition-all duration-300 dark:glow-cyan"
                  >
                    <User className="w-4 h-4 mr-2" />
                    Client Login
                  </Button>

                  <Link
                    href="/pro/dashboard"
                    className="hidden lg:block text-sm font-medium text-gray-700 dark:text-[#E0E6F1] hover:text-[#007BFF] dark:hover:text-[#00FFFF] transition-all duration-300 prestigious-hover"
                  >
                    For Lawyers
                  </Link>
                </>
              )}

              {/* Mobile Menu Button */}
              <Button
                variant="ghost"
                size="sm"
                className="lg:hidden text-gray-700 dark:text-[#E0E6F1] hover:bg-gray-100 dark:hover:bg-[#1B263B] prestigious-hover"
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
                className="lg:hidden py-4 border-t border-slate-200/50 dark:border-[#1B263B]/50"
              >
                <div className="flex flex-col gap-4">
                  {navItems.map((item) => (
                    <Link
                      key={item.href}
                      href={item.href}
                      onClick={() => setIsMenuOpen(false)}
                      className={`text-sm font-medium transition-all duration-300 hover:text-[#007BFF] dark:hover:text-[#00FFFF] ${
                        pathname === item.href
                          ? "text-[#007BFF] dark:text-[#00FFFF]"
                          : "text-gray-700 dark:text-[#E0E6F1]"
                      }`}
                    >
                      {item.label}
                    </Link>
                  ))}

                  {isLoggedIn ? (
                    <>
                      <div className="border-t border-gray-200 dark:border-[#1B263B] my-2" />
                      <Link
                        href="/client-history"
                        onClick={() => setIsMenuOpen(false)}
                        className="flex items-center gap-2 text-sm font-medium text-gray-700 dark:text-[#E0E6F1] hover:text-[#007BFF] dark:hover:text-[#00FFFF] transition-all duration-300"
                      >
                        <History className="w-4 h-4" />
                        My History
                      </Link>
                      <Link
                        href="/client-dashboard"
                        onClick={() => setIsMenuOpen(false)}
                        className="flex items-center gap-2 text-sm font-medium text-gray-700 dark:text-[#E0E6F1] hover:text-[#007BFF] dark:hover:text-[#00FFFF] transition-all duration-300"
                      >
                        <LayoutDashboard className="w-4 h-4" />
                        My Dashboard
                      </Link>
                      <button
                        onClick={handleLogout}
                        className="flex items-center gap-2 text-sm font-medium text-red-600 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300 transition-all duration-300 text-left"
                      >
                        <LogOut className="w-4 h-4" />
                        Logout
                      </button>
                    </>
                  ) : (
                    <>
                      <Button
                        onClick={() => {
                          setShowLoginModal(true)
                          setIsMenuOpen(false)
                        }}
                        className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white w-full prestigious-hover dark:glow-cyan"
                      >
                        <User className="w-4 h-4 mr-2" />
                        Client Login
                      </Button>
                      <Link
                        href="/pro/dashboard"
                        onClick={() => setIsMenuOpen(false)}
                        className="text-sm font-medium text-gray-700 dark:text-[#E0E6F1] hover:text-[#007BFF] dark:hover:text-[#00FFFF] transition-all duration-300"
                      >
                        For Lawyers
                      </Link>
                    </>
                  )}
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </nav>

      <LoginModal
        isOpen={showLoginModal}
        onClose={() => setShowLoginModal(false)}
        onLoginSuccess={handleLoginSuccess}
      />
    </>
  )
}

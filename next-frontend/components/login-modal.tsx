"use client"

import type React from "react"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card } from "@/components/ui/card"
import { X, Mail, Lock, Eye, EyeOff, User, Sparkles } from "lucide-react"

interface LoginModalProps {
  isOpen: boolean
  onClose: () => void
  onLoginSuccess: (profile: { name: string; email: string }) => void
}

export function LoginModal({ isOpen, onClose, onLoginSuccess }: LoginModalProps) {
  const [isLogin, setIsLogin] = useState(true)
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
  })
  const [errors, setErrors] = useState<Record<string, string>>({})

  const validateForm = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.email) {
      newErrors.email = "Email is required"
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = "Please enter a valid email"
    }

    if (!formData.password) {
      newErrors.password = "Password is required"
    } else if (formData.password.length < 6) {
      newErrors.password = "Password must be at least 6 characters"
    }

    if (!isLogin && !formData.name) {
      newErrors.name = "Name is required"
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!validateForm()) return

    setIsLoading(true)

    try {
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1500))

      // Mock successful login/signup
      const profile = {
        name: formData.name || formData.email.split("@")[0],
        email: formData.email,
      }

      onLoginSuccess(profile)
      onClose()
      resetForm()
    } catch (error) {
      console.error("Authentication error:", error)
      setErrors({ general: "Authentication failed. Please try again." })
    } finally {
      setIsLoading(false)
    }
  }

  const resetForm = () => {
    setFormData({ name: "", email: "", password: "" })
    setErrors({})
    setShowPassword(false)
    setIsLoading(false)
  }

  const handleClose = () => {
    resetForm()
    onClose()
  }

  const switchMode = () => {
    setIsLogin(!isLogin)
    setErrors({})
  }

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm"
          onClick={handleClose}
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            transition={{ type: "spring", stiffness: 300, damping: 30 }}
            onClick={(e) => e.stopPropagation()}
            className="w-full max-w-md"
          >
            <Card className="p-8 bg-white dark:bg-[#1B263B] border-gray-200 dark:border-[#1B263B] shadow-2xl relative overflow-hidden">
              {/* Background Effects */}
              <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <motion.div
                  className="absolute top-0 right-0 w-32 h-32 bg-gradient-to-br from-[#007BFF]/10 to-[#00FFFF]/10 dark:from-[#00FFFF]/10 dark:to-[#007BFF]/10 rounded-full blur-2xl"
                  animate={{
                    scale: [1, 1.2, 1],
                    opacity: [0.3, 0.6, 0.3],
                  }}
                  transition={{
                    duration: 4,
                    repeat: Number.POSITIVE_INFINITY,
                    ease: "easeInOut",
                  }}
                />
              </div>

              {/* Close Button */}
              <motion.button
                onClick={handleClose}
                className="absolute top-4 right-4 p-2 text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-300 transition-colors duration-200 z-10"
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
              >
                <X className="w-5 h-5" />
              </motion.button>

              {/* Header */}
              <div className="text-center mb-8 relative z-10">
                <motion.div
                  className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-[#007BFF] to-[#00FFFF] dark:from-[#00FFFF] dark:to-[#007BFF] rounded-2xl mb-4 shadow-lg"
                  animate={{
                    boxShadow: [
                      "0 0 20px rgba(0, 123, 255, 0.3)",
                      "0 0 30px rgba(0, 255, 255, 0.4)",
                      "0 0 20px rgba(0, 123, 255, 0.3)",
                    ],
                  }}
                  transition={{
                    duration: 3,
                    repeat: Number.POSITIVE_INFINITY,
                    ease: "easeInOut",
                  }}
                >
                  <User className="w-8 h-8 text-white" />
                </motion.div>
                <h2 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-2">
                  {isLogin ? "Welcome Back" : "Create Account"}
                </h2>
                <p className="text-gray-600 dark:text-gray-300">
                  {isLogin ? "Sign in to access your legal dashboard" : "Join thousands of users on Juris-Lead"}
                </p>
              </div>

              {/* Form */}
              <form onSubmit={handleSubmit} className="space-y-6 relative z-10">
                {errors.general && (
                  <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg text-red-600 dark:text-red-400 text-sm"
                  >
                    {errors.general}
                  </motion.div>
                )}

                {!isLogin && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Full Name</label>
                    <div className="relative">
                      <User className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                      <Input
                        type="text"
                        value={formData.name}
                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                        className={`pl-10 bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300 ${
                          errors.name ? "border-red-500 dark:border-red-500" : ""
                        }`}
                        placeholder="Enter your full name"
                        disabled={isLoading}
                      />
                    </div>
                    {errors.name && (
                      <motion.p
                        initial={{ opacity: 0, y: -5 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-red-500 text-sm mt-1"
                      >
                        {errors.name}
                      </motion.p>
                    )}
                  </div>
                )}

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Email Address
                  </label>
                  <div className="relative">
                    <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <Input
                      type="email"
                      value={formData.email}
                      onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                      className={`pl-10 bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300 ${
                        errors.email ? "border-red-500 dark:border-red-500" : ""
                      }`}
                      placeholder="Enter your email"
                      disabled={isLoading}
                    />
                  </div>
                  {errors.email && (
                    <motion.p
                      initial={{ opacity: 0, y: -5 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="text-red-500 text-sm mt-1"
                    >
                      {errors.email}
                    </motion.p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Password</label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <Input
                      type={showPassword ? "text" : "password"}
                      value={formData.password}
                      onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                      className={`pl-10 pr-10 bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan transition-all duration-300 ${
                        errors.password ? "border-red-500 dark:border-red-500" : ""
                      }`}
                      placeholder="Enter your password"
                      disabled={isLoading}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors duration-200"
                      disabled={isLoading}
                    >
                      {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                    </button>
                  </div>
                  {errors.password && (
                    <motion.p
                      initial={{ opacity: 0, y: -5 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="text-red-500 text-sm mt-1"
                    >
                      {errors.password}
                    </motion.p>
                  )}
                </div>

                {isLogin && (
                  <div className="text-right">
                    <button
                      type="button"
                      className="text-sm text-[#007BFF] dark:text-[#00FFFF] hover:underline transition-colors duration-200"
                      disabled={isLoading}
                    >
                      Forgot Password?
                    </button>
                  </div>
                )}

                <motion.div
                  whileHover={{ scale: isLoading ? 1 : 1.02 }}
                  whileTap={{ scale: isLoading ? 1 : 0.98 }}
                  transition={{ type: "spring", stiffness: 300 }}
                >
                  <Button
                    type="submit"
                    disabled={isLoading}
                    className="w-full py-3 text-lg font-semibold bg-gradient-to-r from-[#007BFF] to-[#0056b3] dark:from-[#00FFFF] dark:to-[#00CCCC] hover:from-[#0056b3] hover:to-[#004085] dark:hover:from-[#00CCCC] dark:hover:to-[#00AAAA] text-white dark:text-[#0D1B2A] shadow-lg hover:shadow-xl transition-all duration-300 prestigious-hover dark:glow-cyan disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isLoading ? (
                      <div className="flex items-center justify-center gap-2">
                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                        {isLogin ? "Signing In..." : "Creating Account..."}
                      </div>
                    ) : (
                      <div className="flex items-center justify-center gap-2">
                        <Sparkles className="w-5 h-5" />
                        {isLogin ? "Sign In" : "Create Account"}
                      </div>
                    )}
                  </Button>
                </motion.div>
              </form>

              {/* Switch Mode */}
              <div className="text-center mt-6 relative z-10">
                <p className="text-gray-600 dark:text-gray-300">
                  {isLogin ? "Don't have an account?" : "Already have an account?"}{" "}
                  <button
                    onClick={switchMode}
                    className="text-[#007BFF] dark:text-[#00FFFF] hover:underline font-medium transition-colors duration-200"
                    disabled={isLoading}
                  >
                    {isLogin ? "Sign Up" : "Sign In"}
                  </button>
                </p>
              </div>
            </Card>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}

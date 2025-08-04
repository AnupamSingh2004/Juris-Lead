"use client"

import type React from "react"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card } from "@/components/ui/card"
import { X, Mail, Lock, Eye, EyeOff, User, Sparkles, Shield, Users } from "lucide-react"
import { useAuth } from "@/lib/auth-context"
import { ApiError } from "@/lib/api-service"
import { googleAuthService, type GoogleUserInfo } from "@/lib/google-auth"

interface LoginModalProps {
  isOpen: boolean
  onClose: () => void
  onLoginSuccess?: () => void
}

type UserRole = 'client' | 'lawyer'

export function LoginModal({ isOpen, onClose, onLoginSuccess }: LoginModalProps) {
  const { login, googleLogin } = useAuth()
  const [isLogin, setIsLogin] = useState(true)
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [selectedRole, setSelectedRole] = useState<UserRole>('client')
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
    setErrors({})

    try {
      if (isLogin) {
        await login(formData.email, formData.password, selectedRole)
      } else {
        // For now, show message that registration will be available soon
        setErrors({ general: "Registration feature will be available soon. Please use Google Sign In." })
        setIsLoading(false)
        return
      }

      onLoginSuccess?.()
      onClose()
      resetForm()
    } catch (error) {
      console.error("Authentication error:", error)
      if (error instanceof ApiError) {
        setErrors({ general: error.message })
      } else {
        setErrors({ general: "Authentication failed. Please try again." })
      }
    } finally {
      setIsLoading(false)
    }
  }

  const getRoleSelection = (): Promise<UserRole> => {
    return new Promise((resolve) => {
      // Use the already selected role
      resolve(selectedRole)
    })
  }

  const handleGoogleLogin = async () => {
    setIsLoading(true)
    setErrors({})

    try {
      console.log('Starting Google login process...')
      
      // Get role selection first
      console.log('Getting role selection...')
      const role = await getRoleSelection()
      console.log('Role selected:', role)
      
      console.log('Initiating Google sign-in popup...')
      const { token, userInfo } = await googleAuthService.signInWithPopup()
      console.log('Google sign-in successful, token received')
      
      console.log('Calling backend Google login endpoint...')
      await googleLogin(token, role, userInfo)
      
      console.log('Login successful, closing modal')
      onClose()
    } catch (error: any) {
      console.error('Google login error:', error)
      setErrors({ general: error.message || 'Failed to sign in with Google. Please try again.' })
    } finally {
      setIsLoading(false)
    }
  }

  const resetForm = () => {
    setFormData({ name: "", email: "", password: "" })
    setErrors({})
    setShowPassword(false)
    setIsLoading(false)
    setSelectedRole('client')
  }

  const handleClose = () => {
    resetForm()
    onClose()
  }

  const switchMode = () => {
    setIsLogin(!isLogin)
    setErrors({})
  }

  const RoleSelector = () => (
    <div className="mb-6">
      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
        I am a:
      </label>
      <div className="grid grid-cols-2 gap-3">
        <button
          type="button"
          onClick={() => setSelectedRole('client')}
          className={`flex items-center justify-center p-4 rounded-lg border-2 transition-all ${
            selectedRole === 'client'
              ? 'border-[#007BFF] bg-[#007BFF]/10 dark:bg-[#00FFFF]/10'
              : 'border-gray-200 dark:border-gray-700 hover:border-gray-300'
          }`}
        >
          <Users className="w-5 h-5 mr-2" />
          <div className="text-left">
            <div className="font-medium">Client</div>
            <div className="text-xs text-gray-500">Need legal help</div>
          </div>
        </button>
        <button
          type="button"
          onClick={() => setSelectedRole('lawyer')}
          className={`flex items-center justify-center p-4 rounded-lg border-2 transition-all ${
            selectedRole === 'lawyer'
              ? 'border-[#007BFF] bg-[#007BFF]/10 dark:bg-[#00FFFF]/10'
              : 'border-gray-200 dark:border-gray-700 hover:border-gray-300'
          }`}
        >
          <Shield className="w-5 h-5 mr-2" />
          <div className="text-left">
            <div className="font-medium">Lawyer</div>
            <div className="text-xs text-gray-500">Legal professional</div>
          </div>
        </button>
      </div>
    </div>
  )

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

              {/* Role Selector */}
              <RoleSelector />

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

              {/* Google Login */}
              <div className="mt-6 relative z-10">
                <div className="relative">
                  <div className="absolute inset-0 flex items-center">
                    <div className="w-full border-t border-gray-300 dark:border-gray-700" />
                  </div>
                  <div className="relative flex justify-center text-sm">
                    <span className="px-2 bg-white dark:bg-[#1B263B] text-gray-500">or continue with</span>
                  </div>
                </div>

                <motion.div
                  whileHover={{ scale: isLoading ? 1 : 1.02 }}
                  whileTap={{ scale: isLoading ? 1 : 0.98 }}
                  transition={{ type: "spring", stiffness: 300 }}
                >
                  <Button
                    type="button"
                    variant="outline"
                    className="w-full mt-4 py-3 text-lg font-semibold border-gray-300 dark:border-[#1B263B] hover:border-[#007BFF] dark:hover:border-[#00FFFF] transition-all duration-300"
                    onClick={handleGoogleLogin}
                    disabled={isLoading}
                  >
                    <svg className="w-5 h-5 mr-2" viewBox="0 0 24 24">
                      <path
                        fill="currentColor"
                        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                      />
                      <path
                        fill="currentColor"
                        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                      />
                      <path
                        fill="currentColor"
                        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                      />
                      <path
                        fill="currentColor"
                        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                      />
                    </svg>
                    Sign {isLogin ? "in" : "up"} with Google
                  </Button>
                </motion.div>
              </div>

              {/* Lawyer Disclaimer */}
              {selectedRole === 'lawyer' && (
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="mt-4 p-3 bg-blue-50 dark:bg-blue-900/30 border border-blue-200 dark:border-blue-700 rounded-lg relative z-10"
                >
                  <p className="text-xs text-blue-700 dark:text-blue-300 flex items-start">
                    <Shield className="w-4 h-4 mr-1 mt-0.5 flex-shrink-0" />
                    Lawyer accounts require verification of bar council registration and practice details.
                  </p>
                </motion.div>
              )}

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

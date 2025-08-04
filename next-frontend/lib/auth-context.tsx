"use client"

import React, { createContext, useContext, useEffect, useState } from 'react'
import { ApiService, type LoginRequest, type UserProfile } from "./api-service"
import type { GoogleUserInfo } from "./google-auth"

interface AuthContextType {
  user: UserProfile | null
  isAuthenticated: boolean
  isLawyer: boolean
  isClient: boolean
  isLoading: boolean
  login: (email: string, password: string, userRole: 'client' | 'lawyer') => Promise<void>
  googleLogin: (accessToken: string, userRole: 'client' | 'lawyer', userInfo?: GoogleUserInfo) => Promise<void>
  logout: () => Promise<void>
  refreshProfile: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<UserProfile | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  const isAuthenticated = !!user && ApiService.isAuthenticated()
  const isLawyer = user?.user_role === 'lawyer'
  const isClient = user?.user_role === 'client'

  useEffect(() => {
    // Check if user is already logged in on mount
    const initializeAuth = async () => {
      try {
        if (ApiService.isAuthenticated()) {
          const storedUser = ApiService.getCurrentUser()
          if (storedUser) {
            setUser(storedUser)
            // Refresh profile to ensure it's up to date
            try {
              const updatedUser = await ApiService.getProfile()
              setUser(updatedUser)
            } catch (error) {
              console.warn('Failed to refresh profile:', error)
              // If profile refresh fails but we have stored data, use it
            }
          }
        }
      } catch (error) {
        console.error('Auth initialization error:', error)
        // Clear invalid auth state
        await logout()
      } finally {
        setIsLoading(false)
      }
    }

    initializeAuth()
  }, [])

  const login = async (email: string, password: string, userRole: 'client' | 'lawyer') => {
    try {
      setIsLoading(true)
      const response = await ApiService.login({ email, password, user_role: userRole })
      setUser(response.user)
    } catch (error) {
      console.error('Login error:', error)
      throw error
    } finally {
      setIsLoading(false)
    }
  }

  const googleLogin = async (accessToken: string, userRole: 'client' | 'lawyer', userInfo?: GoogleUserInfo) => {
    try {
      setIsLoading(true)
      const response = await ApiService.googleLogin({ 
        access_token: accessToken, 
        user_role: userRole,
        ...(userInfo && {
          email: userInfo.email,
          first_name: userInfo.given_name,
          last_name: userInfo.family_name,
          google_id: userInfo.id
        })
      })
      setUser(response.user)
    } catch (error) {
      console.error('Google login error:', error)
      throw error
    } finally {
      setIsLoading(false)
    }
  }

  const logout = async () => {
    try {
      setIsLoading(true)
      await ApiService.logout()
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      setUser(null)
      setIsLoading(false)
    }
  }

  const refreshProfile = async () => {
    try {
      if (isAuthenticated) {
        const updatedUser = await ApiService.getProfile()
        setUser(updatedUser)
      }
    } catch (error) {
      console.error('Profile refresh error:', error)
      // If refresh fails, logout user
      await logout()
    }
  }

  const value: AuthContextType = {
    user,
    isAuthenticated,
    isLoading,
    isLawyer,
    isClient,
    login,
    googleLogin,
    logout,
    refreshProfile,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

// Higher-order component for protecting routes
export function withAuth<P extends object>(
  Component: React.ComponentType<P>,
  allowedRoles?: ('client' | 'lawyer')[]
) {
  return function ProtectedComponent(props: P) {
    const { isAuthenticated, isLoading, user } = useAuth()

    if (isLoading) {
      return (
        <div className="flex items-center justify-center min-h-screen">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-[#007BFF]"></div>
        </div>
      )
    }

    if (!isAuthenticated) {
      return (
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-center">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
              Authentication Required
            </h2>
            <p className="text-gray-600 dark:text-gray-300">
              Please log in to access this page.
            </p>
          </div>
        </div>
      )
    }

    if (allowedRoles && user && !allowedRoles.includes(user.user_role)) {
      return (
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-center">
            <h2 className="text-2xl font-bold text-red-600 mb-4">
              Access Denied
            </h2>
            <p className="text-gray-600 dark:text-gray-300">
              You don't have permission to access this page.
            </p>
          </div>
        </div>
      )
    }

    return <Component {...props} />
  }
}

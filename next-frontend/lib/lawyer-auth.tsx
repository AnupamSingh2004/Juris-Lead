"use client"

import { useAuth } from "@/lib/auth-context"
import { useRouter } from "next/navigation"
import { useEffect } from "react"
import { motion } from "framer-motion"
import { Shield, AlertTriangle } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"

interface WithLawyerAuthProps {
  children?: React.ReactNode
}

/**
 * Higher-order component that ensures only authenticated lawyers can access wrapped components
 */
export function withLawyerAuth<P extends object>(
  WrappedComponent: React.ComponentType<P>
): React.ComponentType<P> {
  return function LawyerOnlyComponent(props: P) {
    const { user, isAuthenticated, isLawyer, isLoading } = useAuth()
    const router = useRouter()

    useEffect(() => {
      if (!isLoading && isAuthenticated && !isLawyer) {
        // Redirect non-lawyers to homepage
        router.push("/")
      }
    }, [isLoading, isAuthenticated, isLawyer, router])

    // Show loading state while checking authentication
    if (isLoading) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#0D1B2A] via-[#1B263B] to-[#415A77]">
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="text-center"
          >
            <div className="w-12 h-12 border-4 border-[#00FFFF] border-t-transparent rounded-full animate-spin mx-auto mb-4" />
            <p className="text-[#E0E6F1] text-lg">Verifying access...</p>
          </motion.div>
        </div>
      )
    }

    // Show access denied if not authenticated
    if (!isAuthenticated) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#0D1B2A] via-[#1B263B] to-[#415A77] p-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="max-w-md w-full"
          >
            <Card className="p-8 bg-white/10 backdrop-blur-md border-[#1B263B] text-center">
              <motion.div
                className="w-16 h-16 bg-red-500/20 rounded-full flex items-center justify-center mx-auto mb-4"
                animate={{ scale: [1, 1.1, 1] }}
                transition={{ duration: 2, repeat: Infinity }}
              >
                <AlertTriangle className="w-8 h-8 text-red-400" />
              </motion.div>
              <h1 className="text-2xl font-bold text-[#E0E6F1] mb-4">
                Authentication Required
              </h1>
              <p className="text-gray-300 mb-6">
                You must be logged in to access this professional area.
              </p>
              <Button
                onClick={() => router.push("/")}
                className="w-full bg-gradient-to-r from-[#00FFFF] to-[#007BFF] hover:from-[#00CCCC] hover:to-[#0056b3] text-[#0D1B2A] font-semibold"
              >
                Go to Login
              </Button>
            </Card>
          </motion.div>
        </div>
      )
    }

    // Show access denied if not a lawyer
    if (!isLawyer) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#0D1B2A] via-[#1B263B] to-[#415A77] p-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="max-w-md w-full"
          >
            <Card className="p-8 bg-white/10 backdrop-blur-md border-[#1B263B] text-center">
              <motion.div
                className="w-16 h-16 bg-amber-500/20 rounded-full flex items-center justify-center mx-auto mb-4"
                animate={{ scale: [1, 1.1, 1] }}
                transition={{ duration: 2, repeat: Infinity }}
              >
                <Shield className="w-8 h-8 text-amber-400" />
              </motion.div>
              <h1 className="text-2xl font-bold text-[#E0E6F1] mb-4">
                Lawyer Access Only
              </h1>
              <p className="text-gray-300 mb-6">
                This professional dashboard is reserved for verified lawyers only. 
                You are currently logged in as a client.
              </p>
              <div className="space-y-3">
                <Button
                  onClick={() => router.push("/")}
                  className="w-full bg-gradient-to-r from-[#00FFFF] to-[#007BFF] hover:from-[#00CCCC] hover:to-[#0056b3] text-[#0D1B2A] font-semibold"
                >
                  Go to Client Area
                </Button>
                <Button
                  onClick={() => router.push("/find-lawyer")}
                  variant="outline"
                  className="w-full border-[#00FFFF] text-[#00FFFF] hover:bg-[#00FFFF] hover:text-[#0D1B2A]"
                >
                  Find a Lawyer
                </Button>
              </div>
            </Card>
          </motion.div>
        </div>
      )
    }

    // User is authenticated and is a lawyer, render the component
    return <WrappedComponent {...props} />
  }
}

/**
 * Component wrapper for lawyer-only areas
 */
export function LawyerOnly({ children }: WithLawyerAuthProps) {
  const { user, isAuthenticated, isLawyer, isLoading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!isLoading && isAuthenticated && !isLawyer) {
      router.push("/")
    }
  }, [isLoading, isAuthenticated, isLawyer, router])

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="w-8 h-8 border-4 border-[#00FFFF] border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }

  if (!isAuthenticated || !isLawyer) {
    return null
  }

  return <>{children}</>
}

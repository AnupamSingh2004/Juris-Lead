import type React from "react"
import { cn } from "@/lib/utils"

interface GlassCardProps {
  children: React.ReactNode
  className?: string
}

export function GlassCard({ children, className }: GlassCardProps) {
  return (
    <div
      className={cn(
        "backdrop-blur-md bg-white/10 dark:bg-white/5 border border-white/20 rounded-2xl shadow-xl hover:bg-white/15 dark:hover:bg-white/10 transition-all duration-300",
        className,
      )}
    >
      {children}
    </div>
  )
}

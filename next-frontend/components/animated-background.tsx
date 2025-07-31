"use client"

import { useTheme } from "next-themes"

export function AnimatedBackground() {
  const { theme } = useTheme()

  return (
    <div className="fixed inset-0 -z-10 overflow-hidden">
      <div
        className={`absolute inset-0 opacity-60 ${
          theme === "dark"
            ? "bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900"
            : "bg-gradient-to-br from-blue-50 via-purple-50 to-blue-50"
        }`}
        style={{
          background:
            theme === "dark"
              ? `
              radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
              radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%),
              radial-gradient(circle at 40% 80%, rgba(120, 219, 255, 0.3) 0%, transparent 50%),
              linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #0f172a 100%)
            `
              : `
              radial-gradient(circle at 20% 50%, rgba(147, 197, 253, 0.3) 0%, transparent 50%),
              radial-gradient(circle at 80% 20%, rgba(196, 181, 253, 0.3) 0%, transparent 50%),
              radial-gradient(circle at 40% 80%, rgba(147, 197, 253, 0.3) 0%, transparent 50%),
              linear-gradient(135deg, #f8fafc 0%, #e0e7ff 50%, #f8fafc 100%)
            `,
          animation: "float 20s ease-in-out infinite",
        }}
      />
      <style jsx>{`
        @keyframes float {
          0%, 100% { transform: translate(0px, 0px) rotate(0deg); }
          33% { transform: translate(30px, -30px) rotate(120deg); }
          66% { transform: translate(-20px, 20px) rotate(240deg); }
        }
      `}</style>
    </div>
  )
}

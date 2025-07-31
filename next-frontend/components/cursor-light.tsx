"use client"

import { useEffect, useState } from "react"

export function CursorLight() {
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 })

  useEffect(() => {
    const updateMousePosition = (e: MouseEvent) => {
      setMousePosition({ x: e.clientX, y: e.clientY })
    }

    window.addEventListener("mousemove", updateMousePosition)
    return () => window.removeEventListener("mousemove", updateMousePosition)
  }, [])

  return (
    <div
      className="fixed pointer-events-none z-30 mix-blend-screen"
      style={{
        left: mousePosition.x - 100,
        top: mousePosition.y - 100,
        width: 200,
        height: 200,
        background: "radial-gradient(circle, rgba(0, 82, 204, 0.15) 0%, rgba(51, 161, 255, 0.1) 30%, transparent 70%)",
        borderRadius: "50%",
        transition: "all 0.1s ease-out",
      }}
    />
  )
}
